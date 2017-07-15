// This program is free software: you can use, modify and/or redistribute it
// under the terms of the simplified BSD License. You should have received a
// copy of this license along this program. If not, see
// <http://www.opensource.org/licenses/bsd-license.html>.
//
// Copyright (C) 2015, Javier Sánchez Pérez <jsanchez@dis.ulpgc.es>
// All rights reserved.

/** 
  * 
  *  This code implements the 'inverse compositional algorithm' proposed in
  *     [1] S. Baker, and I. Matthews. (2004). Lucas-kanade 20 years on: A 
  *         unifying framework. International Journal of Computer Vision, 
  *         56(3), 221-255.
  *     [2] S. Baker, R. Gross, I. Matthews, and T. Ishikawa. (2004). 
  *         Lucas-kanade 20 years on: A unifying framework: Part 2. 
  *         International Journal of Computer Vision, 56(3), 221-255.
  *  
  *  This implementation is for color images. It calculates the global 
  *  transform between two images. It uses robust error functions and a 
  *  coarse-to-fine strategy for computing large displacements
  * 
**/

#include <stdlib.h>
#include <math.h>
#include <stdio.h>

#include "bicubic_interpolation.h"
#include "inverse_compositional_algorithm.h"
#include "matrix.h"
#include "mask.h"
#include "transformation.h"
#include "zoom.h"


/**
 *
 *  Derivative of robust error functions
 *
 */
double rhop(
  double t2,     //squared difference of both images  
  double lambda, //robust threshold
  int    type    //choice of the robust error function
)
{
  double result=0.0;
  double lambda2=lambda*lambda;
  switch(type)
  {
    case QUADRATIC:
      result=1;
      break;
    default: 
    case TRUNCATED_QUADRATIC:
      if(t2<lambda2) result=1.0;
      else result=0.0;
      break;  
    case GERMAN_MCCLURE:
      result=lambda2/((lambda2+t2)*(lambda2+t2));
      break;
    case LORENTZIAN: 
      result=1/(lambda2+t2);
      break;
    case CHARBONNIER:
      result=1.0/(sqrt(t2+lambda2));
      break;
  }
  return result;
}

 
/**
 *
 *  Function to compute DI^t*J
 *  from the gradient of the image and the Jacobian
 *
 */
void steepest_descent_images
(
  double *Ix,  //x derivate of the image
  double *Iy,  //y derivate of the image
  double *J,   //Jacobian matrix
  double *DIJ, //output DI^t*J
  int nparams, //number of parameters
  int nx,      //number of columns
  int ny,      //number of rows
  int nz       //number of channels
)
{
  int k=0;

  for(int i=0; i<ny; i++)
    for(int j=0; j<nx; j++)
      for(int c=0; c<nz; c++)
      {
        int p=i*nx+j;
        for(int n=0; n<nparams; n++) {
          DIJ[k++]=Ix[p*nz+c]*J[2*p*nparams+n]+
                   Iy[p*nz+c]*J[2*p*nparams+n+nparams];
	}
      }
}

/**
 *
 *  Function to compute the Hessian matrix
 *  the Hessian is equal to DIJ^t*DIJ
 *
 */
void hessian
(
  double *DIJ, //the steepest descent image
  double *H,   //output Hessian matrix
  int nparams, //number of parameters
  int nx,      //number of columns
  int ny,      //number of rows
  int nz       //number of channels
) 
{
  //initialize the hessian to zero
  for(int k=0; k<nparams*nparams; k++)
    H[k] = 0;
 
  //calculate the hessian in a neighbor window
  for(int i=0; i<ny; i++)
    for(int j=0; j<nx; j++)
      AtA(&(DIJ[(i*nx+j)*nz*nparams]), H, nz, nparams);
}


/**
 *
 *  Function to compute the Hessian matrix with robust error functions
 *  the Hessian is equal to rho'*DIJ^t*DIJ
 *
 */
void hessian
(
  double *DIJ, //the steepest descent image
  double *rho, //robust function
  double *H,   //output Hessian matrix
  int nparams, //number of parameters
  int nx,      //number of columns
  int ny,      //number of rows
  int nz       //number of channels
) 
{
  //initialize the hessian to zero
  for(int k=0; k<nparams*nparams; k++)
    H[k] = 0;

  //calculate the hessian in a neighbor window
  for(int i=0; i<ny; i++)
    for(int j=0; j<nx; j++)
      sAtA(rho[i*nx+j], &(DIJ[(i*nx+j)*nz*nparams]), H, nz, nparams);
}



