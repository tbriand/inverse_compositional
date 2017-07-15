// This program is free software: you can use, modify and/or redistribute it
// under the terms of the simplified BSD License. You should have received a
// copy of this license along this program. If not, see
// <http://www.opensource.org/licenses/bsd-license.html>.
//
// Copyright (C) 2015, Javier Sánchez Pérez <jsanchez@dis.ulpgc.es>
// All rights reserved.

#include <math.h>
#include <stdio.h>
#include <stdlib.h>

#include "bicubic_interpolation.h"
#include "file.h"
#include "inverse_compositional_algorithm.h"
#include "transformation.h"


/*********************************************************************
 * NOTE:                                                             *
 * This file generates some information for the online demo in IPOL  *
 * It can be removed for using the program outside the demo system   *              
 *                                                                   *
 *********************************************************************/
 

/**
 *
 *  Function to project a point with two transformations and
 *  compute the distance between them
 *
 */
double distance(
  double *m1, //first transformation
  double *m2, //second transformation
  double x,   //x point coordinate
  double y    //y point coordinate
)
{
  double x1=99999,y1=99999,z1=m1[6]*x+m1[7]*y+1;
  double x2=99999,y2=99999,z2=m2[6]*x+m2[7]*y+1;
  if(z1*z1>1E-10 && z2*z2>1E-10)
  {
    x1=(m1[0]*x+m1[1]*y+m1[2])/z1;
    y1=(m1[3]*x+m1[4]*y+m1[5])/z1;
    x2=(m2[0]*x+m2[1]*y+m2[2])/z2;
    y2=(m2[3]*x+m2[4]*y+m2[5])/z2;
  }
  double d=(x1-x2)*(x1-x2)+(y1-y2)*(y1-y2);
  return sqrt(d);
}


/**
 *
 *  Function to write some output information for the demo
 *
 */
void print_output(
  double *I1,  //first image
  double *I2,  //second image
  double *p,   //parametric model
  double *p2,  //parametric model
  int nparams, //number of parameters
  int nparams2,//number of parameters
  int type,    //type of robust error function
  double lamb, //parameter of robust error function
  int nx,      //number of columns
  int ny,      //number of rows
  int nz       //number of channels
)
{
  double *Iw=new double[nx*ny*nz];
  double *rho1=new double[nx*ny];
  double *rho2=new double[nx*ny];
  bicubic_interpolation(I2, Iw, p, nparams, nx, ny, nz);
  char outfile[50]="output.png";
  save_image(outfile,Iw,nx,ny,nz);

  //computing the RMSE, |I2(x')-I1(x)| and p(|I2(x')-I1(x)|^2)
  double sum=0.0,max=-1,min=99999;
  int size=0;
  for(int i=0;i<ny;i++)
    for(int j=0;j<nx;j++)
    {
      double norm=0;
      int fail=0;
      for(int k=0;k<nz;k++)
        if(Iw[(i*nx+j)*nz+k]*Iw[(i*nx+j)*nz+k]<1E10)
          norm+=(Iw[(i*nx+j)*nz+k]-I1[(i*nx+j)*nz+k])*
                (Iw[(i*nx+j)*nz+k]-I1[(i*nx+j)*nz+k]);
        else fail=1;
      if(!fail)
      {
        Iw[i*nx+j]=sqrt(norm);
        rho2[i*nx+j]=255*rhop(norm,LAMBDA_N,type);
        if(lamb>0)
          rho1[i*nx+j]=255*rhop(norm,lamb,type);
        else
          rho1[i*nx+j]=255*rhop(norm,LAMBDA_0,type);

        max=(Iw[i*nx+j]>max)?Iw[i*nx+j]:max;
        min=(Iw[i*nx+j]<min)?Iw[i*nx+j]:min;
        size++;
        sum+=norm/nz;
      }
      else 
        Iw[i*nx+j]=rho1[i*nx+j]=rho2[i*nx+j]=0;
    }
  if(max>min)
    for(int i=0;i<nx*ny;i++) Iw[i]=255*(Iw[i]-min)/(max-min);
  char L2file[50]="L2image.png";
  save_image(L2file,Iw,nx,ny,1);
  char rhofile1[50]="weights1.png";
  save_normalize_image(rhofile1,rho1,nx,ny);
  char rhofile2[50]="weights2.png";
  save_normalize_image(rhofile2,rho2,nx,ny);
  double RMSE;
  if(size>0) RMSE=sqrt(sum/size);
  else RMSE=9999;
  printf("RMSE=%f\n",RMSE);

  //computing error d(Hx,H'x)
  double m1[9], m2[9];
  params2matrix(p, m1, nparams);
  if(p2!=NULL)
  {
    params2matrix(p2, m2, nparams2);
    double e1=distance(m1, m2, 0, 0);
    double e2=distance(m1, m2, nx,0);
    double e3=distance(m1, m2, 0, ny);
    double e4=distance(m1, m2, nx,ny);
    double error=(e1+e2+e3+e4)/4;
    printf("d(Hx,H'x)=%f\n",error);
  }
  else printf("d(Hx,H'x)=-N/A-\n");
  
  //writing matrices
  printf("Computed Matrix=%f %f %f %f %f %f %f %f %f\n", 
         m1[0],m1[1],m1[2],m1[3],m1[4],m1[5],m1[6],m1[7],m1[8]);
  if(p2!=NULL)
    printf("Original Matrix=%f %f %f %f %f %f %f %f %f\n", 
           m2[0],m2[1],m2[2],m2[3],m2[4],m2[5],m2[6],m2[7],m2[8]);
  else
    printf("Original Matrix=- - - - - - - - -\n");
  
  delete []Iw;
  delete []rho1;
  delete []rho2;
}


int main(int argc, char *argv[])
{
  if(argc==7)
  {
    int nx, ny, nz, nx1, ny1, nz1;

    char  *image1=argv[1];
    char  *image2=argv[2];
    char  *transform1=argv[3];
    char  *transform2=argv[4];
    int    robust=atoi(argv[5]);
    double lambda=atoi(argv[6]);
    
    //read the input images
    double *I1, *I2;
    bool correct1=read_image(image1, &I1, nx, ny, nz);
    bool correct2=read_image(image2, &I2, nx1, ny1, nz1);
    
    if (correct1 && correct2 && nx == nx1 && ny == ny1 && nz == nz1)
    {
      int n1,n2;
      double *p1=NULL, *p2=NULL;
      read(transform1, &p1, n1);
      read(transform2, &p2, n2);

      print_output(I1, I2, p1, p2, n1, n2, robust, lambda, nx, ny, nz);

      //free memory
      free (I1);
      free (I2);
      delete []p1;
      delete []p2;
    }
  }
}

