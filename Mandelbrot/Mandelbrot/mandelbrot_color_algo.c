//
//  mandelbrot_color_algo.c
//  Mandelbrot
//
//  Created by Bingwen Fu on 11/5/15.
//  Copyright © 2015 Bingwen. All rights reserved.
//

#include "mandelbrot_color_algo.h"
#include <stdlib.h>
#include <math.h>

float* gen_c_colorSet(int iterLimit, ColorScheme *cs)
{
    float a = cs->a;
    float cl1 = cs->colorLine1;
    float cl2 = cs->colorLine2;
    Color color1 = cs->color1;
    Color color2 = cs->color2;
    Color color3 = cs->color3;
    Color color4 = cs->color4;
    
    float *colorSet = malloc(sizeof(float)*3*iterLimit);
    for (int i=0; i<iterLimit-1; i++) {
        double r = (double)i/(double)iterLimit;
        Color color;
        if (r >= 0.0 && r < cl1) {
            blendColor(&color, color1, color2, exp(a*((r/cl1)-1)));
        } else if (r >= cl1 && r < cl2) {
            blendColor(&color, color2, color3, (r-cl1)/(cl2-cl1));
        } else if (r >= cl2 && r <= 1.0) {
            blendColor(&color, color3, color4, (r-cl2)/(1-cl2));
        } else {
            exit(0);
        }
        int j = i*3;
        colorSet[j]   = color.r;
        colorSet[j+1] = color.g;
        colorSet[j+2] = color.b;
    }
    int j = (iterLimit-1)*3;
    colorSet[j]   = 0.0;
    colorSet[j+1] = 0.0;
    colorSet[j+2] = 0.0;
    
    return colorSet;
}
