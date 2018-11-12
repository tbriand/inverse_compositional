// This program is free software: you can use, modify and/or redistribute it
// under the terms of the simplified BSD License. You should have received a
// copy of this license along this program. If not, see
// <http://www.opensource.org/licenses/bsd-license.html>.
//
// Copyright (C) 2018, Thibaud Briand <thibaud.briand@enpc.fr>
// All rights reserved.

#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "iio.h"

// function for comparing two values
static int f_compare (const void * a, const void * b)
{
    if(*(const float*)a < *(const float*)b)
        return -1;
    return *(const float*)a > *(const float*)b;
}

// histogram equalization of two images (it is not Midway !)
static void equalization_histo(float *ref, float *modified, float *out, int w,
                               int h, int pd)
{
  /* mix values and indexes to keep track of pixels' location */
  float *sort_values_ref = malloc(2*w*h*sizeof*sort_values_ref);
  float *sort_values_modified = malloc(2*w*h*sizeof*sort_values_modified);

  for (int l=0; l<pd;l++) {
    for (int idx=0; idx<w*h; idx++) {
      sort_values_ref[2*idx] = ref[idx + l*w*h];
      sort_values_ref[2*idx+1] = (float) idx;
      sort_values_modified[2*idx] = modified[idx + l*w*h];
      sort_values_modified[2*idx+1] = (float) idx;
    }

    /* sort pixels depending on their values*/
    qsort(sort_values_ref, w*h, 2*sizeof(float), f_compare);
    qsort(sort_values_modified, w*h, 2*sizeof(float), f_compare);

    /* histogram matching */
    for(int idx=0; idx < w*h ; idx++)
      out[ (int) sort_values_modified[2*idx+1] + l*w*h ]
        = sort_values_ref[2*idx];
  }

  /* free memory */
  free(sort_values_ref);
  free(sort_values_modified);
}

// Additive mean equalization of two images
static void equalization_meanp(float *ref, float *modified, float *out,
                               int w, int h, int w2, int h2, int pd)
{
    /* memory allocation */
    float *mean_ref = malloc(pd*sizeof(float));
    float *mean_modified = malloc(pd*sizeof(float));

    /* mean computation */
    for(int l=0; l<pd; l++) {
        mean_ref[l] = 0;
        for(int i=0; i<w*h; i++)
                mean_ref[l] += ref[i + l*w*h];
        mean_ref[l] /= (float) (w*h);

        mean_modified[l]=0;
        for(int i=0; i<w2*h2; i++)
                mean_modified[l] += modified[i + l*w2*h2];
        mean_modified[l] /= (float) (w2*h2);
    }

    /* equalization by shifting the mean */
    for(int l=0; l<pd; l++)
      for(int i=0; i<w2*h2; i++)
          out[i + l*w2*h2] = modified[i + l*w2*h2]
            - mean_modified[l] + mean_ref[l];

    /* free memory */
    free(mean_ref);
    free(mean_modified);
}

// multiplicative mean equalization of two images
static void equalization_meanx(float *ref, float *modified, float *out,
                               int w, int h, int w2, int h2, int pd)
{
    float *mean_ref = malloc(pd*sizeof(float));
    float *mean_modified = malloc(pd*sizeof(float));

    /* mean computation */
    for(int l=0; l<pd; l++) {
        mean_ref[l] = 0;
        for(int i=0; i<w*h; i++)
            mean_ref[l] += ref[i + l*w*h];
        mean_ref[l] /= (float) (w*h);

        mean_modified[l]=0;
        for(int i=0; i<w2*h2;i++)
            mean_modified[l] += modified[i + l*h2*w2];
        mean_modified[l] /= (float) (w2*h2);
    }

    float factor;
    /* equalization by shifting the mean */
    for(int l=0; l<pd; l++) {
        if ( fabs(mean_modified[l]) < 1e-3 )
            factor = 1;
        else
            factor = mean_ref[l]/mean_modified[l];

        for(int i=0; i<w2*h2; i++)
            out[i + l*w2*h2] = modified[i + l*w2*h2]*factor;
    }

    /* free memory */
    free(mean_ref);
    free(mean_modified);
}

