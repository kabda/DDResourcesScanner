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
                [tmpImageModels addObject:imageModel];

                totalSize += imageModel.volume;
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
        NSMutableArray *similarImages = [[NSMutableArray alloc] init];
        while (1) {
            NSArray *tmpArray = [self findSimilarImagesFromSource:sourceImages fliteredImages:&sourceImages];
            if (tmpArray.count == 0) {
                break;
            }
            [similarImages addObjectsFromArray:tmpArray];
        }

        double reduplicateSize = 0.0;
        for (DDImageModel *imageModel in similarImages) {
            reduplicateSize += imageModel.volume;
        }

        NSUInteger total = sourceImages.count;
        long factorial = getFactorial(total);
        factorial = MAX(factorial, 1);
        long count = 0;
        for (NSInteger section = 0; section < total; section++) {
            DDImageModel *imageModel0 = sourceImages[section];
            for (NSInteger index = section + 1; index < total; index++) {

                count++;

                DDImageModel *imageModel1 = sourceImages[index];

                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([self.delegate respondsToSelector:@selector(analysisManager:didHandleImageWithPath:progress:)]) {
                        [self.delegate analysisManager:self didHandleImageWithPath:imageModel1.path progress:(count * 1.0 / factorial)];
                    }
                });
                NSInteger similarLevel = [NSImage differentValueCountWithString:imageModel0.phaString andString:imageModel1.phaString];

                if (similarLevel < 2) {
                    if (![similarImages containsObject:imageModel0]) {
                        [similarImages addObject:imageModel0];
                        reduplicateSize += imageModel0.volume;
                    }
                    if (![similarImages containsObject:imageModel1]) {
                        [similarImages addObject:imageModel1];
                        reduplicateSize += imageModel1.volume;
                    }
                }
            }
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


- (NSArray *)findSimilarImagesFromSource:(NSArray *)sourceImages fliteredImages:(NSArray **)fliteredImages {
    NSMutableArray *tmpSimilarImages = [[NSMutableArray alloc] init];
    NSMutableArray *tmpSourceImages = [[NSMutableArray alloc] initWithArray:sourceImages];
    NSUInteger total = tmpSourceImages.count;
    BOOL hasFound = NO;
    for (NSInteger section = 0; section < total; section++) {
        if (hasFound) {
            break;
        }
        DDImageModel *imageModel0 = sourceImages[section];
        for (NSInteger index = section + 1; index < total; index++) {
            DDImageModel *imageModel1 = sourceImages[index];
            if ([imageModel0.realName isEqualToString:imageModel1.realName] && imageModel0.scale != imageModel1.scale) {
                continue;
            }
            NSInteger similarLevel = [NSImage differentValueCountWithString:imageModel0.phaString andString:imageModel1.phaString];
            if (similarLevel < 2) {
                hasFound = YES;
                [tmpSimilarImages addObject:imageModel0];
                [tmpSimilarImages addObject:imageModel1];
                [tmpSourceImages removeObjectIdenticalTo:imageModel0];
                [tmpSourceImages removeObjectIdenticalTo:imageModel1];
            }
        }
    }
    *fliteredImages = (NSArray *)[tmpSourceImages copy];
    return [tmpSimilarImages copy];
}

@end