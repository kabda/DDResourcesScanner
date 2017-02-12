//
//  DDAnalysisManager.h
//  DDResourcesScanner
//
//  Created by 樊远东 on 6/30/16.
//  Copyright © 2016 樊远东. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDStructure.h"
#import "DDImageModel.h"

@class DDAnalysisManager;
@protocol DDAnalysisManagerDelegate <NSObject>
- (void)analysisManager:(DDAnalysisManager *)manager didScanningImageWithPath:(NSString *)path;
- (void)analysisManager:(DDAnalysisManager *)manager didHandleImageWithPath1:(NSString *)path1 path2:(NSString *)path2;
@end

@interface DDAnalysisManager : NSObject
@property (nonatomic, strong, readonly) DDTree    *tree;
@property (nonatomic, assign, readonly) long long total;
@property (nonatomic, assign, readonly) long long similarity;

@property (nonatomic, weak) id<DDAnalysisManagerDelegate> delegate;

@property (nonatomic, strong) NSString *projectPath;

- (void)loadAllImagesCompleted:(void(^)(BOOL succeed))completion;

- (void)findSimilarImagesWithLevel:(NSInteger)limitedLevel
                         completed:(void(^)(BOOL succeed))completion;

@end