// affine equalization of two images
static void equalization_affine(float *ref, float *modified, float *out,
                                int w, int h, int w2, int h2, int pd)
{
    float *mean_ref = malloc(pd*sizeof(float));
    float *mean_modified = malloc(pd*sizeof(float));
    float *v_ref = malloc(pd*sizeof(float));
    float *v_modified = malloc(pd*sizeof(float));
    float *slope = malloc(pd*sizeof(float));

    /* mean computation */
    for(int l=0; l<pd; l++) {
        mean_ref[l] = 0;
        for(int i=0; i<w*h; i++)
            mean_ref[l] += ref[i + l*w*h];
        mean_ref[l] /= (float) (w*h);

        mean_modified[l]=0;
        for(int i=0; i<w2*h2; i++)
            mean_modified[l] += modified[i + l*w2*h2];
        mean_modified[l] /= (float) (w2*h2);
    }

    /* variance computation and affine equalization */
    float tmp;
    for(int l=0; l<pd; l++) {
        v_ref[l] = 0;
        for(int i=0; i<w*h; i++) {
            tmp = ref[i + l*w*h] - mean_ref[l];
            v_ref[l] += tmp*tmp;
        }
        v_ref[l] /= (float) (w*h);

        v_modified[l] = 0;
        for(int i=0; i<w2*h2; i++) {
            tmp = modified[i + l*w2*h2] - mean_modified[l];
            v_modified[l] += tmp*tmp;
        }
        v_modified[l] /= (float) (w2*h2);
        
        if ( fabs(v_modified[l]) < 1e-3 )
            slope[l] = 1;
        else
            slope[l] = sqrt(v_ref[l]/v_modified[l]);

        /* affine equalization */
        for(int i=0; i<w2*h2; i++)
          out[i + l*w2*h2] = slope[l] * 
            (modified[i + l*h2*w2] - mean_modified[l]) + mean_ref[l];
    }

    /* free memory */
    free(mean_ref);
    free(mean_modified);
    free(v_ref);
    free(v_modified);
    free(slope);
}

int main(int c, char *v[])
{
  // display usage
  if (c != 5) {
    fprintf(stderr,"usage:\n\t%s ref modified out type\n", *v);
    //                         0 1   2        3   4
    fprintf(stderr,"type possibilities: histo, affine, meanp, meanx\n");
    return EXIT_FAILURE;
  }

  // read inputs
  char *filename_ref = c > 1 ? v[1] : "-";
  char *filename_modified = c > 2 ? v[2] : "-";
  char *filename_out = c > 3 ? v[3] : "-";
  char *equalization_type = c > 4 ? v[4] : "-";

  // read images
  int w, h, pd;
  float *ref = iio_read_image_float_split(filename_ref, &w, &h, &pd);
  int w2, h2 , pd2;
  float *modified = iio_read_image_float_split(filename_modified, &w2, &h2, &pd2);

  // sanity check
  if ( pd != pd2 ) {
    fprintf(stderr,"Images should have the same number of channel\n");
    return EXIT_FAILURE;
  }

  // memory allocation
  float *out = malloc(w2*h2*pd2*sizeof*out);

  // Contrast equalization
  if ( 0 == strcmp(equalization_type, "histo") ) {
    if( w!=w2 || h!=h2 || pd!=pd2 ) {
      fprintf(stderr,"Size of images should be the same\n");
      return EXIT_FAILURE;
    }
    equalization_histo(ref, modified, out, w, h, pd);
  }
  else if ( 0 == strcmp(equalization_type, "affine") )
    equalization_affine(ref, modified, out, w, h, w2, h2, pd);
  else if ( 0 == strcmp(equalization_type, "meanp") )
    equalization_meanp(ref, modified, out, w, h, w2, h2, pd);
  else if ( 0 == strcmp(equalization_type, "meanx") )
    equalization_meanx(ref, modified, out, w, h, w2, h2, pd);
  else {
    fprintf(stderr,"Unknown equalization type\n");
    return EXIT_FAILURE;
  }

  // write output
  iio_write_image_float_split(filename_out, out, w2, h2, pd2);

  // free memory
  free(ref);
  free(modified);
  free(out);

  return EXIT_SUCCESS;
}
