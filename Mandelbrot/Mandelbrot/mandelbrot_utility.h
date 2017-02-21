//
//  mandelbrot_utility.h
//  Mandelbrot
//
//  Created by Bingwen Fu on 11/5/15.
//  Copyright © 2015 Bingwen. All rights reserved.
//

#ifndef mandelbrot_utility_h
#define mandelbrot_utility_h

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <OpenCL/OpenCL.h>
#import "mandelbrot_structs.h"

cl_float* gen_cl_colorSet(int iterLimit, ColorScheme *cs, BOOL clipColor);
NSArray* gen_ns_colorSet(int iterLimit, ColorScheme *cs);
NSColor* cColor2NSColor(Color c);

#endif /* mandelbrot_utility_h */
