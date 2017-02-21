//
//  MandelbrotParameters.h
//  Mandelbrot
//
//  Created by Bingwen Fu on 10/22/15.
//  Copyright © 2015 Bingwen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cl_mdc.h"

@interface MandelbrotParameters : NSObject
@property int ID;
@property int iterLimit;
@property Plane plane;
@property ColorScheme colorScheme;
@end

