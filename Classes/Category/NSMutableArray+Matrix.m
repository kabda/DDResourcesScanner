//
//  NSMutableArray+Matrix.m
//  DDResourcesScanner
//
//  Created by 樊远东 on 7/2/16.
//  Copyright © 2016 樊远东. All rights reserved.
//

#import "NSMutableArray+Matrix.h"
#import <objc/runtime.h>

@implementation NSMutableArray (Matrix)

+ (instancetype)matrixArrayWithLength:(NSUInteger)length {
    return [[NSMutableArray alloc] initWithLength:length];
}

- (instancetype)initWithLength:(NSUInteger)length {
    if (self = [self init]) {
        self.length = length;
        NSUInteger capacity = self.length * self.length;
        for (NSInteger index = 0; index < capacity; index++) {
            [self addObject:[NSNull null]];
        }
    }
    return self;
}

- (void)setObject:(id)anObject forCol:(NSInteger)col atRow:(NSInteger)row {
    NSUInteger index = row * self.length + col;
    [self replaceObjectAtIndex:index withObject:anObject];
}

- (id)objectForCol:(NSUInteger)col atRow:(NSInteger)row {
    NSUInteger index = row * self.length + col;
    return [self objectAtIndex:index];
}

- (void)resetObjectForCol:(NSInteger)col atRow:(NSInteger)row {
    [self setObject:[NSNull null] forCol:col atRow:row];
}

- (NSArray *)fliterObjectsWithCondition:(BOOL (^)(id theObject))condition {
    NSArray *sourceArray = [self copy];
    NSMutableArray *fliteredArray = [[NSMutableArray alloc] init];
    for (id object in sourceArray) {
        if ([object isKindOfClass:[NSNull class]]) {
            continue;
        }
        if (condition && condition(object)) {
            [fliteredArray addObject:object];
        }
    }
    return [fliteredArray copy];
}

#pragma mark - Setter/Getter
static const void *kLengthNameKey = &kLengthNameKey;

- (NSUInteger)length {
    NSNumber *lengthNumber = objc_getAssociatedObject(self, kLengthNameKey);
    return lengthNumber.unsignedIntegerValue;
}

- (void)setLength:(NSUInteger)length {
    objc_setAssociatedObject(self, kLengthNameKey, @(length), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