/**
 *
 *  Function to compute the inverse of the Hessian
 *
 */
void inverse_hessian
(
  double *H,   //input Hessian
  double *H_1, //output inverse Hessian 
  int nparams  //number of parameters
) 
{
  if(inverse(H, H_1, nparams)==-1) 
    //if the matrix is not invertible, set parameters to 0
    for(int i=0; i<nparams*nparams; i++) H_1[i]=0;
}


/**
 *
 *  Function to compute I2(W(x;p))-I1(x)
 *
 */
void difference_image
(
  double *I,  //second warped image I2(x'(x;p))
  double *Iw, //first image I1(x)
  double *DI, //output difference array
  int nx,     //number of columns
  int ny,     //number of rows
  int nz      //number of channels
) 
{
  for(int i=0; i<nx*ny*nz; i++)
    DI[i]=Iw[i]-I[i];
}


/**
 *
 *  Function to store the values of p'((I2(x'(x;p))-I1(x))²)
 *
 */
void robust_error_function
(
  double *DI,   //input difference array
  double *rho,  //output robust function
  double lambda,//threshold used in the robust functions
  int    type,  //choice of robust error function
  int nx,       //number of columns
  int ny,       //number of rows
  int nz        //number of channels
) 
{
  for(int i=0;i<ny;i++)
    for(int j=0;j<nx;j++)
    {
      double norm=0.0;
      for(int c=0;c<nz;c++)
        norm+=DI[(i*nx+j)*nz+c]*DI[(i*nx+j)*nz+c];
      rho[i*nx+j]=rhop(norm,lambda,type);
    }
}


/**
 *
 *  Function to compute b=Sum(DIJ^t * DI)
 *
 */
void independent_vector
(
  double *DIJ, //the steepest descent image
  double *DI,  //I2(x'(x;p))-I1(x) 
  double *b,   //output independent vector
  int nparams, //number of parameters
  int nx,      //number of columns
  int ny,      //number of rows
  int nz       //number of channels
)
{
  //initialize the vector to zero
  for(int k=0; k<nparams; k++)
    b[k]=0;

  for(int i=0; i<ny; i++)
    for(int j=0; j<nx; j++)
    {
      Atb(
        &(DIJ[(i*nx+j)*nparams*nz]), 
        &(DI[(i*nx+j)*nz]), b, nz, nparams
      );
    }
}


/**
 *
 *  Function to compute b=Sum(rho'*DIJ^t * DI)
 *  with robust error functions
 *
 */
void independent_vector
(
  double *DIJ, //the steepest descent image
  double *DI,  //I2(x'(x;p))-I1(x) 
  double *rho, //robust function
  double *b,   //output independent vector
  int nparams, //number of parameters
  int nx,      //number of columns
  int ny,      //number of rows
  int nz       //number of channels
)
{
  //initialize the vector to zero
  for(int k=0; k<nparams; k++)
    b[k]=0;

  for(int i=0; i<ny; i++)
    for(int j=0; j<nx; j++)
    {
      sAtb(
        rho[i*nx+j], &(DIJ[(i*nx+j)*nparams*nz]), 
        &(DI[(i*nx+j)*nz]), b, nz, nparams
      );
    }
}


/**
 *
 *  Function to solve for dp
 *  
 */
double parametric_solve
(
  double *H_1, //inverse Hessian
  double *b,   //independent vector
  double *dp,  //output parameters increment 
  int nparams  //number of parameters
)
{
  double error=0.0;
  Axb(H_1, b, dp, nparams);
  for(int i=0; i<nparams; i++) error+=dp[i]*dp[i];
  return sqrt(error);
}


