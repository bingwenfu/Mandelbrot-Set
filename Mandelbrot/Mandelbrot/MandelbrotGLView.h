//
//  MandelbrotGLView.h
//  Mandelbrot
//
//  Created by Bingwen Fu on 10/11/15.
//  Copyright © 2015 Bingwen. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "cl_mdc.h"

#define MANDELBROT_SET 0x10000000
#define JULIA_SET      0x01000000

@interface MandelbrotGLView : NSOpenGLView
{
    GLuint texture;
    GLuint shaderPrograms;
    cl_uint* iterationImage;
    cl_image shared_climage_buffer;
    ComplexPoint juliaSeed;
    BOOL mouseDraged;
}

@property (nonatomic) int displayType;
@property (nonatomic) int iterLimit;
@property (nonatomic) double zoomRatio;
@property (nonatomic) BOOL clipColor;
@property (nonatomic) Plane p;
@property (nonatomic) ColorScheme colorScheme;

@property int* histData;
@property int histBins;
@property NSMutableArray *histArr;

- (void)updateColor;
- (void)redrawMandelbrotWithCalculation:(BOOL)recalculation;
- (void)zoomOut;
- (void)writeCurrentFrameAsImageToDisk;

@end
