// This program is free software: you can use, modify and/or redistribute it
// under the terms of the simplified BSD License. You should have received a
// copy of this license along this program. If not, see
// <http://www.opensource.org/licenses/bsd-license.html>.
//
// Copyright (C) 2015, Javier Sánchez Pérez <jsanchez@dis.ulpgc.es>
// All rights reserved.

#include <time.h> 
#include <string.h>
#include <stdlib.h>
#include <stdio.h> 
#include <math.h>
#include <algorithm>

#include "inverse_compositional_algorithm.h"
#include "file.h"

#define PAR_DEFAULT_NSCALES 5
#define PAR_DEFAULT_ZFACTOR 0.5
#define PAR_DEFAULT_TOL 0.001
#define PAR_DEFAULT_TYPE 8
#define PAR_DEFAULT_ROBUST 3
#define PAR_DEFAULT_LAMBDA 0.0
#define PAR_DEFAULT_VERBOSE 0
#define PAR_DEFAULT_OUTFILE "transform.mat"

/**
 *
 *  Print a help message 
 *
 */
void print_help(char *name) 
{
  printf("\n<Usage>: %s image1 image2 [OPTIONS] \n\n", name);
  printf("This program calculates the transformation between two images.\n");
  printf("It implements the inverse compositional algorithm. \n");
  printf("More information in http://www.ipol.im \n\n");
  printf("OPTIONS:\n");
  printf("--------\n");
  printf(" -f name \t Name of the output filename that will contain the\n");
  printf("         \t   computed transformation\n");
  printf("         \t   Default value %s\n", PAR_DEFAULT_OUTFILE);
  printf(" -n N    \t Number of scales for the coarse-to-fine scheme\n");
  printf("         \t   Default value %d\n", PAR_DEFAULT_NSCALES);
  printf(" -z F    \t Zoom factor used in the coarse-to-fine scheme \n");
  printf("         \t   Values must be in the range (0,1)\n"); 
  printf("         \t   Default value %0.2f\n", 
                        PAR_DEFAULT_ZFACTOR);
  printf(" -e F    \t Threshold for the convergence criterion \n");
  printf("         \t   Default value %0.4f\n", PAR_DEFAULT_TOL);
  printf(" -t N    \t Transformation type to be computed:\n");
  printf("         \t   2-traslation; 3-Euclidean transform; 4-similarity\n");
  printf("         \t   6-affinity; 8-homography\n"); 
  printf("         \t   Default value %d\n", 
                        PAR_DEFAULT_TYPE);
  printf(" -r N    \t Use robust error functions: \n");
  printf("         \t   0-Non robust (L2 norm); 1-truncated quadratic\n"); 
  printf("         \t   2-German & McLure; 3-Lorentzian 4-Charbonnier \n");
  printf("         \t   Default value %d\n", 
                        PAR_DEFAULT_ROBUST);
  printf(" -l F    \t Value of the parameter for the robust error function\n");
  printf("         \t   A value <=0 if it is automatically computed\n");
  printf("         \t   Default value %0.0f\n", PAR_DEFAULT_LAMBDA);
  printf(" -v      \t Switch on verbose mode. \n\n\n");
}


/**
 *
 *  Read command line parameters 
 *
 */
