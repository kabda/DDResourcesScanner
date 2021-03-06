//
//  DDImageModel.m
//  DDResourcesScanner
//
//  Created by 樊远东 on 11/02/2017.
//  Copyright © 2017 樊远东. All rights reserved.
//

#import "DDImageModel.h"
#import "NSImage+PHA.h"

@interface DDImageModel ()
@property (nonatomic, copy  ) NSString   *path;
@property (nonatomic, assign) long       volume;
@property (nonatomic, copy  ) NSString   *name;
@property (nonatomic, assign) NSUInteger scale;
@property (nonatomic, assign) NSSize     size;
@property (nonatomic, strong) NSColor    *mainColor;
@property (nonatomic, copy  ) NSString   *fingerprint;
@property (nonatomic, strong) NSImage    *image;
@end

@implementation DDImageModel

+ (instancetype)modelForPath:(NSString *)path {
    DDImageModel *model = [[DDImageModel alloc] init];
    model.path          = path;
    model.volume        = [DDImageModel imageSizeForPath:path];
    model.name          = [DDImageModel imageNameForPath:path];
    model.scale         = [DDImageModel imageScaleForPath:path];
    model.image         = [DDImageModel imageForPath:path];
    model.size          = model.image.size;
    model.mainColor     = model.image.mainColor;
    model.fingerprint   = model.image.fingerprint;
    return model;
}

+ (long)imageSizeForPath:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDictionary *attributes = [fileManager attributesOfItemAtPath:path error:nil];
    NSNumber *size = [attributes objectForKey:NSFileSize];
    return size.longValue;
}

+ (NSString *)imageNameForPath:(NSString *)path {
    return [[path pathComponents] lastObject];
}

+ (NSUInteger)imageScaleForPath:(NSString *)path {
    if ([path containsString:@"@3x"]) {
        return 3;
    }
    if ([path containsString:@"@2x"]) {
        return 2;
    }
    return 1;
}

+ (NSImage *)imageForPath:(NSString *)path {
    return [[NSImage alloc] initWithContentsOfFile:path];
}


@end
