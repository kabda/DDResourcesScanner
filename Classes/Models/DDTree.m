//
//  DDTree.m
//  DDResourcesScanner
//
//  Created by 樊远东 on 11/02/2017.
//  Copyright © 2017 樊远东. All rights reserved.
//

#import "DDTree.h"


@implementation DDNode

+ (instancetype)nodeForParent:(DDNode *)parent
                   withObject:(NSObject *)object {

    DDNode *node  = [[DDNode alloc] init];
    node.parent   = parent;
    node.children = [[NSMutableSet alloc] init];
    node.object   = object;
    return node;
}

@end




@interface DDTree ()
@property (nonatomic, strong) DDNode *rootNode;
@end

@implementation DDTree

+ (instancetype)tree {
    DDTree *tree  = [[DDTree alloc] init];
    tree.rootNode = [DDNode nodeForParent:nil withObject:nil];
    return tree;
}

- (void)addChildForRoot:(DDNode *)child {
    if (!child || ![child isKindOfClass:[DDNode class]]) {
        //无效子节点
        return;
    }
    [self addChild:child forParent:self.rootNode];
}

- (void)addChild:(DDNode *)child forParent:(DDNode *)parent {
    if (!child || ![child isKindOfClass:[DDNode class]]) {
        //无效子节点
        return;
    }
    if (!parent || ![parent isKindOfClass:[DDNode class]]) {
        //无效父节点
        return;
    }
    child.parent = parent;
    [parent.children addObject:child];
}

- (void)removeChildFromParent:(DDNode *)child {
    if (!child || ![child isKindOfClass:[DDNode class]]) {
        //无效子节点
        return;
    }
    [child.parent.children removeObject:child];
}

- (void)moveChild:(DDNode *)child toParent:(DDNode *)parent {
    if (!child || ![child isKindOfClass:[DDNode class]]) {
        //无效子节点
        return;
    }
    if (!parent || ![parent isKindOfClass:[DDNode class]]) {
        //无效父节点
        //添加至root
        [self addChild:child forParent:self.rootNode];
    }
}

- (NSArray *)childrenOfRoot {
    return [self childrenOfNode:self.rootNode];
}

- (NSArray *)childrenOfNode:(DDNode *)node {
    if (!node || ![node isKindOfClass:[DDNode class]]) {
        //无效节点
        return nil;
    }
    return node.children.allObjects;
}

- (NSArray *)allChildren {
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    NSMutableArray *queueArray = [[NSMutableArray alloc] init];
    [queueArray addObject:self.rootNode]; //压入根节点
    while (queueArray.count > 0) {
        DDNode *node = queueArray.firstObject;
        [queueArray removeObjectAtIndex:0]; //弹出最前面的节点，仿照队列先进先出原则
        NSArray *children = [self childrenOfNode:node];
        if (children.count > 0) {
            [returnArray addObjectsFromArray:children];
            [queueArray addObjectsFromArray:children];
        }
    }
    return [returnArray copy];
}

- (NSArray *)allLeaves {
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    NSMutableArray *queueArray = [[NSMutableArray alloc] init];
    [queueArray addObject:self.rootNode]; //压入根节点
    while (queueArray.count > 0) {
        DDNode *node = queueArray.firstObject;
        [queueArray removeObjectAtIndex:0]; //弹出最前面的节点，仿照队列先进先出原则
        NSArray *children = [self childrenOfNode:node];
        if (children.count > 0) {
            [queueArray addObjectsFromArray:children];
        } else {
            //叶节点返回
            [returnArray addObject:node];
        }
    }
    return [returnArray copy];
}

@end
