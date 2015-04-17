//
//  YHReuseScrollView.h
//  ReuseScrollView
//
//  Created by zhouyehong on 15/4/7.
//  Copyright (c) 2015年 zhouyehong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YHReuseSegmentView.h"

@protocol YHReuseScrollViewDatasource;
@protocol IYHReuseScrollView;

@interface YHReuseScrollView : UIScrollView
@property(nonatomic,assign)NSInteger totalPages;
@property(nonatomic,strong)NSMutableArray *pageDatas;
@property(nonatomic,assign)id<YHReuseScrollViewDatasource> reuseViewDatasource;
@property(nonatomic,assign)YHReuseSegmentView *reuseSegmentView;

-(void)updateCurrentPage:(NSInteger)currentPage;

-(void)setTotalPages:(NSInteger)totalPages currentPage:(NSInteger)currentPage;

-(id)pageDatasWithPage:(NSInteger)page;
-(void)updatePageDatas:(id)datas withPage:(NSInteger)page;
@end

@protocol YHReuseScrollViewDatasource <NSObject>

@required
-(id<IYHReuseScrollView>)reuseView:(YHReuseScrollView*)scrollView;
@end


@protocol IYHReuseScrollView <NSObject>;
@required
@property(nonatomic,assign)NSInteger page;
@property(nonatomic,assign)YHReuseScrollView *reuseScrollView;
-(void)yhReuseScrollView:(YHReuseScrollView*)scrollView willShowPage:(NSInteger)page;
-(void)yhReuseScrollView:(YHReuseScrollView*)scrollView didShowPage:(NSInteger)page;
@end
