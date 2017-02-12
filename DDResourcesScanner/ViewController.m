//
//  ViewController.m
//  DDResourcesScanner
//
//  Created by 樊远东 on 6/30/16.
//  Copyright © 2016 樊远东. All rights reserved.
//

#import "ViewController.h"
#import "DDAnalysisManager.h"

static NSUInteger const kDefaultSimilarityValue = 5;

typedef NS_ENUM(NSUInteger, DDScannerWorkFlow) {
    DDScannerWorkFlowWaitingSelectPath,
    DDScannerWorkFlowLoadAndAnalysis,
    DDScannerWorkFlowCompleted,
};

@interface ViewController () <NSOutlineViewDelegate, NSOutlineViewDataSource, DDAnalysisManagerDelegate>
@property (weak) IBOutlet NSButton *actionButton;
@property (weak) IBOutlet NSTextField *contentLabel;
@property (weak) IBOutlet NSOutlineView *resourcesView;

@property (nonatomic, assign) NSUInteger similarity;//相似度

@property (nonatomic, strong) DDAnalysisManager *analysisManager;
@property (nonatomic, assign) DDScannerWorkFlow workFlow;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.similarity = kDefaultSimilarityValue;
    self.workFlow = DDScannerWorkFlowWaitingSelectPath;
    self.contentLabel.stringValue = @"";

    self.resourcesView.dataSource = self;
    self.resourcesView.delegate = self;

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

#pragma mark - NSOutlineViewDataSource
- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
//    if ([item isKindOfClass:[DDNode class]]) {
//        return ((DDNode *)item).children.count;
//    }
//    return self.analysisManager.tree.rootNode.children.count;
    if (!item) {
        return 1;
    }
    if ([item isKindOfClass:[NSArray class]]) {
        return ((NSArray *)item).count;
    }
    return 0;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(nullable id)item {
    if ([item isKindOfClass:[NSArray class]]) {
        return (NSArray *)item[index];
    }
    return self.analysisManager.images[index];
//    if ([item isKindOfClass:[DDNode class]]) {
//        return ((DDNode *)item).children[index];
//    }
//    return self.analysisManager.tree.rootNode.children[index];
}


- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    if ([item isKindOfClass:[NSArray class]]) {
        return ((NSArray *)item).count > 0;
    }
    return NO;;

//    if ([item isKindOfClass:[DDNode class]]) {
//        return (((DDNode *)item).children > 0);
//    }
//    return NO;
}

#pragma mark - NSOutlineViewDelegate
- (CGFloat)outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(id)item {
    return 40.0;
}

- (void)outlineView:(NSOutlineView *)outlineView
    willDisplayCell:(id)cell
     forTableColumn:(NSTableColumn *)tableColumn
               item:(id)item {

    NSString *identifier = tableColumn.identifier;
    if ([item isKindOfClass:[DDImageModel class]]) {
        DDImageModel *imageModel = (DDImageModel *)item;
        if (imageModel) {
            if ([identifier isEqualToString:@"kImageIdentifier"]) {
                NSImageCell *imageCell = (NSImageCell*)cell;
                imageCell.image = imageModel.image;
            }
            if ([identifier isEqualToString:@"kNameIdentifier"]) {
                NSTextFieldCell * textFieldCell = (NSTextFieldCell*)cell;
                textFieldCell.stringValue = imageModel.name;
            }
            if ([identifier isEqualToString:@"kPathIdentifier"]) {
                NSTextFieldCell * textFieldCell = (NSTextFieldCell*)cell;
                textFieldCell.stringValue = imageModel.path;
            }
            if ([identifier isEqualToString:@"kSizeIdentifier"]) {
                NSTextFieldCell * textFieldCell = (NSTextFieldCell*)cell;
                textFieldCell.stringValue = [NSString stringWithFormat:@"%0.2f", imageModel.volume / 1024.0];
            }
        }
    } else {
        if ([identifier isEqualToString:@"kNameIdentifier"]) {
            NSTextFieldCell * textFieldCell = (NSTextFieldCell*)cell;
            textFieldCell.stringValue = @"根目录";
        }
    }


//    NSString *identifier = tableColumn.identifier;
//    if ([item isKindOfClass:[DDNode class]]) {
//        DDNode *node = (DDNode *)item;
//        if (node.object) {
//            DDImageModel *imageModel = (DDImageModel *)node.object;
//            if ([identifier isEqualToString:@"kImageIdentifier"]) {
//                NSImageCell *imageCell = (NSImageCell*)cell;
//                imageCell.image = imageModel.image;
//            }
//            if ([identifier isEqualToString:@"kNameIdentifier"]) {
//                NSTextFieldCell * textFieldCell = (NSTextFieldCell*)cell;
//                textFieldCell.stringValue = imageModel.name;
//            }
//            if ([identifier isEqualToString:@"kPathIdentifier"]) {
//                NSTextFieldCell * textFieldCell = (NSTextFieldCell*)cell;
//                textFieldCell.stringValue = imageModel.path;
//            }
//            if ([identifier isEqualToString:@"kSizeIdentifier"]) {
//                NSTextFieldCell * textFieldCell = (NSTextFieldCell*)cell;
//                textFieldCell.stringValue = [NSString stringWithFormat:@"%0.2f", imageModel.volume / 1024.0];
//            }
//        }
//    } else {
//        if ([identifier isEqualToString:@"kNameIdentifier"]) {
//            NSTextFieldCell * textFieldCell = (NSTextFieldCell*)cell;
//            textFieldCell.stringValue = @"根目录";
//        }
//    }
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldExpandItem:(id)item {
    return [outlineView isExpandable:item];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item {
    return (!!item);
}

#pragma mark - DDAnalysisManagerDelegate
- (void)analysisManager:(DDAnalysisManager *)manager didScanningImageWithPath:(NSString *)path {
    self.contentLabel.stringValue = [NSString stringWithFormat:@"[正在扫描图片] %@", path];
}

- (void)analysisManager:(DDAnalysisManager *)manager didHandleImageWithPath1:(NSString *)path1 path2:(NSString *)path2 {
    self.contentLabel.stringValue = [NSString stringWithFormat:@"[正在寻找相似图片] %@", path1];
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
            [strongSelf.analysisManager findSimilarImagesWithLevel:self.similarity
                                                         completed:^(BOOL succeed) {

                __strong __typeof(weakSelf) strongSelf = weakSelf;
                if (succeed) {
                    strongSelf.actionButton.enabled = YES;
                    strongSelf.contentLabel.stringValue = [NSString stringWithFormat:@"总计: %lldKB, 相似: %lldKB", strongSelf.analysisManager.total / 1024, strongSelf.analysisManager.similarity / 1024];
                    strongSelf.workFlow = DDScannerWorkFlowCompleted;
                    [strongSelf.resourcesView reloadData];
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
