//
//  DDAnalysisManager.m
//  DDResourcesScanner
//
//  Created by 樊远东 on 6/30/16.
//  Copyright © 2016 樊远东. All rights reserved.
//

#import "DDAnalysisManager.h"
#import "DDImageModel.h"
#import "NSImage+PHA.h"

@interface DDAnalysisManager ()
@property (nonatomic, strong) DDTree *tree;
@end


@implementation DDAnalysisManager


- (void)loadAllImagesCompleted:(void(^)(BOOL succeed))completion {

    [self.tree empty];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *subpaths = [fileManager subpathsOfDirectoryAtPath:self.projectPath error:nil];
        for (NSString *path in subpaths) {
            if ([path hasSuffix:@".png"] || [path hasSuffix:@".jpg"] || [path hasSuffix:@".jpeg"]) {

                NSString *fullPath = [self.projectPath stringByAppendingPathComponent:path];

                DDImageModel *imageModel = [DDImageModel modelForPath:fullPath];
                DDNode *node = [DDNode nodeForParent:nil withObject:imageModel];
                [self.tree addChild:node forParent:self.tree.rootNode];

                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([self.delegate respondsToSelector:@selector(analysisManager:didScanningImageWithPath:)]) {
                        [self.delegate analysisManager:self didScanningImageWithPath:fullPath];
                    }
                });
            }
        }

        dispatch_async(dispatch_get_main_queue(), ^{

            if (completion) {
                completion(YES);
            }
        });
    });
}

- (void)findSimilarImagesWithLevel:(NSInteger)limitedLevel
                         completed:(void(^)(BOOL succeed))completion {

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        __block BOOL unfinished = YES;
        while (unfinished) {
            __block DDNode *tmpNode = nil;
            unfinished = NO;
            [DDTree traverse:self.tree.rootNode handler:^(DDNode *node) {

                if (node.children.count > 0) {
                    return;
                }
                if (!tmpNode) {
                    tmpNode = node;
                    return;
                }
                if (tmpNode) {
                    DDImageModel *imageModel1 = (DDImageModel *)tmpNode.object;
                    DDImageModel *imageModel2 = (DDImageModel *)node.object;
                    NSInteger diff = [NSImage differentBetweenFingerprint:imageModel1.fingerprint andFingerprint:imageModel2.fingerprint];
                    if (diff <= limitedLevel) {
                        [self.tree moveChild:node toParent:tmpNode];

                        unfinished = YES;
                    }
                }
            }];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
                    if ([self.delegate respondsToSelector:@selector(analysisManager:didHandleImageWithPath:progress:)]) {
                        [self.delegate analysisManager:self didHandleImageWithPath:nil progress:0.0];
                    }
                });

        dispatch_async(dispatch_get_main_queue(), ^{

            if (completion) {
                completion(YES);
            }
        });
    });
}

#pragma mark - Getter
- (DDTree *)tree {
    if (!_tree) {
        _tree = [DDTree tree];
    }
    return _tree;
}

@end
