//
//  DDAnalysisManager.m
//  DDResourcesScanner
//
//  Created by 樊远东 on 6/30/16.
//  Copyright © 2016 樊远东. All rights reserved.
//

#import "DDAnalysisManager.h"

@interface DDAnalysisManager ()
@property (nonatomic, strong) NSArray *allImages;
@property (nonatomic, strong) NSArray *similarImages;

@property (nonatomic, assign) long totalSize;
@property (nonatomic, assign) long reduplicateSize;
@end


@implementation DDAnalysisManager


- (void)loadAllImagesCompleted:(void(^)(BOOL succeed))completion {

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *subpaths = [fileManager subpathsOfDirectoryAtPath:self.projectPath error:nil];
        NSMutableArray *tmpImageModels = [[NSMutableArray alloc] init];
        long totalSize = 0;
        for (NSString *path in subpaths) {
            if ([path hasSuffix:@".png"] || [path hasSuffix:@".jpg"] || [path hasSuffix:@".jpeg"]) {

                NSString *fullPath = [self.projectPath stringByAppendingPathComponent:path];
                NSDictionary *attributes = [fileManager attributesOfItemAtPath:fullPath error:nil];
                NSNumber *fileSize = [attributes objectForKey:NSFileSize];

                DDImageModel *imageModel = [[DDImageModel alloc] init];
                imageModel.path = fullPath;
                imageModel.volume = fileSize.longValue / 1024.0;
                imageModel.image = [[NSImage alloc] initWithContentsOfFile:fullPath];
                imageModel.name = [[fullPath pathComponents] lastObject];

                if ([imageModel.name containsString:@"@3x"]) {
                    imageModel.scale = 3;
                    
                    NSRange range = [imageModel.name rangeOfString:@"@3x"];
                    imageModel.simpleName = [imageModel.name substringToIndex:range.location];
                    
                } else if ([imageModel.name containsString:@"@2x"]) {
                    imageModel.scale = 2;
                    
                    NSRange range = [imageModel.name rangeOfString:@"@2x"];
                    imageModel.simpleName = [imageModel.name substringToIndex:range.location];
                    
                } else if ([imageModel.name containsString:@"@1x"]) {
                    imageModel.scale = 1;
                    
                    NSRange range = [imageModel.name rangeOfString:@"@1x"];
                    imageModel.simpleName = [imageModel.name substringToIndex:range.location];
                } else {
                    imageModel.scale = 1;
                    
                    NSRange range = [imageModel.name rangeOfString:@"."];
                    imageModel.simpleName = [imageModel.name substringToIndex:range.location];
                }
                
                [tmpImageModels addObject:imageModel];
                
                totalSize += imageModel.volume;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([self.delegate respondsToSelector:@selector(analysisManager:didScanningImageWithPath:)]) {
                        [self.delegate analysisManager:self didScanningImageWithPath:fullPath];
                    }
                });
            }
        }

        dispatch_async(dispatch_get_main_queue(), ^{

            self.allImages = tmpImageModels;
            self.totalSize = totalSize;

            if (completion) {
                completion(YES);
            }
        });
    });
}

- (void)findSimilarImagesWithLevel:(NSInteger)similarLevel
                         completed:(void(^)(BOOL succeed))completion {

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        NSArray *sourceImages = [[NSArray alloc] initWithArray:self.allImages];
        NSUInteger length = sourceImages.count;
        NSMutableArray *similarImages = [NSMutableArray matrixArrayWithLength:length];
        for (NSInteger section = 0; section < length - 1; section++) {
            DDImageModel *imageModel1 = (DDImageModel *)sourceImages[section];
            for (NSInteger index = section + 1; index < length - 1; index++) {
                DDImageModel *imageModel2 = (DDImageModel *)sourceImages[index];
                
                NSInteger similarLevel = [imageModel1.image similarLevelWithAnotherImage:imageModel2.image];
                
                DDSimilarImagesModel *similarImagesModel = [[DDSimilarImagesModel alloc] init];
                similarImagesModel.imageModel1 = imageModel1;
                similarImagesModel.imageModel2 = imageModel2;
                similarImagesModel.similarLevel = similarLevel;
                [similarImages addObject:similarImagesModel];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([self.delegate respondsToSelector:@selector(analysisManager:didHandleImageWithPath:progress:)]) {
                        [self.delegate analysisManager:self didHandleImageWithPath:imageModel2.path progress:((section * length + index) / (length * length))];
                    }
                });
            }
        }
        double reduplicateSize = 0.0;
        for (DDSimilarImagesModel *similarImagesModel in similarImages) {
            reduplicateSize += similarImagesModel.imageModel1.volume;
            reduplicateSize += similarImagesModel.imageModel2.volume;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{

            self.similarImages = [similarImages copy];
            self.reduplicateSize = reduplicateSize;

            if (completion) {
                completion(YES);
            }
        });
    });
}

@end