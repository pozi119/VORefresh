//
//  VODemoCollectionViewController.m
//  VORefreshDemo
//
//  Created by Valo Lee on 14-11-8.
//  Copyright (c) 2014年 valo. All rights reserved.
//

#import "VODemoCollectionViewController.h"
#import "VODemoCell.h"
#import "UIScrollView+VORefresh.h"

@interface VODemoCollectionViewController ()
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSDate *loadTime;
@property (nonatomic, assign) NSTimeInterval inc;

@end

@implementation VODemoCollectionViewController

- (void)viewDidLoad{
	self.dataArray = [NSMutableArray array];
	self.loadTime = [NSDate date];
	[self.dataArray addObject:[self timeToString:self.loadTime]];
	[self.collectionView addLeftRefreshWithTarget:self action:@selector(leftRefreshing)];
	[self.collectionView addRightRefreshWithTarget:self action:@selector(rightRefreshing)];
#warning 自定义刷新控件, 测试时可以自动调整
	self.collectionView.leftRefresh.refreshTexts = nil;
	[self.collectionView.leftRefresh setRefreshText:@"啊啊啊..." forRefreshState:VORefreshStateRefreshing];
	self.collectionView.leftRefresh.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	self.collectionView.rightRefresh.refreshTexts = @[@"正常状态", @"拉动状态", @"准备状态", @"加载状态"];
}

- (void)leftRefreshing{
	[self.dataArray insertObject:[self timeToString:[NSDate date]] atIndex:0];
	// 模拟加载延迟
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[self.collectionView reloadData];
#warning 修改指定状态的刷新文字,可以设置显示上次刷新时间.
		NSString *str = @"下拉刷新内容";
		NSString *timeStr =[NSString stringWithFormat:@"\n最后刷新时间: %@", self.dataArray[0]];
		NSMutableAttributedString *attributeTimeStr = [[NSMutableAttributedString alloc] initWithString: [NSString stringWithFormat:@"%@%@",str, timeStr]];
		[attributeTimeStr addAttribute:NSForegroundColorAttributeName value:[UIColor purpleColor] range:NSMakeRange(0, str.length)];
		[attributeTimeStr addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(str.length, timeStr.length)];
		[self.collectionView.leftRefresh setRefreshText:attributeTimeStr forRefreshState:VORefreshStatePulling];
#warning 加载结束需要结束刷新状态
		[self.collectionView.leftRefresh endRefreshing];
	});
}

- (void)rightRefreshing{
	self.inc += 88;
	[self.dataArray addObject:[self timeToString:[self.loadTime dateByAddingTimeInterval:-self.inc]]];
	// 模拟加载延迟
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[self.collectionView reloadData];
		[self.collectionView.rightRefresh endRefreshing];
	});
}

- (NSString *)timeToString: (NSDate *)time{
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.dateFormat = @"HH:mm:ss";
	NSString *timeStr = [formatter stringFromDate:time];
	return timeStr;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
	return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
	VODemoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[VODemoCell reuseIdentifier] forIndexPath:indexPath];
	cell.text = self.dataArray[indexPath.row];
	return cell;
}

@end
