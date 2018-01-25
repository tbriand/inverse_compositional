#include <unistd.h>
#include <math.h>
#include <time.h>
#include <stdio.h>
#include <stdlib.h>

#include "mt19937ar.h"
#include "file.h"

void add_noise(double *u, double *v, double sigma, int size) {

    mt_init_genrand((unsigned long int) time (NULL) + (unsigned long int) getpid());

    for (int i=0; i< size; i++) 
    {
        double a=mt_genrand_res53();
        double b=mt_genrand_res53();
        double z = (sigma)*sqrt(-2.0*log(a))*cos(2.0*M_PI*b);

        v[i] =  u[i] + z;
    }
}


int main (int argc, char *argv[])
{
  if(argc<4)
    printf("\n\n<Usage>: %s input_image output_image sigma\n\n", argv[0]); 
  else
  {
    //read the parameters from console
    char *image1=argv[1], *image2=argv[2];
    int nx, ny, nz;
    double *I;
    double sigma=atof(argv[3]);
    
    if(read_image(image1, &I, nx, ny, nz))
    {
      double *F=new double[nx*ny*nz];
      
      if(sigma>0)
      {
        add_noise(I, F, sigma, nx*ny*nz);
        save_image(image2, F, nx, ny, nz);
      }
      else 
        save_image(image2, I, nx, ny, nz);
      
      free(I);
      delete []F;
    }
    else
      printf("Cannot read the image\n"); 
  }
}
