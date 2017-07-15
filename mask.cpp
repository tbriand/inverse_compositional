// This program is free software: you can use, modify and/or redistribute it
// under the terms of the simplified BSD License. You should have received a
// copy of this license along this program. If not, see
// <http://www.opensource.org/licenses/bsd-license.html>.
//
// Copyright (C) 2015, Javier Sánchez Pérez <jsanchez@ulpgc.es>
// Copyright (C) 2014, Nelson Monzón López  <nmonzon@ctim.es>
// All rights reserved.

#include "mask.h"

#include <math.h>
#include <stdio.h>


/**
 *
 * Function to apply a 3x3 mask to an image
 *
 */
void
mask3x3 (double *input,         //input image
         double *output,        //output image
         int nx,                //image width
         int ny,                //image height
         int nz,                // number of color channels in the image 
         double *mask           //mask to be applied
  )
{
  int nx_rgb = nx * nz;

  for (int index_color = 0; index_color < nz; index_color++)
    {
      //apply the mask to the center body of the image
      for (int i = 1; i < ny - 1; i++)
        {
          for (int j = 1; j < nx - 1; j++)
            {
              int k = (i * nx + j) * nz + index_color;
              double sum = 0;
              for (int l = 0; l < 3; l++)
                {
                  for (int m = 0; m < 3; m++)
                    {
                      int p =
                        ((i + l - 1) * nx + j + m - 1) * nz + index_color;
                      sum += input[p] * mask[l * 3 + m];
                    }
                }
              output[k] = sum;
            }
        }

      //apply the mask to the first and last rows
      for (int j = 1; j < nx - 1; j++)
        {
          int index = j * nz + index_color;
          double sum = 0;

          sum += input[index - nz] * (mask[0] + mask[3]);
          sum += input[index] * (mask[1] + mask[4]);
          sum += input[index + nz] * (mask[2] + mask[5]);

          sum += input[nx_rgb + j - nz] * mask[6];
          sum += input[nx_rgb + j] * mask[7];
          sum += input[nx_rgb + j + nz] * mask[8];

          output[j] = sum;

          index = ((ny - 2) * nx + j) * nz + index_color;

          sum = 0;
          sum += input[index - nz] * mask[0];
          sum += input[index] * mask[1];
          sum += input[index + nz] * mask[2];

          index = ((ny - 1) * nx + j) * nz + index_color;

          sum += input[index - nz] * (mask[6] + mask[3]);
          sum += input[index] * (mask[7] + mask[4]);
          sum += input[index + 1] * (mask[8] + mask[5]);

          output[index] = sum;
        }

      //apply the mask to the first and last columns
      for (int i = 1; i < ny - 1; i++)
        {
          int index = i * nx_rgb + index_color;

          double sum = 0;

          int index_row = (i - 1) * nx_rgb + index_color;

          sum += input[index_row] * (mask[0] + mask[1]);
          sum += input[index_row + nz] * mask[2];

          sum += input[index] * (mask[3] + mask[4]);
          sum += input[index + nz] * mask[5];

          index_row = (i + 1) * nx_rgb + index_color;

          sum += input[index_row] * (mask[6] + mask[7]);
          sum += input[index_row + nz] * mask[8];

          output[index] = sum;

          sum = 0;
          sum += input[index - 2 * nz] * mask[0];
          sum += input[index - nz] * (mask[1] + mask[2]);

          index_row = (i + 1) * nx_rgb + index_color;

          sum += input[index_row - 2 * nz] * mask[3];
          sum += input[index_row - nz] * (mask[4] + mask[5]);

          index_row = (i + 2) * nx_rgb + index_color;

          sum += input[index_row - 2 * nz] * mask[6];
          sum += input[index_row - nz] * (mask[7] + mask[8]);

          output[(i * nx + nx - 1) * nz + index_color] = sum;

        }

      //apply the mask to the four corners
      output[index_color] =
        input[index_color] * (mask[0] + mask[1] + mask[3] + mask[4]) +
        input[index_color + nz] * (mask[2] + mask[5]) +
        input[nx_rgb + index_color] * (mask[6] + mask[7]) +
        input[nx_rgb + index_color + nz] * mask[8];

      output[nx_rgb - nz + index_color] =
        input[(nx - 2) * nz + index_color] * (mask[0] + mask[3]) +
        input[(nx - 1) * nz + index_color] * (mask[1] + mask[2] + mask[4] +
                                              mask[5]) + input[(2 * nx -
                                                                2) * nz +
                                                               index_color] *
        mask[6] + input[(2 * nx - 1) * nz + index_color] * (mask[7] +
                                                            mask[8]);

      output[(ny - 1) * nx_rgb + index_color] =
        input[(ny - 2) * nx_rgb + index_color] * (mask[0] + mask[1]) +
        input[((ny - 2) * nx + 1) * nz + index_color] * mask[2] +
        input[(ny - 1) * nx_rgb + index_color] * (mask[3] + mask[4] +
                                                  mask[6] + mask[7]) +
        input[((ny - 1) * nx + 1) * nz + index_color] * (mask[5] + mask[8]);

      output[(ny * nx - 1) * nz + index_color] =
        input[((ny - 1) * nx - 2) * nz + index_color] * mask[0] +
        input[((ny - 1) * nx - 1) * nz + index_color] * (mask[1] + mask[2]) +
        input[(ny * nx - 2) * nz + index_color] * (mask[3] + mask[6]) +
        input[(ny * nx - 1) * nz + index_color] * (mask[4] + mask[5] +
                                                   mask[7] + mask[8]);
    }// end loop for channels information
}// end mask3x3


