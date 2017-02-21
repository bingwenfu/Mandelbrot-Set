//
//  ImageManager.h
//  Mandelbrot
//
//  Created by Bingwen Fu on 11/25/15.
//  Copyright © 2015 Bingwen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <OpenCL/OpenCL.h>

@interface ImageManager : NSObject

+ (id)sharedManager;
- (int)currentWrittingJobNumber;
- (void)saveCLImageToFile:(cl_image)output_image size:(NSSize)size fileName:(NSString*)fileName blured:(BOOL)blured;

@end
