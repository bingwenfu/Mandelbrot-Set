//
//  cl_mdc.m
//  Mandelbrot
//
//  Created by Bingwen Fu on 10/9/15.
//  Copyright © 2015 Bingwen. All rights reserved.
//

#include "cl_mdc.h"
#include "mandelbrot_colorize.cl.h"
#include "mandelbrot_color_algo.h"
#include <stdio.h>

dispatch_queue_t dispatch_get_cl_queue()
{
    dispatch_queue_t queue = gcl_create_dispatch_queue(DEVICE_TYPE, NULL);
    if (!queue) {
        fprintf(stdout, "Unable to create a GPU-based dispatch queue.\n");
        exit(1);
    }
    return queue;
}

void cl_calculate_mandelbrot_iterations(cl_uint iterLimit, cl_uint width, cl_uint height, Plane p, cl_uint* iterImage)
{
    dispatch_queue_t queue = dispatch_get_cl_queue();
    dispatch_sync(queue, ^{
        cl_ndrange range = { 2, {0}, {width, height}, {0} };
        mandelbrot_iterations_kernel(&range, iterImage, width, height, iterLimit, p.x1, p.x2, p.y1, p.y2);
    });
    dispatch_release(queue);
}

void cl_colorize_iteration_Images(cl_uint* iterArr, cl_image image_buffer, cl_float* colorSet, cl_int iterLimit, cl_int width, cl_int height)
{
    dispatch_queue_t queue = dispatch_get_cl_queue();
    dispatch_sync(queue, ^{
        cl_ndrange range = { 2, {0}, {width, height}, {0} };
        mandelbrot_colorize_kernel(&range, image_buffer, iterArr, colorSet, iterLimit, width, height);
    });
    dispatch_release(queue);
}

void cl_calculate_and_colorize_mandelbrot(cl_uint iterLimit, cl_uint width, cl_uint height, Plane p, cl_float* colorSet, cl_image image_buffer, cl_uint* iterImage)
{
    dispatch_queue_t queue = dispatch_get_cl_queue();
    dispatch_sync(queue, ^{
        cl_ndrange range = { 2, {0}, {width, height}, {0} };
        mandelbrot_iteration_and_colorize_kernel(&range, image_buffer, iterImage, colorSet, width, height, iterLimit, p.x1, p.x2, p.y1, p.y2);
    });
    dispatch_release(queue);
}

void cl_calculate_julia_iterations(cl_uint iterLimit, cl_uint width, cl_uint height, Plane p, cl_uint* iterImage, ComplexPoint seed)
{
    dispatch_queue_t queue = dispatch_get_cl_queue();
    dispatch_sync(queue, ^{
        cl_ndrange range = { 2, {0}, {width, height}, {0} };
        julia_iterations_kernel(&range, iterImage, width, height, iterLimit, p.x1, p.x2, p.y1, p.y2, seed.r, seed.i);
    });
    dispatch_release(queue);
}

void cl_outlier_filter(cl_uint width, cl_uint height, cl_uint* iterImage, cl_uint* filteredImage)
{
    dispatch_queue_t queue = dispatch_get_cl_queue();
    dispatch_sync(queue, ^{
        //cl_ndrange range = { 2, {0}, {width, height}, {0} };
        //julia_iterations_kernel(&range, iterImage, width, height, iterLimit, p.x1, p.x2, p.y1, p.y2, seed.r, seed.i);
    });
    dispatch_release(queue);
}

