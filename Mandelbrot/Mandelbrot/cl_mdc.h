//
//  cl_mdc.h
//  Mandelbrot
//
//  Created by Bingwen Fu on 10/11/15.
//  Copyright © 2015 Bingwen. All rights reserved.
//

#ifndef cl_mdc_h
#define cl_mdc_h

#import <OpenCL/OpenCL.h>
#include "mandelbrot_structs.h"

#define DEVICE_TYPE CL_DEVICE_TYPE_GPU

dispatch_queue_t dispatch_get_cl_queue();
void cl_calculate_mandelbrot_iterations(cl_uint iterLimit, cl_uint width, cl_uint height, Plane p, cl_uint* iterImage);
void cl_colorize_iteration_Images(cl_uint* iterArr, cl_image image_buffer, cl_float* colorSet, cl_int iterLimit, cl_int width, cl_int height);
void cl_calculate_and_colorize_Image(cl_uint iterLimit, cl_uint width, cl_uint height, Plane p, cl_float* colorSet, cl_image image_buffer, cl_uint* iterImage);
void cl_calculate_julia_iterations(cl_uint iterLimit, cl_uint width, cl_uint height, Plane p, cl_uint* iterImage, ComplexPoint seed);

#endif /* cl_mdc_h */
