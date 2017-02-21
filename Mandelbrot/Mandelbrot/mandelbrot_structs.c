//
//  mandelbrot_structs.c
//  Mandelbrot
//
//  Created by Bingwen Fu on 11/5/15.
//  Copyright © 2015 Bingwen. All rights reserved.
//

#include "mandelbrot_structs.h"

void initColor(Color *c, float r, float g, float b)
{
    c->r = r;
    c->g = g;
    c->b = b;
}

void blendColor(Color *out, Color c1, Color c2, double r)
{
    out->r = (c1.r * (1-r) + c2.r * r);
    out->g = (c1.g * (1-r) + c2.g * r);
    out->b = (c1.b * (1-r) + c2.b * r);
}

void initPlane(Plane *p, double x1, double x2, double y1, double y2)
{
    p->x1 = x1;
    p->x2 = x2;
    p->y1 = y1;
    p->y2 = y2;
}

void zoomPlaneByRatio(Plane *p, double r)
{
    ComplexPoint center;
    center.r = (p->x1 + p->x2)/2;
    center.i = (p->y1 + p->y2)/2;
    
    double halfWidth = (p->x2-p->x1)/(2.0*r);
    p->x1 = center.r-halfWidth;
    p->x2 = center.r+halfWidth;
    p->y1 = center.i+halfWidth;
    p->y2 = center.i-halfWidth;
}