/**
 *
 * Compute the gradient with central differences
 *
 */
void
gradient (double *input,        //input image
          double *dx,           //computed x derivative
          double *dy,           //computed y derivative
          int nx,               //image width
          int ny,               //image height
          int nz                //number of color channels in the image 
  )
{
  int nx_rgb = nx * nz;

  for (int index_color = 0; index_color < nz; index_color++)
    {
      //gradient in the center body of the image
      for (int i = 1; i < ny - 1; i++)
        {
          for (int j = 1; j < nx - 1; j++)
            {
              int k = (i * nx + j) * nz + index_color;

              dx[k] = 0.5 * (input[k + nz] - input[k - nz]);
              dy[k] = 0.5 * (input[k + nx_rgb] - input[k - nx_rgb]);
            }
        }

      //gradient in the first and last rows
      for (int j = 1; j < nx - 1; j++)
        {

          int index = j * nz + index_color;

          dx[index] = 0.5 * (input[index + nz] - input[index - nz]);
          dy[index] = 0.5 * (input[index + nx_rgb] - input[index]);

          int k = ((ny - 1) * nx + j) * nz + index_color;

          dx[k] = 0.5 * (input[k + nz] - input[k - nz]);
          dy[k] = 0.5 * (input[k] - input[k - nx_rgb]);
        }

      //gradient in the first and last columns
      for (int i = 1; i < ny - 1; i++)
        {

          int p = (i * nx_rgb) + index_color;

          dx[p] = 0.5 * (input[p + nz] - input[p]);
          dy[p] = 0.5 * (input[p + nx_rgb] - input[p - nx_rgb]);

          int k = ((i + 1) * nx - 1) * nz + index_color;

          dx[k] = 0.5 * (input[k] - input[k - nz]);
          dy[k] = 0.5 * (input[k + nx_rgb] - input[k - nx_rgb]);
        }

      //calculate the gradient in the corners
      dx[index_color] = 0.5 * (input[index_color + nz] - input[index_color]);
      dy[index_color] =
        0.5 * (input[nx_rgb + index_color] - input[index_color]);

      int corner_up_right = (nx - 1) * nz + index_color;

      dx[corner_up_right] =
        0.5 * (input[corner_up_right] - input[corner_up_right - nz]);
      dy[corner_up_right] =
        0.5 * (input[(2 * nx_rgb) + index_color - nz] -
               input[corner_up_right]);

      int corner_down_left = ((ny - 1) * nx) * nz + index_color;

      dx[corner_down_left] =
        0.5 * (input[corner_down_left + nz] - input[corner_down_left]);
      dy[corner_down_left] =
        0.5 * (input[corner_down_left] -
               input[(ny - 2) * nx_rgb + index_color]);

      int corner_down_right = ny * nx_rgb - nz + index_color;

      dx[corner_down_right] =
        0.5 * (input[corner_down_right] - input[corner_down_right - nz]);
      dy[corner_down_right] =
        0.5 * (input[corner_down_right] -
               input[(ny - 1) * nx_rgb - nz + index_color]);
    }
}