/**
  *
  *  Inverse compositional algorithm
  *  Quadratic version - L2 norm
  * 
  *
**/
void inverse_compositional_algorithm(
  double *I1,   //first image
  double *I2,   //second image
  double *p,    //parameters of the transform (output)
  int nparams,  //number of parameters of the transform
  int nx,       //number of columns of the image
  int ny,       //number of rows of the image
  int nz,       //number of channels of the images
  double TOL,   //Tolerance used for the convergence in the iterations
  int verbose   //enable verbose mode
)
{
  int size1=nx*ny*nz;        //size of the image with channels
  int size2=size1*nparams;   //size of the image with transform parameters
  int size3=nparams*nparams; //size for the Hessian
  int size4=2*nx*ny*nparams; 
  
  double *Ix =new double[size1];   //x derivate of the first image
  double *Iy =new double[size1];   //y derivate of the first image
  double *Iw =new double[size1];   //warp of the second image/
  double *DI =new double[size1];   //error image (I2(w)-I1)
  double *DIJ=new double[size2];   //steepest descent images
  double *dp =new double[nparams]; //incremental solution
  double *b  =new double[nparams]; //steepest descent images
  double *J  =new double[size4];   //jacobian matrix for all points
  double *H  =new double[size3];   //Hessian matrix
  double *H_1=new double[size3];   //inverse Hessian matrix

   
  //Evaluate the gradient of I1
  gradient(I1, Ix, Iy, nx, ny, nz);
  
  //Evaluate the Jacobian
  jacobian(J, nparams, nx, ny);

  //Compute the steepest descent images
  steepest_descent_images(Ix, Iy, J, DIJ, nparams, nx, ny, nz);

  //Compute the Hessian matrix
  hessian(DIJ, H, nparams, nx, ny, nz);
  inverse_hessian(H, H_1, nparams);

  //Iterate
  double error=1E10;
  int niter=0;
  
  do{     
    //Warp image I2
    bicubic_interpolation(I2, Iw, p, nparams, nx, ny, nz);

    //Compute the error image (I1-I2w)
    difference_image(I1, Iw, DI, nx, ny, nz);

    //Compute the independent vector
    independent_vector(DIJ, DI, b, nparams, nx, ny, nz);

    //Solve equation and compute increment of the motion 
    error=parametric_solve(H_1, b, dp, nparams);

    //Update the warp x'(x;p) := x'(x;p) * x'(x;dp)^-1
    update_transform(p, dp, nparams);

    if(verbose)
    {
      printf("|Dp|=%f: p=(",error);
      for(int i=0;i<nparams-1;i++)
        printf("%f ",p[i]);
      printf("%f)\n",p[nparams-1]);
    }
    niter++;    
  }
  while(error>TOL && niter<MAX_ITER);
  
  //delete allocated memory
  delete []DI;
  delete []Ix;
  delete []Iy;
  delete []Iw;
  delete []DIJ;
  delete []dp;
  delete []b;
  delete []J;
  delete []H;
  delete []H_1;
}



/**
  *
  *  Inverse compositional algorithm 
  *  Version with robust error functions
  * 
**/
void robust_inverse_compositional_algorithm(
  double *I1,    //first image
  double *I2,    //second image
  double *p,     //parameters of the transform (output)
  int nparams,   //number of parameters of the transform
  int nx,        //number of columns of the image
  int ny,        //number of rows of the image
  int nz,        //number of channels of the images
  double TOL,    //Tolerance used for the convergence in the iterations
  int    robust, //robust error function
  double lambda, //parameter of robust error function
  int verbose    //enable verbose mode
)
{
  int size0=nx*ny;           //size of the image 
  int size1=nx*ny*nz;        //size of the image with channels
  int size2=size1*nparams;   //size of the image with transform parameters
  int size3=nparams*nparams; //size for the Hessian
  int size4=2*nx*ny*nparams; 
  
  double *Ix =new double[size1];   //x derivate of the first image
  double *Iy =new double[size1];   //y derivate of the first image
  double *Iw =new double[size1];   //warp of the second image/
  double *DI =new double[size1];   //error image (I2(w)-I1)
  double *DIJ=new double[size2];   //steepest descent images
  double *dp =new double[nparams]; //incremental solution
  double *b  =new double[nparams]; //steepest descent images
  double *J  =new double[size4];   //jacobian matrix for all points
  double *H  =new double[size3];   //Hessian matrix
  double *H_1=new double[size3];   //inverse Hessian matrix
  double *rho=new double[size0];   //robust function
   
  //Evaluate the gradient of I1
  gradient(I1, Ix, Iy, nx, ny, nz);
  
  //Evaluate the Jacobian
  jacobian(J, nparams, nx, ny);

  //Compute the steepest descent images
  steepest_descent_images(Ix, Iy, J, DIJ, nparams, nx, ny, nz);
  
  //Iterate
  double error=1E10;
  int niter=0;
  double lambda_it;
  
  if(lambda>0) lambda_it=lambda;
  else lambda_it=LAMBDA_0;
  
  do{     
    //Warp image I2
    bicubic_interpolation(I2, Iw, p, nparams, nx, ny, nz);

    //Compute the error image (I1-I2w)
    difference_image(I1, Iw, DI, nx, ny, nz);

    //compute robustifiction function
    robust_error_function(DI, rho, lambda_it, robust, nx, ny, nz);
    if(lambda<=0 && lambda_it>LAMBDA_N) 
    {
      lambda_it*=LAMBDA_RATIO;
      if(lambda_it<LAMBDA_N) lambda_it=LAMBDA_N;
    }

    //Compute the independent vector
    independent_vector(DIJ, DI, rho, b, nparams, nx, ny, nz);

    //Compute the Hessian matrix
    hessian(DIJ, rho, H, nparams, nx, ny, nz);
    inverse_hessian(H, H_1, nparams);

    //Solve equation and compute increment of the motion 
    error=parametric_solve(H_1, b, dp, nparams);

    //Update the warp x'(x;p) := x'(x;p) * x'(x;dp)^-1
    update_transform(p, dp, nparams);

    if(verbose) 
    {
      printf("|Dp|=%f: p=(",error);
      for(int i=0;i<nparams-1;i++)
        printf("%f ",p[i]);
      printf("%f), lambda=%f\n",p[nparams-1],lambda_it);
    }
    niter++;    
  }
  while(error>TOL && niter<MAX_ITER);
  
  //delete allocated memory
  delete []DI;
  delete []Ix;
  delete []Iy;
  delete []Iw;
  delete []DIJ;
  delete []dp;
  delete []b;
  delete []J;
  delete []H;
  delete []H_1;
  delete []rho;
}


