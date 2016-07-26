//
//  DDSimilarImagesModel.h
//  DDResourcesScanner
//
//  Created by 樊远东 on 7/2/16.
//  Copyright © 2016 樊远东. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDImageModel.h"


@interface DDSimilarImageModel : NSObject
@property (nonatomic, strong) NSArray<DDImageModel *> *similarImages;
@property (nonatomic, assign) NSInteger similarLevel;
@end

@interface DDSimilarImagesModel : NSObject
@property (nonatomic, strong) DDImageModel *sourceImage;
@property (nonatomic, strong) NSArray<DDSimilarImageModel *> *similarImages;
@property (nonatomic, assign) long reduplicateSize;
@end
