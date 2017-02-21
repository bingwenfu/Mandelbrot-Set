//
//  mandelbrot_structs.h
//  Mandelbrot
//
//  Created by Bingwen Fu on 11/5/15.
//  Copyright © 2015 Bingwen. All rights reserved.
//

#ifndef mandelbrot_structs_h
#define mandelbrot_structs_h

typedef struct Plane {
    double x1;
    double x2;
    double y1;
    double y2;
} Plane;

typedef struct ComplexPoint {
    double r;
    double i;
} ComplexPoint;

typedef struct Color {
    float r;
    float g;
    float b;
} Color;

typedef struct ColorScheme {
    Color color1;
    Color color2;
    Color color3;
    Color color4;
    float colorLine1;
    float colorLine2;
    float a;
    float b;
} ColorScheme;


void initColor(Color *c, float r, float g, float b);
void blendColor(Color *out, Color c1, Color c2, double r);
void initPlane(Plane *p, double x1, double x2, double y1, double y2);
void zoomPlaneByRatio(Plane *p, double r);

#endif /* mandelbrot_structs_h */
