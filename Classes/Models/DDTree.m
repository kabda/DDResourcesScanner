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
    node.children = [[NSMutableArray alloc] init];
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

- (void)empty {
    self.rootNode = [DDNode nodeForParent:nil withObject:nil];
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
    if ([parent.children containsObject:child]) {
        //已经存在该子节点
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
        return;
    }
    [self removeChildFromParent:child];
    [self addChild:child forParent:parent];
}

+ (void)traverse:(DDNode *)rootNode handler:(void(^)(DDNode *node))handler {
    if (!rootNode) {
        return;
    }
    if (handler) {
        handler(rootNode);
    }
    for (DDNode *childNode in rootNode.children.copy) {
        [DDTree traverse:childNode handler:handler];
    }
}

@end
