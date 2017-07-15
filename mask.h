// This program is free software: you can use, modify and/or redistribute it
// under the terms of the simplified BSD License. You should have received a
// copy of this license along this program. If not, see
// <http://www.opensource.org/licenses/bsd-license.html>.
//
// Copyright (C) 2015, Javier Sánchez Pérez <jsanchez@ulpgc.es>
// Copyright (C) 2014, Nelson Monzón López  <nmonzon@ctim.es>
// All rights reserved.

#ifndef MASK_H
#define MASK_H

/**
 *
 * Function to apply a 3x3 mask to an image
 *
 */
void mask3x3(
  double *input,  //input image
  double *output, //output image
  int nx,         //image width
  int ny,         //image height
  int nz,         //number of color channels in the image 
  double *mask    //mask to be applied
);


/**
 *
 * Compute the gradient with central differences
 *
 */
void gradient(
  double *input,  //input image
  double *dx,     //computed x derivative
  double *dy,     //computed y derivative
  int nx,         //image width
  int ny,         //image height
  int nz          //number of color channels in the image 
);


/**
 *
 * Convolution with a Gaussian
 *
 */
void
gaussian (
  double *I,        //input/output image
  int xdim,         //image width
  int ydim,         //image height
  int zdim,         //number of color channels in the image
  double sigma,     //Gaussian sigma
  int bc = 1,       //boundary condition
  int precision = 5 //defines the size of the window
);

#endif
