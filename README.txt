The Inverse Compositional Algorithm for Parametric Motion Estimation
--------------------------------------------------------------------

*******
SUMMARY
*******

This program implements the inverse compositional algorithm for parametric
motion estimation. It computes a planar transformation between two images, 
including translations, similarities, affinities and homographies. It 
computes large displacements through a pyramidal scheme and uses robust 
functionals to deal with noise and occlusions.

Reference articles:

[1] S. Baker and I. Matthews, Lucas-kanade 20 years on: A unifying framework, 
International journal of computer vision, 56 (2004), pp. 221-255.

[2] S. Baker, R. Gross, I. Matthews, and T. Ishikawa, Lucas-kanade 20 years 
on: A unifying framework: Part 2, Tech. Report CMU-RI-TR-03-01, Robotics 
Institute, Pittsburgh, PA, February 2003.

This program is part of an IPOL publication:
http://www.ipol.im/


******
AUTHOR
******

Javier Sánchez Pérez <jsanchez@dis.ulpgc.es> 
Centro de Tecnologías de la Imagen (CTIM) 
Universidad de Las Palmas de Gran Canaria


*******
VERSION
*******

Version 1, released on October 9, 2015


*******
LICENSE
*******

This program is free software: you can use, modify and/or redistribute it
under the terms of the simplified BSD License. You should have received a
copy of this license along this program. If not, see
<http://www.opensource.org/licenses/bsd-license.html>.

Copyright (C) 2015, Javier Sánchez Pérez <jsanchez@dis.ulpgc.es>
All rights reserved.


***********
COMPILATION
***********

Required environment: Any unix-like system with a standard compilation
environment (make and C and C++ compilers)

Required libraries: libpng, lipjpeg, libtiff

Compilation instructions: run "make" to produce an executable
"inverse_compositional_algorithm" 


*****
USAGE
*****

The program reads two input images, take some parameters and produce a 
parametric model. The meaning of the parameters is thoroughly discussed on the 
accompanying IPOL article. Usage instructions:

  <Usage>: inverse_compositional_algorithm image1 image2 [OPTIONS]
  
  OPTIONS:
  --------
   -f name  Name of the output filename that will contain the
              computed transformation
              
   -n N     Number of scales for the coarse-to-fine scheme
              
   -z F     Zoom factor used in the coarse-to-fine scheme 
              Values must be in the range (0,1) 
              
   -e F     Threshold for the convergence criterion 
              
   -t N     Transformation type to be computed:
              2-traslation; 3-Euclidean transform; 4-similarity
              6-affinity; 8-homography 
              
   -r N     Use robust error functions: 
              0-Non robust (L2 norm); 1-truncated quadratic 
              2-German & McLure; 3-Lorentzian 4-Charbonnier 
              
   -l F     Value of the parameter for the robust error function
              A value <=0 if it is automatically computed
              
   -v       Switch on verbose mode. 
   

Execution examples:

  1.Default parameters:
    
   >inverse_compositional_algorithm input/homography1.png input/homography2.png 
  
  2.Computing an affinity with the truncated quadratic and verbose mode:
    
   >inverse_compositional_algorithm input/homography1.png input/homography2.png
                                    -t 6 -r 1 -v 

If a parameter is given an invalid value it will take a default value.


*************
LIST OF FILES
*************
bicubic_interpolation.cpp: Computes the bicubic interpolation of an image
file.cpp:   Functions for input/output 
iio.c:      Functions to read and write images 
inverse_compositional_algorithm.cpp: Implementation of the method
main.cpp:   Main algorithm to read the command line parameters
mask.cpp:   Function to compute the gradient of an image and apply a Gaussian
matrix.cpp: Multiplication of matrices and vectors and calculating the inverse
transformation.cpp: Compute the Jacobian and the composition of transformations
zoom.cpp:   Compute the zoom-out of an image and the zoom-in of the parameters

Complementary programs (used for the online demo only):
output.cpp:  Program to compute some images and error metrics from the results
noise.cpp:   Program to add Gaussian noise to the input images
mt19937ar.c: Program to generate random numbers, used in noise.cpp