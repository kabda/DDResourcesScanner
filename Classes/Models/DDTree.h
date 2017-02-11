//
//  DDTree.h
//  DDResourcesScanner
//
//  Created by 樊远东 on 11/02/2017.
//  Copyright © 2017 樊远东. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DDNode : NSObject
@property (nonatomic, weak  ) DDNode                 *parent;
@property (nonatomic, strong) NSMutableSet<DDNode *> *children;
@property (nonatomic, strong) NSObject               *object;

+ (instancetype)nodeForParent:(DDNode *)parent
                   withObject:(NSObject *)object;

@end



@interface DDTree : NSObject

+ (instancetype)tree;

- (void)addChildForRoot:(DDNode *)child;

- (void)addChild:(DDNode *)child forParent:(DDNode *)parent;
- (void)removeChildFromParent:(DDNode *)child;

- (void)moveChild:(DDNode *)child toParent:(DDNode *)parent;

- (NSArray *)childrenOfRoot;
- (NSArray *)childrenOfNode:(DDNode *)node;

- (NSArray *)allChildren;//所有子节点
- (NSArray *)allLeaves;//所有叶节点(没有子节点的节点)

@end
