//
//  DDStructure.m
//  DDResourcesScanner
//
//  Created by 樊远东 on 12/02/2017.
//  Copyright © 2017 樊远东. All rights reserved.
//

#import "DDStructure.h"


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
    return tree;
}

- (void)empty {
    self.rootNode = nil;
}

- (void)addChild:(DDNode *)child forParent:(DDNode *)parent {
    if (!child || ![child isKindOfClass:[DDNode class]]) {
        //无效子节点
        return;
    }
    if (!parent || ![parent isKindOfClass:[DDNode class]]) {
        //无效父节点
        if (self.rootNode) {
            //如果存在根节点，就添加至根节点
            [self addChild:child forParent:self.rootNode];
        } else {
            //根节点不存在，作为根节点
            self.rootNode = child;
        }
        return;
    }
    if ([parent.children containsObject:child]) {
        //该父节点已经拥有该子节点
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




@interface DDStack ()
@property (nonatomic, strong) NSMutableArray *store;
@end


@implementation DDStack

+ (instancetype)emptyStack {
    return [[DDStack alloc] init];
}

- (void)push:(NSObject *)obj {
    [self.store addObject:obj];
}

- (void)pop {
    [self.store removeLastObject];
}

- (NSObject *)top {
    return [self.store lastObject];
}

- (BOOL)isEmpty {
    return (self.store.count == 0);
}

- (NSArray *)allObjects {
    return [self.store copy];
}

- (NSMutableArray *)store {
    if (!_store) {
        _store = [[NSMutableArray alloc] init];
    }
    return _store;
}

@end


@interface DDQueue ()
@property (nonatomic, strong) NSMutableArray *store;
@end

@implementation DDQueue

+ (instancetype)emptyQueue {
    return [[DDQueue alloc] init];
}

- (void)put:(NSObject *)obj {
    [self.store addObject:obj];
}

- (NSObject *)get {
    return [self.store firstObject];
}

- (BOOL)isEmpty {
    return (self.store.count == 0);
}

- (NSArray *)allObjects {
    return [self.store copy];
}

- (NSMutableArray *)store {
    if (!_store) {
        _store = [[NSMutableArray alloc] init];
    }
    return _store;
}

@end
