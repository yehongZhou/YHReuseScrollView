//
//  YHReuseSegmentView.m
//  ReuseScrollView
//
//  Created by zhouyehong on 15/4/7.
//  Copyright (c) 2015年 zhouyehong. All rights reserved.
//

#import "YHReuseSegmentView.h"
#define reuse_segment_padding 10

@implementation YHReuseSegmentView{
    UIScrollView *_scrollView;
    UIView *_lineView;
    BOOL canScroll;
    NSMutableArray *btns;
    NSMutableArray *btnLayers;
}

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
    _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.backgroundColor =[UIColor lightGrayColor];
    [self addSubview:_scrollView];
    
    _lineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-2, 1, 2)];
    _lineView.backgroundColor = [UIColor redColor];
    [_scrollView addSubview:_lineView];
    _currentIndex = NSNotFound;
}

-(void)setSegmentTitles:(NSArray *)segmentTitles currentPage:(NSInteger)currendIndex{
    self.segmentTitles = segmentTitles;
    [self setCurrentIndex:currendIndex animation:NO];
}

-(void)setSegmentTitles:(NSArray *)segmentTitles{
    _segmentTitles = segmentTitles;
    [btns makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    btns = [NSMutableArray arrayWithCapacity:segmentTitles.count];
    btnLayers= [NSMutableArray arrayWithCapacity:segmentTitles.count];
    CGFloat h=self.bounds.size.height,padding=reuse_segment_padding;
    __block CGFloat offX = padding;
    [segmentTitles enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        CGSize size = CGSizeZero;
        if ([obj respondsToSelector:@selector(sizeWithAttributes:)]) {
             size = [obj sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]}];
        }else {
            size = [obj sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(MAXFLOAT, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
        }
        
        UIButton *titleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        titleBtn.frame = CGRectMake(offX, 0, size.width+2*padding, h);
        offX += (titleBtn.frame.size.width + padding);
        [_scrollView addSubview:titleBtn];
        [btns addObject:titleBtn];
        titleBtn.tag = idx;
        [titleBtn addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventTouchUpInside];
        
        CATextLayer *textLayer = [CATextLayer layer];
        textLayer.fontSize =15;
        textLayer.contentsScale = [[UIScreen mainScreen] scale];
        textLayer.rasterizationScale = [[UIScreen mainScreen] scale];
        textLayer.alignmentMode = kCAAlignmentCenter;
        [textLayer setString:obj];
        [textLayer setForegroundColor:[UIColor blackColor].CGColor];
         [textLayer setFrame:CGRectMake(0, (h-size.height)/2, titleBtn.bounds.size.width, size.height)];
         [[titleBtn layer] addSublayer:textLayer];
        [btnLayers addObject:textLayer];
        
    }];
    _scrollView.contentSize = CGSizeMake(offX, 1);
    CGFloat less = _scrollView.bounds.size.width - _scrollView.contentSize.width;
    if (less > 0) {
        _scrollView.contentInset = UIEdgeInsetsMake(0, less/2, 0, less/2);
        canScroll = NO;
    }else {
        _scrollView.contentInset = UIEdgeInsetsZero;
        canScroll = YES;
    }
}

-(void)setCurrentIndex:(NSInteger)currentIndex animation:(BOOL)animation{
    if (_currentIndex == currentIndex) {
        return;
    }
    UIButton *targetBtn = btns.count > currentIndex?btns[currentIndex]:nil;
    CATextLayer *lastBtnLayer = btnLayers.count > _currentIndex?btnLayers[_currentIndex]:nil;
    CATextLayer *targetBtnLayer = btnLayers.count > currentIndex?btnLayers[currentIndex]:nil;
    dispatch_block_t a = ^{
        CGRect frame = _lineView.frame;
        frame.size.width = targetBtn.frame.size.width;
        frame.origin.x = targetBtn.frame.origin.x;
        _lineView.frame = frame;
        
        lastBtnLayer.foregroundColor = [UIColor blackColor].CGColor;
        targetBtnLayer.foregroundColor = [UIColor redColor].CGColor;
        lastBtnLayer.transform = CATransform3DMakeScale(1, 1, 1);
        targetBtnLayer.transform = CATransform3DMakeScale(1.1, 1.1, 1);
    };
    if (animation) {
        [UIView animateWithDuration:.35 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|7<<16 animations:a completion:nil];
    }else{
        a();
    }
    self.currentIndex = currentIndex;
}

