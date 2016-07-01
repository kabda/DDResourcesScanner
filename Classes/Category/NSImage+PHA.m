//
//  NSImage+PHA.m
//  FindSimilarImages
//
//  Created by 樊远东 on 12/4/15.
//  Copyright © 2015 樊远东. All rights reserved.
//

#import "NSImage+PHA.h"
#import <CoreGraphics/CoreGraphics.h>

@interface NSImage (CGImage)
- (CGImageRef)CGImage;
+ (NSImage *)imageWithCGImage:(CGImageRef)cgImage;

@end

@implementation NSImage (CGImage)

- (CGImageRef)CGImage {
    NSData *imageData = [self TIFFRepresentation];
    CGImageRef imageRef;
    if(imageData) {
        CGImageSourceRef imageSource = CGImageSourceCreateWithData((CFDataRef)imageData,  NULL);
        imageRef = CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);
    }
    return imageRef;
}

+ (NSImage *)imageWithCGImage:(CGImageRef)cgImage {
    NSRect imageRect = NSZeroRect;
    CGContextRef imageContext = nil;
    NSImage* newImage = nil;
    // Get the image dimensions.
    imageRect.size.height = CGImageGetHeight(cgImage);
    imageRect.size.width = CGImageGetWidth(cgImage);
    // Create a new image to receive the Quartz image data.
    newImage = [[NSImage alloc] initWithSize:imageRect.size];
    [newImage lockFocus];
    // Get the Quartz context and draw.
    imageContext = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
    CGContextDrawImage(imageContext, *(CGRect*)&imageRect, cgImage);
    [newImage unlockFocus];
    return newImage;
}


@end

@implementation NSImage (PHA)

#pragma mark - Priate
- (NSImage *)pha_scaleToSize:(CGSize)size {
    NSRect targetFrame = NSMakeRect(0, 0, size.width, size.height);
    NSImageRep *sourceImageRep = [self bestRepresentationForRect:targetFrame context:nil hints:nil];
    NSImage *targetImage = [[NSImage alloc] initWithSize:size];
    [targetImage lockFocus];
    [sourceImageRep drawInRect: targetFrame];
    [targetImage unlockFocus];
    return targetImage;
}

- (NSImage *)pha_grayImage {
    int width = self.size.width;
    int height = self.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate (nil, width, height, 8,0, colorSpace, kCGImageAlphaNone);
    CGColorSpaceRelease(colorSpace);
    if (!context) {
        return nil;
    }
    CGContextDrawImage(context,CGRectMake(0, 0, width, height), self.CGImage);
    NSImage *grayImage = [NSImage imageWithCGImage:CGBitmapContextCreateImage(context)];
    CGContextRelease(context);
    return grayImage;
}

- (NSString *)pha_pHashStringValue {
    NSMutableString * pHashString = [NSMutableString string];
    CGImageRef imageRef = [self CGImage];
    unsigned long width = CGImageGetWidth(imageRef);
    unsigned long height = CGImageGetHeight(imageRef);
    CGDataProviderRef provider = CGImageGetDataProvider(imageRef);
    NSData *data = (id)CFBridgingRelease(CGDataProviderCopyData(provider));
    const char * heightData = (char *)data.bytes;
    int sum = 0;
    for (int i = 0; i < width * height; i++) {
        if (heightData[i] != 0) {
            sum += heightData[i];
        }
    }
    int avr = sum / (width * height);
    for (int i = 0; i < width * height; i++) {
        if (heightData[i] >= avr) {
            [pHashString appendString:@"1"];
        } else {
            [pHashString appendString:@"0"];
        }
    }
    return pHashString;
}

#pragma mark - Public
+ (NSInteger)differentValueCountWithString:(NSString *)str1 andString:(NSString *)str2 {
    NSInteger diff = 0;
    const char * s1 = [str1 UTF8String];
    const char * s2 = [str2 UTF8String];
    for (int i = 0 ; i < str1.length ;i++){
        if(s1[i] != s2[i]){
            diff++;
        }
    }
    return diff;
}

+ (NSInteger)differentValueCountWithImage:(NSImage *)image1 andAnotherImage:(NSImage *)image2 {
    NSString *pHashString1 = [[[image1 pha_scaleToSize:CGSizeMake(8.0, 8.0)] pha_grayImage] pha_pHashStringValue];
    NSString *pHashString2 = [[[image2 pha_scaleToSize:CGSizeMake(8.0, 8.0)] pha_grayImage] pha_pHashStringValue];
    return [NSImage differentValueCountWithString:pHashString1 andString:pHashString2];
}

- (NSInteger)differentValueCountWithdAnotherImage:(NSImage *)anotierImage {
    return [NSImage differentValueCountWithImage:self andAnotherImage:anotierImage];
}

- (NSString *)pHashStringValueWithSize:(CGSize)size {
    return [[[self pha_scaleToSize:size] pha_grayImage] pha_pHashStringValue];
}

@end

@implementation NSImage (PHA_Deprecated)

- (NSImage *)scaleToSize:(CGSize)size {
    return [self pha_scaleToSize:size];
}

- (NSImage *)grayImage {
    return [self pha_grayImage];
}

@end
