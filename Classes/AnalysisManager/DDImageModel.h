//
//  DDImageModel.h
//  DDResourcesScanner
//
//  Created by 樊远东 on 6/30/16.
//  Copyright © 2016 樊远东. All rights reserved.
//

#import "NSImage+PHA.h"

@interface DDImageModel : NSObject

@property (nonatomic, strong) NSString *path;
@property (nonatomic, assign) double volume;

@property (nonatomic, strong, readonly) NSImage *image;
@property (nonatomic, strong, readonly) NSString *phaString;
@property (nonatomic, assign, readonly) NSInteger scale;
@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong, readonly) NSString *realName;

@end
