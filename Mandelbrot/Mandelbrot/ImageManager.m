//
//  ImageManager.m
//  Mandelbrot
//
//  Created by Bingwen Fu on 11/25/15.
//  Copyright © 2015 Bingwen. All rights reserved.
//

#import <CoreImage/CoreImage.h>
#import "ImageManager.h"

#include <pthread.h>
#include "cl_mdc.h"

@implementation ImageManager
{
    pthread_mutex_t lock;
    int numOfWrittingThread;
}

+ (id)sharedManager
{
    static ImageManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init
{
    if (self = [super init]) {
        pthread_mutex_init(&lock, NULL);
        numOfWrittingThread = 0;
    }
    return self;
}

- (void)incrementWrittingJobNumber
{
    pthread_mutex_lock(&lock);
    numOfWrittingThread++;
    pthread_mutex_unlock(&lock);
}

- (void)decrementWrittingJobNumber
{
    pthread_mutex_lock(&lock);
    numOfWrittingThread--;
    pthread_mutex_unlock(&lock);
}

- (int)currentWrittingJobNumber
{
    int n = 0;
    pthread_mutex_lock(&lock);
    n = numOfWrittingThread;
    pthread_mutex_unlock(&lock);
    return n;
}

- (void)saveCLImageToFile:(cl_image)output_image size:(NSSize)size fileName:(NSString*)fileName blured:(BOOL)blured
{
    [self incrementWrittingJobNumber];
    int width = size.width;
    int height = size.height;
    
    @autoreleasepool {
        unsigned int * pixels = (unsigned int*)malloc(width * height * sizeof(unsigned int));
        dispatch_sync(dispatch_get_cl_queue(), ^{
            const size_t origin[3] = { 0, 0, 0 };
            const size_t region[3] = { width, height, 1 };
            gcl_copy_image_to_ptr(pixels, output_image, origin, region);
        });
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSBitmapImageRep * imageRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:(unsigned char **)&pixels pixelsWide:width pixelsHigh:height bitsPerSample:8 samplesPerPixel:4 hasAlpha:YES isPlanar:NO colorSpaceName:NSDeviceRGBColorSpace bitmapFormat:NSAlphaNonpremultipliedBitmapFormat bytesPerRow:4 * width bitsPerPixel:32];
            
            if (blured) {
                saveCIImageToFile(blurredImageWithBitmap(imageRep), fileName);
            } else {
                saveNSBitmapImageRepToFile(imageRep, fileName);
            }
            free(pixels);
            [self decrementWrittingJobNumber];
        });
    }
}

void saveNSBitmapImageRepToFile(NSBitmapImageRep *bitmap, NSString* fileName)
{
    NSDictionary *pros = @{NSImageCompressionFactor:@1.0};
    NSData* data = [bitmap representationUsingType:NSPNGFileType properties:pros];
    [data writeToFile:fileName atomically:YES];
}

void saveNSImageToFile(NSImage *image, NSString* fileName)
{
    NSBitmapImageRep *bitMap = [[NSBitmapImageRep alloc] initWithData:image.TIFFRepresentation];
    saveNSBitmapImageRepToFile(bitMap, fileName);
}

void saveCIImageToFile(CIImage *ciImage, NSString *fileName)
{
    NSBitmapImageRep *bitMap = [[NSBitmapImageRep alloc] initWithCIImage:ciImage];
    saveNSBitmapImageRepToFile(bitMap, fileName);
}

CIImage* clampBack(CIImage* src)
{
    NSRect rect = src.extent;
    CGFloat x = rect.origin.x;
    CGFloat y = rect.origin.y;
    CGFloat w = rect.size.width;
    CGFloat h = rect.size.height;
    rect = NSMakeRect(0, 0, w+2*x, h+2*y);
    return [src imageByCroppingToRect:rect];
}

CIImage* blurredImageWithBitmap(NSBitmapImageRep* bitmap) {
    
    CIImage *imageToBlur = [CIImage imageWithData:[bitmap TIFFRepresentation]];
    CIFilter *gaussianFilter = [CIFilter filterWithName: @"CIGaussianBlur"];
    [gaussianFilter setValue:imageToBlur forKey:kCIInputImageKey];
    [gaussianFilter setValue:[NSNumber numberWithFloat:1.0] forKey: @"inputRadius"];
    CIImage *result = [gaussianFilter valueForKey:kCIOutputImageKey];
    result = clampBack(result);
    return result;
}

@end
