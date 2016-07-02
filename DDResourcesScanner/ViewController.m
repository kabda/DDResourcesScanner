//
//  ViewController.m
//  DDResourcesScanner
//
//  Created by 樊远东 on 6/30/16.
//  Copyright © 2016 樊远东. All rights reserved.
//

#import "ViewController.h"
#import "DDAnalysisManager.h"

typedef NS_ENUM(NSUInteger, DDScannerWorkFlow) {
    DDScannerWorkFlowWaitingSelectPath,
    DDScannerWorkFlowLoadAndAnalysis,
    DDScannerWorkFlowCompleted,
};

@interface ViewController () <NSTableViewDelegate, NSTableViewDataSource, DDAnalysisManagerDelegate>
@property (weak) IBOutlet NSButton *actionButton;
@property (weak) IBOutlet NSTextField *contentLabel;
@property (weak) IBOutlet NSTableView *resourcesTableView;

@property (nonatomic, strong) DDAnalysisManager *analysisManager;
@property (nonatomic, assign) DDScannerWorkFlow workFlow;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.workFlow = DDScannerWorkFlowWaitingSelectPath;
    self.contentLabel.stringValue = @"";

    self.resourcesTableView.dataSource = self;
    self.resourcesTableView.delegate = self;

    self.analysisManager.delegate = self;
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

}

#pragma mark - Button Action
- (IBAction)actionButtonDidClicked:(NSButton *)sender {
    switch (self.workFlow) {
        case DDScannerWorkFlowWaitingSelectPath:
        case DDScannerWorkFlowCompleted: {
            [self openFinder];
            break;
        }
        case DDScannerWorkFlowLoadAndAnalysis: {
            [self startScanner];
            break;
        }
    }
}

#pragma mark - NSTableViewDataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.analysisManager.similarImages.count;
}

#pragma mark - NSTableViewDelegate
- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return 80.0;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {

    DDImageModel *imageModel = self.analysisManager.similarImages[row];

    NSTableCellView *cell = [tableView makeViewWithIdentifier:tableColumn.identifier owner:nil];
    if ([tableColumn.identifier isEqualToString:@"kImageAndNameIdentifier"]) {
        cell.textField.stringValue = imageModel.name;
        cell.imageView.image = imageModel.image;
    } else if ([tableColumn.identifier isEqualToString:@"kPathIdentifier"]) {
        cell.textField.stringValue = imageModel.path;
        cell.imageView.image = nil;
    } else if ([tableColumn.identifier isEqualToString:@"kSizeIdentifier"]) {
        cell.textField.stringValue = [NSString stringWithFormat:@"%0.2f", imageModel.volume];
        cell.imageView.image = nil;
    } else {
        cell.textField.stringValue = @"";
        cell.imageView.image = nil;
    }
    return cell;
}

#pragma mark - DDAnalysisManagerDelegate
- (void)analysisManager:(DDAnalysisManager *)manager didScanningImageWithPath:(NSString *)path {
    self.contentLabel.stringValue = [NSString stringWithFormat:@"[正在扫描图片] %@", path];
}

- (void)analysisManager:(DDAnalysisManager *)manager didHandleImageWithPath:(NSString *)path progress:(double)progress {
    self.contentLabel.stringValue = [NSString stringWithFormat:@"[%0.2f%%] %@", progress * 100, path];
}

#pragma mark - Open Finder
- (void)openFinder {
    __weak __typeof(self) weakSelf = self;
    NSOpenPanel *openPanel = [NSOpenPanel openPanel]; //快捷建立方式不用释放, 我还记得, 你呢?
    [openPanel setCanChooseDirectories:YES]; //可以打开目录
    [openPanel setCanChooseFiles:NO]; //不能打开文件(我需要处理一个目录内的所有文件)
    [openPanel beginWithCompletionHandler:^(NSInteger result){
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (result == NSFileHandlingPanelOKButton) {
            NSString *path = [[[openPanel URLs] firstObject] path];
            strongSelf.analysisManager.projectPath = path;
            strongSelf.contentLabel.stringValue = path;
            strongSelf.workFlow = DDScannerWorkFlowLoadAndAnalysis;
        }
    }];
}

#pragma mark - Work
- (void)startScanner {
    self.actionButton.enabled = NO;
    self.contentLabel.stringValue = @"正在加载, 请稍候...";

    __weak __typeof(self) weakSelf = self;
    [self.analysisManager loadAllImagesCompleted:^(BOOL succeed) {
        if (succeed) {
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf.analysisManager findSimilarImagesWithLevel:5 completed:^(BOOL succeed) {
                __strong __typeof(weakSelf) strongSelf = weakSelf;
                if (succeed) {
                    strongSelf.actionButton.enabled = YES;
                    strongSelf.contentLabel.stringValue = [NSString stringWithFormat:@"总计: %ldKB, 相似: %ldKB", strongSelf.analysisManager.totalSize, strongSelf.analysisManager.reduplicateSize];
                    strongSelf.workFlow = DDScannerWorkFlowCompleted;
                    [strongSelf.resourcesTableView reloadData];
                }
            }];
        }
    }];
}

#pragma mark - Setter
- (void)setWorkFlow:(DDScannerWorkFlow)workFlow {
    _workFlow = workFlow;

    switch (_workFlow) {
        case DDScannerWorkFlowWaitingSelectPath: {
            [self.actionButton setTitle:@"选择工程"];
            break;
        }
        case DDScannerWorkFlowCompleted: {
            [self.actionButton setTitle:@"重新开始"];
            break;
        }
        case DDScannerWorkFlowLoadAndAnalysis: {
            [self.actionButton setTitle:@"导入并分析"];
            break;
        }
    }}

#pragma mark - Getter
- (DDAnalysisManager *)analysisManager {
    if (!_analysisManager) {
        _analysisManager = [[DDAnalysisManager alloc] init];
    }
    return _analysisManager;
}
@end
