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

@property (nonatomic, strong) NSImage *image;
@property (nonatomic, assign) NSInteger scale;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *simpleName;

@end
