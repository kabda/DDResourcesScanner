//
//  DDStructure.h
//  DDResourcesScanner
//
//  Created by 樊远东 on 12/02/2017.
//  Copyright © 2017 樊远东. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DDNode : NSObject
@property (nonatomic, weak  ) DDNode                   *parent;
@property (nonatomic, strong) NSMutableArray<DDNode *> *children;
@property (nonatomic, strong) NSObject                 *object;

+ (instancetype)nodeForParent:(DDNode *)parent
                   withObject:(NSObject *)object;

@end



@interface DDTree : NSObject
@property (nonatomic, strong, readonly) DDNode *rootNode;

+ (instancetype)tree;

- (void)empty;

- (void)addChild:(DDNode *)child forParent:(DDNode *)parent;
- (void)removeChildFromParent:(DDNode *)child;
- (void)moveChild:(DDNode *)child toParent:(DDNode *)parent;

+ (void)traverse:(DDNode *)rootNode handler:(void(^)(DDNode *node))handler;

@end



@interface DDStack : NSObject

+ (instancetype)emptyStack;

- (void)push:(NSObject *)obj;
- (void)pop;
- (NSObject *)top;
- (BOOL)isEmpty;

- (NSArray *)allObjects;

@end



@interface DDQueue : NSObject

+ (instancetype)emptyQueue;

- (void)put:(NSObject *)obj;
- (NSObject *)get;
- (BOOL)isEmpty;

- (NSArray *)allObjects;

@end
