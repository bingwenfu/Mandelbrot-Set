//
//  mandelbrot_utility.c
//  Mandelbrot
//
//  Created by Bingwen Fu on 11/5/15.
//  Copyright © 2015 Bingwen. All rights reserved.
//

#include "mandelbrot_utility.h"
#include "mandelbrot_color_algo.h"
#include "cl_mdc.h"

NSColor* cColor2NSColor(Color c)
{
    return [NSColor colorWithRed:c.r green:c.g blue:c.b alpha:1.0];
}

cl_float* gen_cl_colorSet(int iterLimit, ColorScheme *cs, BOOL clipColor)
{
    int size = clipColor ? 1:3;
    float* c_colorSet = gen_c_colorSet(iterLimit, cs);
    void* cl_ColorSet = gcl_malloc(sizeof(cl_float)*iterLimit*size, c_colorSet, CL_MEM_COPY_HOST_PTR);
    free(c_colorSet);
    return cl_ColorSet;
}

NSArray* gen_ns_colorSet(int iterLimit, ColorScheme *cs)
{
    float* c_colorSet = gen_c_colorSet(iterLimit, cs);
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i=0; i<iterLimit; i++) {
        int j = i*3;
        NSColor *color = [NSColor colorWithRed:c_colorSet[j] green:c_colorSet[j+1] blue:c_colorSet[j+2] alpha:1.0];
        [array addObject:color];
    }
    free(c_colorSet);
    return array;
}