-(void)segmentAction:(UIButton*)sender{
    NSInteger tag = sender.tag;
    [self setCurrentIndex:tag animation:YES];
    [self _autoUpdateOffx];
    if (self.segmentClickAction) {
        self.segmentClickAction(_currentIndex);
    }
}

-(void)_autoUpdateOffx{
    if (canScroll) {
        UIButton *targetBtn = btns.count > _currentIndex?btns[_currentIndex]:nil;
        [_scrollView scrollRectToVisible:CGRectInset(targetBtn.frame, -4*reuse_segment_padding, 0) animated:YES];
    }
}

-(void)updateSegmentOffx:(CGFloat)offx{
    NSInteger lastIndex = floorf(offx);
    NSInteger index = roundf(offx);
    NSInteger targetIndex = ceilf(offx);
    
    float rate = offx-lastIndex;
    
    UIButton *lastBtn = btns.count > lastIndex?btns[lastIndex]:nil;
    UIButton *targetBtn = btns.count > targetIndex?btns[targetIndex]:nil;
    
    if (lastBtn && targetBtn) {
        CGRect frame = _lineView.frame;
        frame.size.width = lastBtn.frame.size.width +(targetBtn.frame.size.width-lastBtn.frame.size.width)*rate;
        frame.origin.x = lastBtn.frame.origin.x+  (targetBtn.frame.origin.x - lastBtn.frame.origin.x)*rate;
        _lineView.frame = frame;
        
        float changeRate = rate==0?1:rate;
        UIColor *lastColor = [YHReuseSegmentView evaluate:changeRate startValue:0xff0000 endValue:0x000000];
        UIColor *targetColor = [YHReuseSegmentView evaluate:changeRate startValue:0x000000 endValue:0xff0000];
        
        CATextLayer *lastBtnLayer = btnLayers.count > lastIndex?btnLayers[lastIndex]:nil;
        CATextLayer *targetBtnLayer = btnLayers.count > targetIndex?btnLayers[targetIndex]:nil;
        
        lastBtnLayer.transform = CATransform3DMakeScale(1.1-changeRate/10, 1.1-changeRate/10, 1);
        targetBtnLayer.transform = CATransform3DMakeScale(1+changeRate/10, 1+changeRate/10, 1);
        lastBtnLayer.foregroundColor = lastColor.CGColor;
        targetBtnLayer.foregroundColor = targetColor.CGColor;
        if (_currentIndex != index) {
            
            self.currentIndex = index;
            [self _autoUpdateOffx];
        }
    }
}

+(UIColor*)evaluate:(float)fraction startValue:(int)startValue endValue:(int)endValue{
    int startInt = startValue;
    int startR = (startInt >> 16) & 0xff;
    int startG = (startInt >> 8) & 0xff;
    int startB = startInt & 0xff;
    
    int endInt = endValue;
    int endR = (endInt >> 16) & 0xff;
    int endG = (endInt >> 8) & 0xff;
    int endB = endInt & 0xff;
    
    int r = hex2ten(startR + (int)(fraction * (endR - startR)));
    int g = hex2ten(startG + (int)(fraction * (endG - startG)));
    int b = hex2ten(startB + (int)(fraction * (endB - startB)));
    return [UIColor colorWithRed:(r / 255.0f) green:(g / 255.0f) blue:(b / 255.0f) alpha:1.0f];
}

int hex2ten( int x){
    int sum = 0;
    for(int i = 0 ; x!= 0; i++){
        sum = (x %16) * pow(16,i)+ sum;
        x = x/ 16;
    }
    return sum;
}

@end

