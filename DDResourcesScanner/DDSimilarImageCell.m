//
//  DDSimilarImageCell.m
//  DDResourcesScanner
//
//  Created by 樊远东 on 6/30/16.
//  Copyright © 2016 樊远东. All rights reserved.
//

#import "DDSimilarImageCell.h"

@implementation DDSimilarImageCell

- (instancetype)init {
    if (self = [super init]) {
        _imageView0 = [[NSImageView alloc] initWithFrame:NSZeroRect];
        _titleLabel0 = [[NSTextField alloc] initWithFrame:NSZeroRect];
        _pathLabel0 = [[NSTextField alloc] initWithFrame:NSZeroRect];
        _imageView1 = [[NSImageView alloc] initWithFrame:NSZeroRect];
        _titleLabel1 = [[NSTextField alloc] initWithFrame:NSZeroRect];
        _pathLabel1 = [[NSTextField alloc] initWithFrame:NSZeroRect];

        [self addSubview:_imageView0];
        [self addSubview:_titleLabel0];
        [self addSubview:_pathLabel0];
        [self addSubview:_imageView1];
        [self addSubview:_titleLabel1];
        [self addSubview:_pathLabel1];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

@end
