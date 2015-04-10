//
//  TestTableView.m
//  ReuseScrollView
//
//  Created by zhouyehong on 15/4/8.
//  Copyright (c) 2015年 zhouyehong. All rights reserved.
//

#import "TestTableView.h"

@interface TestTableView ()<UITableViewDataSource>

@end

@implementation TestTableView{
    NSArray *datas;
}

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.dataSource = self;
    }
    return self;
}

-(void)yhReuseScrollView:(YHReuseScrollView*)scrollView willShowPage:(NSInteger)page{
    NSLog(@"will show:%zd",page);
    id data = [scrollView pageDatasWithPage:page];
    datas = data;
    [self reloadData];
}

-(void)yhReuseScrollView:(YHReuseScrollView*)scrollView didShowPage:(NSInteger)page{
    NSLog(@"did show:%zd",page);
    id data = [scrollView pageDatasWithPage:page];
    if (!data) {
        [self loadData:page];
    }else {
        datas = data;
        [self reloadData];
    }
}

-(void)loadData:(NSInteger)page{
    int testCount = arc4random() % 20 + 2;
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:testCount];
    for (int i=0; i<testCount; i++) {
        [result addObject:[NSString stringWithFormat:@"%zd-%d",self.page,i]];
    }
    datas = result;
    [self reloadData];
    [self.reuseScrollView updatePageDatas:result withPage:self.page];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return datas.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:0 reuseIdentifier:nil];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = datas[indexPath.row];
    return cell;
}

@end