int read_parameters(
    int    argc, 
    char   *argv[], 
    char   **image1,
    char   **image2,
    char   *outfile,
    int    &nscales,
    double &zfactor,
    double &TOL,
    int    &nparams,
    int    &robust,
    double &lambda,
    int    &verbose
)
{
  if (argc < 3){
    print_help(argv[0]); 
    return 0;
  }
  else{
    int i=1;
    *image1=argv[i++];
    *image2=argv[i++];      

    //assign default values to the parameters
    strcpy(outfile,PAR_DEFAULT_OUTFILE);
    nscales=PAR_DEFAULT_NSCALES;
    zfactor=PAR_DEFAULT_ZFACTOR;
    TOL    =PAR_DEFAULT_TOL;
    nparams=PAR_DEFAULT_TYPE; 
    robust =PAR_DEFAULT_ROBUST; 
    lambda =PAR_DEFAULT_LAMBDA; 
    verbose=PAR_DEFAULT_VERBOSE; 

    //read each parameter from the command line
    while(i<argc)
    {
      if(strcmp(argv[i],"-f")==0)
        if(i<argc-1)
          strcpy(outfile,argv[++i]);
      
      if(strcmp(argv[i],"-n")==0)
        if(i<argc-1)
          nscales=atoi(argv[++i]);

      if(strcmp(argv[i],"-z")==0)
        if(i<argc-1)
          zfactor=atof(argv[++i]);

      if(strcmp(argv[i],"-e")==0)
        if(i<argc-1)
          TOL=atof(argv[++i]);

      if(strcmp(argv[i],"-t")==0)
        if(i<argc-1)
          nparams=atoi(argv[++i]);
        
      if(strcmp(argv[i],"-r")==0)
        if(i<argc-1)
          robust=atoi(argv[++i]);

      if(strcmp(argv[i],"-l")==0)
        if(i<argc-1)
          lambda=atof(argv[++i]);

      if(strcmp(argv[i],"-v")==0)
        verbose=1;
      
      i++;
    }
    
    //check parameter values
    if(nscales <= 0)           nscales=PAR_DEFAULT_NSCALES;
    if(zfactor<=0||zfactor>=1) zfactor=PAR_DEFAULT_ZFACTOR;
    if(TOL<0)                  TOL    =PAR_DEFAULT_TOL;
    if(nparams!=2 && nparams!=3 && nparams!=4 && 
     nparams!=6 && nparams!=8) nparams=PAR_DEFAULT_TYPE;
    if(robust<0||robust>4)     robust =PAR_DEFAULT_ROBUST;
    if(lambda<0)               lambda =PAR_DEFAULT_LAMBDA;
  }

  return 1;
}


/**
 *
 *  Main program:
 *   This program reads the following parameters from the console and
 *   computes the corresponding parametric transformation:
 *   -I1          first image
 *   -I2          second image
 *   -out_file    name of the output flow field
 *   -nscales     number of scales for the pyramidal approach
 *   -zoom_factor reduction factor for creating the scales
 *   -TOL         stopping criterion threshold for the iterative process
 *   -robust      type of the robust error function 
 *   -lambda      parameter of the robust error function
 *   -type        type of the parametric model (the number of parameters):
 *                Translation(2), Euclidean(3), Similarity(4), Affinity(6), 
 *                Homography(8)
 *   -verbose     switch on/off messages
 *
 */
int main (int argc, char *argv[])
{
  //parameters of the method
  char  *image1, *image2, outfile[200];
  int    nscales, nparams, robust, verbose;
  double zfactor, TOL, lambda;

  //read the parameters from the console
  int result=read_parameters(
        argc, argv, &image1, &image2, outfile, nscales, 
        zfactor, TOL, nparams, robust, lambda, verbose
      );
  
  if(result)
  {
    int nx, ny, nz, nx1, ny1, nz1;

    double *I1, *I2;

    //read the input images
    bool correct1=read_image(image1, &I1, nx, ny, nz);
    bool correct2=read_image(image2, &I2, nx1, ny1, nz1);

    // if the images are correct, compute the optical flow
    if (correct1 && correct2 && nx == nx1 && ny == ny1 && nz == nz1)
    {
      if(verbose) 
        printf(
          "\nParameters: scales=%d, zoom=%f, TOL=%f, transform type=%d, "
          "robust function=%d, lambda=%f, output file=%s\n",
          nscales, zfactor, TOL, nparams, robust, lambda, outfile
        );

      //limit the number of scales according to image size (min 32x32)
      const double N=1+log(std::min(nx, ny)/32.)/log(1./zfactor);
      if ((int) N<nscales) nscales=(int) N;

      //allocate memory for the parametric model
      double *p=new double[nparams];

      //compute the optic flow
      const clock_t begin = clock();
      pyramidal_inverse_compositional_algorithm(
        I1, I2, p, nparams, nx, ny, nz, 
        nscales, zfactor, TOL, robust, lambda, verbose
      );
      
      if(verbose) 
        printf("Time=%f\n", double(clock()-begin)/CLOCKS_PER_SEC);
      
      //save the parametric model to disk
      save(outfile, p, nparams);

      //free memory
      free (I1);
      free (I2);
      delete[]p;          
    }
    else 
    {
      printf("Cannot read the images or their sizes are not the same\n");
      exit(EXIT_FAILURE);
    }
      
  }
  exit(EXIT_SUCCESS);
}
