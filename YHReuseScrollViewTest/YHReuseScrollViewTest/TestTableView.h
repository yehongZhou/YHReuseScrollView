//
//  TestTableView.h
//  ReuseScrollView
//
//  Created by zhouyehong on 15/4/8.
//  Copyright (c) 2015年 zhouyehong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YHReuseScrollView.h"

@interface TestTableView : UITableView<IYHReuseScrollView>
@property(nonatomic,assign)NSInteger page;
@property(nonatomic,assign)YHReuseScrollView *reuseScrollView;
@end