/**
 *
 * Convolution with a Gaussian
 *
 */
void
gaussian (
  double *I,    //input/output image
  int xdim,     //image width
  int ydim,     //image height
  int zdim,     //number of color channels in the image
  double sigma, //Gaussian sigma
  int bc,       //boundary condition
  int precision //defines the size of the window
)
{
  int i, j, k;
  
  double den = 2 * sigma * sigma;
  int size = (int) (precision * sigma) + 1;
  int bdx = xdim + size;
  int bdy = ydim + size;
  
  if (bc && size > xdim){
      printf("GaussianSmooth: sigma too large for this bc\n");
      throw 1;
  }

  //compute the coefficients of the 1D convolution kernel
  double *B = new double[size];
  for (int i = 0; i < size; i++)
    B[i] = 1 / (sigma * sqrt (2.0 * 3.1415926)) * exp (-i * i / den);

  double norm = 0;

  //normalize the 1D convolution kernel
  for (int i = 0; i < size; i++)
    norm += B[i];

  norm *= 2;
  norm -= B[0];

  for (int i = 0; i < size; i++)
    B[i] /= norm;
  
  double *R = new double[size + xdim + size]; 
  double *T = new double[size + ydim + size];
  
  //Loop for every channel
  for(int index_color = 0; index_color < zdim; index_color++){
  
  //convolution of each line of the input image
   for (k = 0; k < ydim; k++)
    {
      for (i = size; i < bdx; i++) 
        R[i] = I[(k * xdim + i - size) * zdim + index_color];
      switch (bc)
        {
        case 0: //Dirichlet boundary conditions

          for (i = 0, j = bdx; i < size; i++, j++)
            R[i] = R[j] = 0;
          break;
        case 1: //Reflecting boundary conditions
          for (i = 0, j = bdx; i < size; i++, j++)
            {
              R[i] = I[(k * xdim + size - i ) * zdim + index_color];
              R[j] = I[(k * xdim + xdim - i - 1) * zdim + index_color ];
            }
          break;
        case 2: //Periodic boundary conditions
          for (i = 0, j = bdx; i < size; i++, j++)
            {
              R[i] = I[(k * xdim + xdim - size + i) * zdim + index_color];
              R[j] = I[(k * xdim + i) * zdim + index_color];
            }
          break;
        }

      for (i = size; i < bdx; i++)
        {

          double sum = B[0] * R[i];

          for (int j = 1; j < size; j++)
            sum += B[j] * (R[i - j] + R[i + j]);

          I[(k * xdim + i - size) * zdim + index_color] = sum;
          
        }
    }

  //convolution of each column of the input image
  for (k = 0; k < xdim; k++)
    {
      for (i = size; i < bdy; i++)
        T[i] = I[((i - size) * xdim + k) * zdim + index_color];

      switch (bc)
        {
        case 0: // Dirichlet boundary conditions
          for (i = 0, j = bdy; i < size; i++, j++)
            T[i] = T[j] = 0;
          break;
        case 1: // Reflecting boundary conditions
          for (i = 0, j = bdy; i < size; i++, j++)
            {
              T[i] = I[((size - i) * xdim + k) * zdim + index_color];
              T[j] = I[((ydim - i - 1) * xdim + k) * zdim + index_color];
            }
          break;
        case 2: // Periodic boundary conditions
          for (i = 0, j = bdx; i < size; i++, j++)
            {
              T[i] = I[((ydim - size + i) * xdim + k) * zdim + index_color];
              T[j] = I[(i * xdim + k) * zdim + index_color];
            }
          break;
        }

      for (i = size; i < bdy; i++)
        {
          double sum = B[0] * T[i];

          for (j = 1; j < size; j++)
            sum += B[j] * (T[i - j] + T[i + j]);

          I[((i - size) * xdim + k) * zdim + index_color] = sum;
        }
    }
  }
  
  delete[]B;
  delete[]R;
  delete[]T;
}
