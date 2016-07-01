//
//  DDImageModel.m
//  DDResourcesScanner
//
//  Created by 樊远东 on 6/30/16.
//  Copyright © 2016 樊远东. All rights reserved.
//

#import "DDImageModel.h"

@interface DDImageModel ()
@property (nonatomic, strong) NSImage *image;
@property (nonatomic, strong) NSString *phaString;
@property (nonatomic, assign) NSInteger scale;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *realName;
@end

@implementation DDImageModel

- (void)setPath:(NSString *)path {
    _path = path;


    self.image = [[NSImage alloc] initWithContentsOfFile:_path];
    self.name = [[_path pathComponents] lastObject];
    self.phaString = [self.image pHashStringValueWithSize:CGSizeMake(8.0, 8.0)];

    if ([self.name containsString:@"@3x"]) {
        self.scale = 3;

        NSRange range = [self.name rangeOfString:@"@3x"];
        self.realName = [self.name substringToIndex:range.location];

    } else if ([self.name containsString:@"@2x"]) {
        self.scale = 2;

        NSRange range = [self.name rangeOfString:@"@2x"];
        self.realName = [self.name substringToIndex:range.location];

    } else if ([self.name containsString:@"@1x"]) {
        self.scale = 1;

        NSRange range = [self.name rangeOfString:@"@1x"];
        self.realName = [self.name substringToIndex:range.location];
    } else {
        self.scale = 1;

        NSRange range = [self.name rangeOfString:@"."];
        self.realName = [self.name substringToIndex:range.location];
    }
}


@end
