//
//  DDSimilarImagesModel.h
//  DDResourcesScanner
//
//  Created by 樊远东 on 7/2/16.
//  Copyright © 2016 樊远东. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDImageModel.h"

@interface DDSimilarImagesModel : NSObject
@property (nonatomic, strong) DDImageModel *imageModel1;
@property (nonatomic, strong) DDImageModel *imageModel2;

@property (nonatomic, assign) NSInteger similarLevel;

@property (nonatomic, assign) NSUInteger col;
@property (nonatomic, assign) NSUInteger row;
@end
