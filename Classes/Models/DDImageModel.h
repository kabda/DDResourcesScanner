//
//  DDImageModel.h
//  DDResourcesScanner
//
//  Created by 樊远东 on 11/02/2017.
//  Copyright © 2017 樊远东. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DDImageModel : NSObject

@property (nonatomic, copy,   readonly) NSString   *path;        //路径
@property (nonatomic, assign, readonly) long       volume;       //容量
@property (nonatomic, copy,   readonly) NSString   *name;        //名称
@property (nonatomic, assign, readonly) NSUInteger scale;        //缩放率
@property (nonatomic, copy,   readonly) NSString   *fingerprint; //图片指纹

+ (instancetype)modelForPath:(NSString *)path;

@end
