//
//  NSImage+PHA.m
//  FindSimilarImages
//
//  Created by 樊远东 on 12/4/15.
//  Copyright © 2015 樊远东. All rights reserved.
//

#import "NSImage+PHA.h"
#import <math.h>

@implementation NSImage (PHA)

- (NSString *)fingerprint {
    NSImage *scaledImage = [NSImage scaleImage:self withSize:NSMakeSize(8.0, 8.0)];
    NSImage *grayImage   = [scaledImage pha_grayImage];
    return [grayImage pha_pHashStringValue];
}

- (NSColor *)mainColor {
    return [self pha_mainColor];
}

+ (NSImage *)scaleImage:(NSImage *)sourceImage withSize:(NSSize)newSize {
    if (![sourceImage isValid]) {
        return nil;
    }

    NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
                                                                    pixelsWide:newSize.width
                                                                    pixelsHigh:newSize.height
                                                                 bitsPerSample:8
                                                               samplesPerPixel:4
                                                                      hasAlpha:YES
                                                                      isPlanar:NO
                                                                colorSpaceName:NSCalibratedRGBColorSpace
                                                                   bytesPerRow:0
                                                                  bitsPerPixel:0];
    rep.size = newSize;

    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithBitmapImageRep:rep]];

    [sourceImage drawInRect:NSMakeRect(0, 0, newSize.width, newSize.height)
                   fromRect:NSZeroRect
                  operation:NSCompositeCopy
                   fraction:1.0];

    [NSGraphicsContext restoreGraphicsState];

    NSImage *resizedImage = [[NSImage alloc] initWithSize:newSize];
    [resizedImage addRepresentation:rep];
    return resizedImage;
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
    CGContextDrawImage(context,CGRectMake(0, 0, width, height), [self pha_CGImage]);
    NSImage *grayImage = [[NSImage alloc] initWithCGImage:CGBitmapContextCreateImage(context) size:self.size];
    CGContextRelease(context);
    return grayImage;
}


- (CGImageRef)pha_CGImage {
    CGContextRef bitmapCtx = CGBitmapContextCreate(NULL/*data - pass NULL to let CG allocate the memory*/,
                                                   [self size].width,
                                                   [self size].height,
                                                   8 /*bitsPerComponent*/,
                                                   0 /*bytesPerRow - CG will calculate it for you if it's allocating the data.  This might get padded out a bit for better alignment*/,
                                                   [[NSColorSpace genericRGBColorSpace] CGColorSpace],
                                                   kCGBitmapByteOrder32Host|kCGImageAlphaPremultipliedFirst);

    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithGraphicsPort:bitmapCtx flipped:NO]];
    [self drawInRect:NSMakeRect(0,0, [self size].width, [self size].height) fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0];
    [NSGraphicsContext restoreGraphicsState];

    CGImageRef cgImage = CGBitmapContextCreateImage(bitmapCtx);
    CGContextRelease(bitmapCtx);

    return cgImage;
}


- (NSString *)pha_pHashStringValue {
    NSMutableString * pHashString = [NSMutableString string];
    CGImageRef imageRef = [self pha_CGImage];
    unsigned long width = CGImageGetWidth(imageRef);
    unsigned long height = CGImageGetHeight(imageRef);
    CGDataProviderRef provider = CGImageGetDataProvider(imageRef);
    NSData* data = (id)CFBridgingRelease(CGDataProviderCopyData(provider));
    const char * heightData = (char*)data.bytes;
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

- (NSColor *)pha_mainColor {

    CGContextRef bitmapCtx = CGBitmapContextCreate(NULL/*data - pass NULL to let CG allocate the memory*/,
                                                   [self size].width,
                                                   [self size].height,
                                                   8 /*bitsPerComponent*/,
                                                   0 /*bytesPerRow - CG will calculate it for you if it's allocating the data.  This might get padded out a bit for better alignment*/,
                                                   [[NSColorSpace genericRGBColorSpace] CGColorSpace],
                                                   kCGBitmapByteOrder32Host|kCGImageAlphaPremultipliedFirst);

    unsigned char *data = CGBitmapContextGetData(bitmapCtx);

    if (data == NULL) {
        return nil;
    }

    NSCountedSet *cls = [NSCountedSet setWithCapacity:self.size.width * self.size.height];
    for (int x = 0; x < self.size.width; x++) {
        for (int y = 0; y < self.size.height; y++) {

            int offset = 4*(x*y);

            int red = data[offset];
            int green = data[offset+1];
            int blue = data[offset+2];
            int alpha =  data[offset+3];

            NSArray *clr=@[@(red),@(green),@(blue),@(alpha)];
            [cls addObject:clr];
        }
    }
    CGContextRelease(bitmapCtx);

    NSEnumerator *enumerator = [cls objectEnumerator];
    NSArray *curColor = nil;
    NSArray *maxColor = nil;
    NSUInteger maxCount = 0;
    while ((curColor = [enumerator nextObject])) {
        NSUInteger tmpCount = [cls countForObject:curColor];
        if (tmpCount < maxCount) {
            continue;
        }
        maxCount = tmpCount;
        maxColor = curColor;
    }
    return [NSColor colorWithRed:([maxColor[0] intValue] / 255.0f)
                           green:([maxColor[1] intValue] / 255.0f)
                            blue:([maxColor[2] intValue] / 255.0f)
                           alpha:([maxColor[3] intValue] / 255.0f)];
}


+ (NSInteger)differentBetweenFingerprint:(NSString *)fingerprint1 andFingerprint:(NSString *)fingerprint2 {
    if (fingerprint1.length == 0 || fingerprint1.length != fingerprint2.length) {
        return NSIntegerMax;
    }
    NSInteger diff = 0;
    const char * s1 = [fingerprint1 UTF8String];
    const char * s2 = [fingerprint2 UTF8String];
    for (int i = 0 ; i < fingerprint1.length ;i++){
        if(s1[i] != s2[i]){
            diff++;
        }
    }
    return diff;
}

+ (CGFloat)differentBetweenColor:(NSColor *)color1 andColor:(NSColor *)color2 {

    CGFloat redColor1 = 0.0, redColor2 = 0.0;
    CGFloat greenColor1 = 0.0, greenColor2 = 0.0;
    CGFloat blueColor1 = 0.0, blueColor2 = 0.0;

    [color1 getRed:&redColor1 green:&greenColor1 blue:&blueColor1 alpha:nil];
    [color2 getRed:&redColor2 green:&greenColor2 blue:&blueColor2 alpha:nil];

    CGFloat absR = fabs(redColor1 - redColor2);
    CGFloat absG = fabs(greenColor1 - greenColor2);
    CGFloat absB = fabs(blueColor1 - blueColor2);

    return sqrt(absR * absR + absG * absG + absB * absB);
}


@end
