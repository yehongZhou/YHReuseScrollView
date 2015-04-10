//
//  ViewController.m
//  ReuseScrollView
//
//  Created by zhouyehong on 15/4/7.
//  Copyright (c) 2015年 zhouyehong. All rights reserved.
//

#import "ViewController.h"
#import "YHReuseSegmentView.h"
#import "YHReuseScrollView.h"
#import "TestTableView.h"

@interface ViewController ()<YHReuseScrollViewDatasource>
@property (weak, nonatomic) IBOutlet YHReuseSegmentView *segView;
@property (weak, nonatomic) IBOutlet YHReuseScrollView *scrollView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.modalPresentationCapturesStatusBarAppearance = NO;
    }
    
    NSArray *titles = @[@"title0",@"t1",@"reuse scrollview2",@"test title3",@"title4",@"page5"];
    NSInteger defalutPage = 1;
    

    [_segView setSegmentTitles:titles currentPage:defalutPage];
    __weak typeof(self) _self = self;
    _segView.segmentClickAction = ^(NSInteger page){
        [_self.scrollView updateCurrentPage:page];
    };
    
    _scrollView.reuseViewDatasource = self;
    [_scrollView setTotalPages:titles.count currentPage:defalutPage];
    _scrollView.reuseSegmentView = _segView;
}


-(id<IYHReuseScrollView>)reuseView:(YHReuseScrollView*)scrollView{
    TestTableView *tableView = [[TestTableView alloc] initWithFrame:scrollView.bounds];
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    return tableView;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
