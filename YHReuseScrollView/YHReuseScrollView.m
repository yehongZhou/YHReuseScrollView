//
//  YHReuseScrollView.m
//  ReuseScrollView
//
//  Created by zhouyehong on 15/4/7.
//  Copyright (c) 2015年 zhouyehong. All rights reserved.
//

#import "YHReuseScrollView.h"

@interface YHReuseScrollView()<UIScrollViewDelegate>{
    NSInteger _lastDidPage;
    NSInteger _lastWillPage;
}

@property (assign, nonatomic) NSInteger currentPage;

@property (strong, nonatomic) NSMutableArray *reusableViews;
@property (strong, nonatomic) NSMutableArray *visibleViews;

@end

@implementation YHReuseScrollView
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self _init];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        [self _init];
    }
    return self;
}

-(void)_init{
    self.currentPage = NSNotFound;
    _lastDidPage = NSNotFound;
    _lastWillPage = NSNotFound;
    self.delegate = self;
    self.pagingEnabled =YES;

}

-(void)updateCurrentPage:(NSInteger)currentPage{
    self.contentOffset = CGPointMake(currentPage*self.frame.size.width, 0);
    [self _didEndScroll:self];
    [self loadPage:currentPage];
}

-(void)setTotalPages:(NSInteger)totalPages{
    _totalPages = totalPages;
    self.contentSize = CGSizeMake(self.frame.size.width*totalPages, 1);
    self.pageDatas = [NSMutableArray arrayWithCapacity:totalPages];
    for (NSInteger i=0;i<totalPages; i++) {
        [_pageDatas addObject:[NSNull null]];
    }
}

-(void)setTotalPages:(NSInteger)totalPages currentPage:(NSInteger)currentPage{
    self.totalPages = totalPages;
    [self updateCurrentPage:currentPage];
}

- (NSMutableArray *)reusableViews
{
    if (!_reusableViews) {
        _reusableViews = [NSMutableArray array];
    }
    return _reusableViews;
}

- (NSMutableArray *)visibleViews
{
    if (!_visibleViews) {
        _visibleViews = [NSMutableArray array];
    }
    return _visibleViews;
}

- (void)loadPage:(NSInteger)page{
    if (page == self.currentPage) {
        return;
    }
    self.currentPage =page;
    NSMutableArray *pagesToLoad = [@[@(page), @(page - 1), @(page + 1)] mutableCopy];
    NSMutableArray *vcsToEnqueue = [NSMutableArray array];
    for (id<IYHReuseScrollView> view in self.visibleViews) {
        if (![pagesToLoad containsObject:@(view.page)]) {
            [vcsToEnqueue addObject:view];
        } else if (view.page != NSNotFound) {
            [pagesToLoad removeObject:@(view.page)];
        }
    }
    for (id<IYHReuseScrollView> view in vcsToEnqueue) {
        [(UIView*)view removeFromSuperview];
        view.page = NSNotFound;
        [self.visibleViews removeObject:view];
        [self enqueueReusableViewController:view];
    }
    for (NSNumber *page in pagesToLoad) {
        
        [self addViewControllerForPage:[page integerValue]];
    }
}

- (void)enqueueReusableViewController:(id)view{
    [self.reusableViews addObject:view];
}

- (id)dequeueReusableViewController{
    id<IYHReuseScrollView> view = [self.reusableViews firstObject];
    if (view) {
        [self.reusableViews removeObject:view];
    } else {
        view = [self.reuseViewDatasource reuseView:self];
        view.reuseScrollView = self;
    }
    return view;
}

- (void)addViewControllerForPage:(NSInteger)page{
    if (page < 0 || page >= self.totalPages) {
        return;
    }
    id<IYHReuseScrollView> view = [self dequeueReusableViewController];
    view.page = page;
    ((UIView*)view).frame = CGRectMake(self.frame.size.width * page, 0, self.frame.size.width, self.frame.size.height);
    
    [self addSubview:(UIView*)view];
    [self.visibleViews addObject:view];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat rate = scrollView.contentOffset.x / scrollView.frame.size.width;
    NSInteger page = roundf(rate);
    page = MAX(page, 0);
    page = MIN(page, self.totalPages - 1);
    [self loadPage:page];
    NSInteger willPage = NSNotFound;
    if (rate > _lastDidPage) {
        willPage = _lastDidPage + 1;
    }else if (rate < _lastDidPage) {
        willPage = _lastDidPage - 1;
    }
    if (willPage != NSNotFound && willPage != _lastWillPage && willPage >=0 && willPage < self.totalPages) {
        _lastWillPage = willPage;
        id<IYHReuseScrollView> view = [self reuserViewByPage:willPage];
        [view yhReuseScrollView:self willShowPage:willPage];
    }
    [_reuseSegmentView updateSegmentOffx:rate];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (!decelerate) {
        [self _didEndScroll:scrollView];
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self _didEndScroll:scrollView];
}

-(void)_didEndScroll:(UIScrollView*)scrollView{
    CGFloat rate = scrollView.contentOffset.x / scrollView.frame.size.width;
    NSInteger page = roundf(rate);
    page = MAX(page, 0);
    page = MIN(page, self.totalPages - 1);
    if (page != _lastDidPage) {
        _lastDidPage = page;
        id<IYHReuseScrollView> view = [self reuserViewByPage:page];
        [view yhReuseScrollView:self didShowPage:page];
    }
}

-(id<IYHReuseScrollView>)reuserViewByPage:(NSInteger)page{
    for (id<IYHReuseScrollView> view in self.visibleViews) {
        if (view.page == page) {
            return view;
            break;
        }
    }
    return nil;
}

-(id)pageDatasWithPage:(NSInteger)page{
    id data = self.pageDatas[page];
    if ([data isKindOfClass:[NSNull class]]) {
        return nil;
    }else {
        return data;
    }
}

-(void)updatePageDatas:(id)datas withPage:(NSInteger)page{
    [self.pageDatas replaceObjectAtIndex:page withObject:datas];
}
@end
