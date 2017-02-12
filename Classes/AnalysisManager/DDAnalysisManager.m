//
//  DDAnalysisManager.m
//  DDResourcesScanner
//
//  Created by 樊远东 on 6/30/16.
//  Copyright © 2016 樊远东. All rights reserved.
//

#import "DDAnalysisManager.h"
#import "NSImage+PHA.h"

@interface DDAnalysisManager ()
//@property (nonatomic, strong) DDTree    *tree;
@property (nonatomic, strong) NSMutableArray *images;
@property (nonatomic, assign) long long total;
@property (nonatomic, assign) long long similarity;
@end


@implementation DDAnalysisManager


- (void)loadAllImagesCompleted:(void(^)(BOOL succeed))completion {

    self.total = 0;
    self.similarity = 0;
    
//    [self.tree empty];
//    DDNode *virtualRoot = [DDNode nodeForParent:nil withObject:nil];
//    [self.tree addChild:virtualRoot forParent:nil];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *subpaths = [fileManager subpathsOfDirectoryAtPath:self.projectPath error:nil];
        for (NSString *path in subpaths) {
            if ([path hasSuffix:@".png"] || [path hasSuffix:@".jpg"] || [path hasSuffix:@".jpeg"]) {

                NSString *fullPath = [self.projectPath stringByAppendingPathComponent:path];

                DDImageModel *imageModel = [DDImageModel modelForPath:fullPath];
//                DDNode *node = [DDNode nodeForParent:nil withObject:imageModel];
//                [self.tree addChild:node forParent:self.tree.rootNode];
                [self.images addObject:imageModel];

                self.total += imageModel.volume;

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

- (void)findSimilarImagesWithShapeLevel:(NSInteger)shapeLevel
                             colorLevel:(CGFloat)colorLevel
                         completed:(void(^)(BOOL succeed))completion {

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        NSMutableArray *storeArray = [[NSMutableArray alloc] init];
        NSArray *tmpArray = [[NSArray alloc] initWithArray:self.images];
        NSUInteger total = tmpArray.count;
        for (NSInteger section = 0; section < total; section++) {
            DDImageModel *image1 = (DDImageModel *)tmpArray[section];
            NSMutableArray *subStoreArray = [[NSMutableArray alloc] init];
            [subStoreArray addObject:image1];
            for (NSInteger index = (section + 1); index < total; index++) {
                DDImageModel *image2 = (DDImageModel *)tmpArray[index];

                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([self.delegate respondsToSelector:@selector(analysisManager:didHandleImageWithPath1:path2:)]) {
                        [self.delegate analysisManager:self didHandleImageWithPath1:image1.path path2:image2.path];
                    }
                });

                NSInteger shapeDiff = [NSImage differentBetweenFingerprint:image1.fingerprint andFingerprint:image2.fingerprint];
                CGFloat   colorDiff = [NSImage differentBetweenColor:image1.mainColor andColor:image2.mainColor];
                if (shapeDiff <= shapeLevel && colorDiff <= colorLevel) {
                    [subStoreArray addObject:image2];
                }
            }
            [storeArray addObject:subStoreArray];
        }
        self.images = storeArray;
        
//        __block BOOL unfinished = YES;
//        while (unfinished) {
//            __block DDNode *tmpNode = nil;
//            unfinished = NO;
//            [DDTree traverse:self.tree.rootNode handler:^(DDNode *node) {
//
//                if (!node.object) {
//                    return;
//                }
//                if (!tmpNode) {
//                    tmpNode = node;
//                    return;
//                }
//
//                DDImageModel *imageModel1 = (DDImageModel *)tmpNode.object;
//                DDImageModel *imageModel2 = (DDImageModel *)node.object;
//
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    if ([self.delegate respondsToSelector:@selector(analysisManager:didHandleImageWithPath1:path2:)]) {
//                        [self.delegate analysisManager:self didHandleImageWithPath1:imageModel1.path path2:imageModel2.path];
//                    }
//                });
//
//                NSInteger diff = [NSImage differentBetweenFingerprint:imageModel1.fingerprint andFingerprint:imageModel2.fingerprint];
//                if (diff <= limitedLevel) {
//                    if ([node.parent isEqualTo:self.tree.rootNode] && [node.parent isEqualTo:tmpNode.parent]) {
//                        [self.tree moveChild:node toParent:tmpNode];
//                        self.similarity += imageModel2.volume;
//                    } else if (![node.parent isEqualTo:self.tree.rootNode] && [node.parent isEqualTo:tmpNode.parent]) {
//
//                    } else if ([node.parent isEqualTo:self.tree.rootNode] && ![node.parent isEqualTo:tmpNode.parent]) {
//                        [self.tree moveChild:node toParent:tmpNode];
//                        self.similarity += imageModel2.volume;
//                    } else {
//
//                    }
//                    unfinished = YES;
//                }
//            }];
//        }
        dispatch_async(dispatch_get_main_queue(), ^{

            if (completion) {
                completion(YES);
            }
        });
    });
}

#pragma mark - Getter
- (NSMutableArray *)images {
    if (!_images) {
        _images = [[NSMutableArray alloc] init];
    }
    return _images;
}

//- (DDTree *)tree {
//    if (!_tree) {
//        _tree = [DDTree tree];
//    }
//    return _tree;
//}

@end
