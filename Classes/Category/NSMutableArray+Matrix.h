//
//  NSMutableArray+Matrix.h
//  DDResourcesScanner
//
//  Created by 樊远东 on 7/2/16.
//  Copyright © 2016 樊远东. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (Matrix)
@property (nonatomic, assign, readonly) NSUInteger length;

+ (instancetype)matrixArrayWithLength:(NSUInteger)length;
- (instancetype)initWithLength:(NSUInteger)length;

- (void)setObject:(id)anObject forCol:(NSInteger)col atRow:(NSInteger)row;
- (id)objectForCol:(NSUInteger)col atRow:(NSInteger)row;
- (void)resetObjectForCol:(NSInteger)col atRow:(NSInteger)row; //reset可以理解为一般意义上的remove，只是reset会用NSNull进行占位
- (NSArray *)fliterObjectsWithCondition:(BOOL (^)(id theObject))condition;

@end
