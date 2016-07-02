//
//  DDAnalysisManager.h
//  DDResourcesScanner
//
//  Created by 樊远东 on 6/30/16.
//  Copyright © 2016 樊远东. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDSimilarImagesModel.h"

@class DDAnalysisManager;
@protocol DDAnalysisManagerDelegate <NSObject>
- (void)analysisManager:(DDAnalysisManager *)manager didScanningImageWithPath:(NSString *)path;
- (void)analysisManager:(DDAnalysisManager *)manager didHandleImageWithPath:(NSString *)path progress:(double)progress;
@end

@interface DDAnalysisManager : NSObject
@property (nonatomic, weak) id<DDAnalysisManagerDelegate> delegate;

@property (nonatomic, strong) NSString *projectPath;

@property (nonatomic, strong, readonly) NSArray *similarImages;
@property (nonatomic, assign, readonly) long totalSize;
@property (nonatomic, assign, readonly) long reduplicateSize;



- (void)loadAllImagesCompleted:(void(^)(BOOL succeed))completion;
- (void)findSimilarImagesWithLevel:(NSInteger)similarLevel completed:(void(^)(BOOL succeed))completion;

@end
