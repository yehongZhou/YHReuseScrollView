# YHReuseScrollView
iOS,Reuse UIScrollView

 ![image](https://github.com/yehongZhou/YHReuserScrollView/blob/master/screenshot.gif)
 
Usage：

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