/**
  *
  *  Multiscale approach for computing the optical flow
  *
**/
void pyramidal_inverse_compositional_algorithm(
    double *I1,     //first image
    double *I2,     //second image
    double *p,      //parameters of the transform
    int    nparams, //number of parameters
    int    nxx,     //image width
    int    nyy,     //image height
    int    nzz,     //number of color channels in image  
    int    nscales, //number of scales
    double nu,      //downsampling factor
    double TOL,     //stopping criterion threshold
    int    robust,  //robust error function
    double lambda,  //parameter of robust error function
    bool   verbose  //switch on messages
)
{
    int size=nxx*nyy*nzz;

    double **I1s=new double*[nscales];
    double **I2s=new double*[nscales];
    double **ps =new double*[nscales];

    int *nx=new int[nscales];
    int *ny=new int[nscales];

    I1s[0]=new double[size];
    I2s[0]=new double[size];

    //copy the input images
    for(int i=0;i<size;i++)
    {
      I1s[0][i]=I1[i];
      I2s[0][i]=I2[i];
    }

    ps[0]=p;
    nx[0]=nxx;
    ny[0]=nyy;

    //initialization of the transformation parameters at the finest scale
    for(int i=0; i<nparams; i++)
      p[i]=0.0;

    //create the scales
    for(int s=1; s<nscales; s++)
    {
      zoom_size(nx[s-1], ny[s-1], nx[s], ny[s], nu);

      const int size=nx[s]*ny[s];

      I1s[s]=new double[size*nzz];
      I2s[s]=new double[size*nzz];
      ps[s] =new double[nparams];
      
      for(int i=0; i<nparams; i++)
        ps[s][i]=0.0;

      //zoom the images from the previous scale
      zoom_out(I1s[s-1], I1s[s], nx[s-1], ny[s-1], nzz, nu);
      zoom_out(I2s[s-1], I2s[s], nx[s-1], ny[s-1], nzz, nu);
    }  

    //pyramidal approach for computing the transformation
    for(int s=nscales-1; s>=0; s--)
    {
      if(verbose) printf("Scale: %d ",s);

      //incremental refinement for this scale
      if(robust==QUADRATIC)
      {
        if(verbose) printf("(L2 norm)\n");

        inverse_compositional_algorithm(
          I1s[s], I2s[s], ps[s], nparams, nx[s], 
          ny[s], nzz, TOL, verbose
        );
      }
      else
      {
        if(verbose) printf("(Robust error function %d)\n",robust);

        robust_inverse_compositional_algorithm(
          I1s[s], I2s[s], ps[s], nparams, nx[s], 
          ny[s], nzz, TOL, robust, lambda,verbose
        );
      }

      //if it is not the finer scale, then upsample the parameters
      if(s) 
        zoom_in_parameters(
          ps[s], ps[s-1], nparams, nx[s], ny[s], nx[s-1], ny[s-1]
        );
    }

    //delete allocated memory
    delete []I1s[0];
    delete []I2s[0];
    for(int i=1; i<nscales; i++)
    {
      delete []I1s[i];
      delete []I2s[i];
      delete []ps [i];
    }
    delete []I1s;
    delete []I2s;
    delete []ps;
    delete []nx;
    delete []ny;
}
