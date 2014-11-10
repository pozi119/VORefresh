//
//  VORefresh.h
//  VORefreshDemo
//
//  Created by Valo Lee on 14-11-7.
//  Copyright (c) 2014年 valo. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  刷新状态
 */
typedef NS_ENUM(NSUInteger, VORefreshState){
	VORefreshStateNormal = 1,		// 普通状态
	VORefreshStatePulling,			// 拉动中
	VORefreshStateWillRefreshing,	// 拉动超过临界点,释放即可刷新
	VORefreshStateRefreshing,		// 刷新中
};

typedef NS_ENUM(NSUInteger, VORefreshPosition) {
	VORefreshPositionTop,
	VORefreshPositionBottom,
	VORefreshPositionLeft,
	VORefreshPositionRight,
};

@interface VORefreshView : UIView


#pragma mark 子控件相关
@property (nonatomic, strong) UIView  *activityView;
@property (nonatomic, strong) UIView  *progressView;

#pragma mark 刷新内容相关
@property (nonatomic, weak  ) id  refreshingTaget;
@property (nonatomic, assign) SEL refreshingAction;

#pragma mark - 创建/初始化
- (instancetype)initWithFrame:(CGRect)frame
				   atPosition:(VORefreshPosition)position;

- (instancetype)initWithFrame:(CGRect)frame
				   atPosition:(VORefreshPosition)position
			 withActivityView:(UIView *)activityView
			  andProgressView:(UIView *)progressView
			  andRefreshTexts:(NSArray *)refreshTexts;

+ (instancetype)refreshControlWithFrame: (CGRect)frame
							 atPosition: (VORefreshPosition)position;

- (void)setRefreshTexts:(NSArray *)refreshTexts;
- (void)setRefreshText: (id)text forRefreshState: (VORefreshState)state;
#pragma mark - 刷新相关
- (BOOL)isRefreshing;
- (void)beginRefreshing;
- (void)endRefreshing;
@end


#pragma mark - 定义RefreshView子控件的可选接口,同时防止编译警告
/**
 *  ActivityView 的可选接口, ActivityView显示时调用startAnimating, 隐藏时调用stopAnimating
 */
@protocol VORefreshAcivityViewProtocol <NSObject>
@optional
- (void)startAnimating;
- (void)stopAnimating;
@end

/**
 *  ProgressView 的可选接口, 若ProgressView可以根据progress或者moveDistance渐变,则在拉动过程中可以看到渐变效果
 */
@protocol VORefreshProgressViewProtocol <NSObject>
@optional
- (void)setProgress:(CGFloat)progress;
- (void)setMoveDistance: (CGFloat)moveDistance;
@end
