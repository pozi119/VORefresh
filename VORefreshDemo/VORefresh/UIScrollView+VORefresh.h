//
//  UIScrollView+VORefresh.h
//  VORefreshDemo
//
//  Created by Valo Lee on 14-11-8.
//  Copyright (c) 2014年 valo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VORefreshView.h"

@interface UIScrollView (VORefresh)

@property (nonatomic, weak) VORefreshView *topRefresh;
@property (nonatomic, weak) VORefreshView *bottomRefresh;
@property (nonatomic, weak) VORefreshView *leftRefresh;
@property (nonatomic, weak) VORefreshView *rightRefresh;

#pragma mark - 自定义位置和子控件
- (void)addRefreshAtPostion:(VORefreshPosition)position
		   withActivityView:(UIView *)activityView
			andProgressView:(UIView *)progressView
			andRefreshTexts:(NSArray *)refreshTexts
					 target:(id)target
					 action:(SEL)action;

#pragma mark - 上
- (void)addTopRefreshWithTarget:(id)target
						 action:(SEL)action;

- (void)removeTopRefresh;

#pragma mark - 下
- (void)addBottomRefreshWithTarget:(id)target
						 action:(SEL)action;

- (void)removeBottomRefresh;

#pragma mark - 左
- (void)addLeftRefreshWithTarget:(id)target
						  action:(SEL)action;

- (void)removeLeftRefresh;

#pragma mark - 右
- (void)addRightRefreshWithTarget:(id)target
						   action:(SEL)action;
- (void)removeRightRefresh;

@end
