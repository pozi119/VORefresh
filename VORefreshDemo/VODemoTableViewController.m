//
//  VODemoTableViewController.m
//  VORefreshDemo
//
//  Created by Valo Lee on 14-11-8.
//  Copyright (c) 2014年 valo. All rights reserved.
//

#import "VODemoTableViewController.h"
#import "UIScrollView+VORefresh.h"

@interface VODemoTableViewController ()

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSDate *loadTime;
@property (nonatomic, assign) NSTimeInterval inc;
@end

@implementation VODemoTableViewController

- (void)viewDidLoad{
	self.dataArray = [NSMutableArray array];
	self.loadTime = [NSDate date];
	[self.dataArray addObject:[self timeToString:self.loadTime]];
	[self.tableView addTopRefreshWithTarget:self action:@selector(topRefreshing)];
	[self.tableView addBottomRefreshWithTarget:self action:@selector(bottomRefreshing)];
#warning 自定义刷新控件, 测试时可以自动调整
#if 0 //有文字内容时, progressView和ActivityView的center是superView 1/4宽度位置,若progressView过宽会不好看
	self.tableView.bottomRefresh.progressView = [[UIProgressView alloc] initWithFrame:self.tableView.bottomRefresh.bounds];
	self.tableView.bottomRefresh.refreshTexts = nil;
#else
	CGRect frame = self.tableView.bottomRefresh.bounds;
	frame.size.width /= 4;
	self.tableView.bottomRefresh.progressView = [[UIProgressView alloc] initWithFrame:frame];
	[self.tableView.bottomRefresh setRefreshText:nil forRefreshState:VORefreshStatePulling];
#endif
#warning 下拉文字可以使用NSAttributedString的数组,使用NSAttributedString可以自定义颜色大小之类的. 上下拉动时显示文字的UILabel设置的是2行(如果是左右拉动则设置的0),
	NSMutableAttributedString *str1 = [[NSMutableAttributedString alloc] initWithString:@"下拉刷新内容"];
	NSMutableAttributedString *str2 = [[NSMutableAttributedString alloc] initWithString:@"下拉刷新内容"];
	NSMutableAttributedString *str3 = [[NSMutableAttributedString alloc] initWithString:@"释放立即刷新"];
	NSMutableAttributedString *str4 = [[NSMutableAttributedString alloc] initWithString:@"刷新中..."];
	[str1 addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, str1.length)];
	[str2 addAttribute:NSForegroundColorAttributeName value:[UIColor purpleColor] range:NSMakeRange(0, str2.length)];
	[str3 addAttribute:NSForegroundColorAttributeName value:[UIColor brownColor] range:NSMakeRange(0, str3.length)];
	[str4 addAttribute:NSForegroundColorAttributeName value:[UIColor orangeColor] range:NSMakeRange(0, str4.length)];
	self.tableView.topRefresh.refreshTexts = @[str1, str2, str3, str4];
}

- (void)topRefreshing{
	[self.dataArray insertObject:[self timeToString:[NSDate date]] atIndex:0];
	// 模拟加载延迟
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[self.tableView reloadData];
#warning 修改指定状态的刷新文字,可以设置显示上次刷新时间.
		NSString *str = @"下拉刷新内容";
		NSString *timeStr =[NSString stringWithFormat:@"\n最后刷新时间: %@", self.dataArray[0]];
		NSMutableAttributedString *attributeTimeStr = [[NSMutableAttributedString alloc] initWithString: [NSString stringWithFormat:@"%@%@",str, timeStr]];
		[attributeTimeStr addAttribute:NSForegroundColorAttributeName value:[UIColor purpleColor] range:NSMakeRange(0, str.length)];
		[attributeTimeStr addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(str.length, timeStr.length)];
		[self.tableView.topRefresh setRefreshText:attributeTimeStr forRefreshState:VORefreshStatePulling];
#warning 加载结束需要结束刷新状态
		[self.tableView.topRefresh endRefreshing];
	});
}

- (void)bottomRefreshing{
	self.inc += 88;
	[self.dataArray addObject:[self timeToString:[self.loadTime dateByAddingTimeInterval:-self.inc]]];
	// 模拟加载延迟
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[self.tableView reloadData];
		[self.tableView.bottomRefresh endRefreshing];
	});
}

- (NSString *)timeToString: (NSDate *)time{
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.dateFormat = @"HH:mm:ss";
	NSString *timeStr = [formatter stringFromDate:time];
	return timeStr;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	static NSString *cellReuseIdentifer = @"demoTableViewCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifer];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellReuseIdentifer];
	}
	cell.textLabel.text = [@(indexPath.row) stringValue];
	cell.detailTextLabel.text = self.dataArray[indexPath.row];
	return cell;
}

@end
