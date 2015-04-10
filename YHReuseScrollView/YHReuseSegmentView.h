//
//  YHReuseSegmentView.h
//  ReuseScrollView
//
//  Created by zhouyehong on 15/4/7.
//  Copyright (c) 2015年 zhouyehong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YHReuseSegmentView : UIView
@property(nonatomic,copy)NSArray *segmentTitles;

@property(nonatomic,assign)NSInteger currentIndex;
@property(nonatomic,copy)void (^segmentClickAction)(NSInteger currentPage);

-(void)updateSegmentOffx:(CGFloat)offx;

-(void)setSegmentTitles:(NSArray *)segmentTitles currentPage:(NSInteger)currendIndex;
@end
