//
//  UIScrollView+VORefresh.m
//  VORefreshDemo
//
//  Created by Valo Lee on 14-11-8.
//  Copyright (c) 2014年 valo. All rights reserved.
//

#import "UIScrollView+VORefresh.h"
#import <objc/runtime.h>

@interface UIScrollView ()

@end

static char VOTopRefreshViewKey;
static char VOBottomRefreshViewKey;
static char VOLeftRefreshViewKey;
static char VORightRefreshViewKey;

@implementation UIScrollView (VORefresh)

- (void)setTopRefresh:(VORefreshView *)topRefresh{
	[self willChangeValueForKey:@"VOTopRefreshViewKey"];
	objc_setAssociatedObject(self, &VOTopRefreshViewKey,
							 topRefresh,
							 OBJC_ASSOCIATION_ASSIGN);
	[self didChangeValueForKey:@"VOTopRefreshViewKey"];
}

- (VORefreshView *)topRefresh{
	return objc_getAssociatedObject(self, &VOTopRefreshViewKey);
}

- (void)setBottomRefresh:(VORefreshView *)bottomRefresh{
	[self willChangeValueForKey:@"VOBottomRefreshViewKey"];
	objc_setAssociatedObject(self, &VOBottomRefreshViewKey,
							 bottomRefresh,
							 OBJC_ASSOCIATION_ASSIGN);
	[self didChangeValueForKey:@"VOBottomRefreshViewKey"];
}

- (VORefreshView *)bottomRefresh{
	return objc_getAssociatedObject(self, &VOBottomRefreshViewKey);
}

- (void)setLeftRefresh:(VORefreshView *)leftRefresh{
	[self willChangeValueForKey:@"VOLeftRefreshViewKey"];
	objc_setAssociatedObject(self, &VOLeftRefreshViewKey,
							 leftRefresh,
							 OBJC_ASSOCIATION_ASSIGN);
	[self didChangeValueForKey:@"VOLeftRefreshViewKey"];
}

- (VORefreshView *)leftRefresh{
	return objc_getAssociatedObject(self, &VOLeftRefreshViewKey);
}

- (void)setRightRefresh:(VORefreshView *)rightRefresh{
	[self willChangeValueForKey:@"VORightRefreshViewKey"];
	objc_setAssociatedObject(self, &VORightRefreshViewKey,
							 rightRefresh,
							 OBJC_ASSOCIATION_ASSIGN);
	[self didChangeValueForKey:@"VORightRefreshViewKey"];
}

- (VORefreshView *)rightRefresh{
	return objc_getAssociatedObject(self, &VORightRefreshViewKey);
}

- (void)addRefreshAtPostion:(VORefreshPosition)position
		   withActivityView:(UIView *)activityView
			andProgressView:(UIView *)progressView
			andRefreshTexts:(NSArray *)refreshTexts
					 target:(id)target
					 action:(SEL)action{
	VORefreshView *refreshView = [[VORefreshView alloc] initWithFrame:self.bounds atPosition:position withActivityView:activityView andProgressView:progressView andRefreshTexts:refreshTexts];
	refreshView.refreshingTaget = target;
	refreshView.refreshingAction = action;
	[self addSubview:refreshView];
	switch (position) {
		case VORefreshPositionTop:
			self.topRefresh = refreshView;
			break;
		case VORefreshPositionBottom:
			self.bottomRefresh = refreshView;
			break;
		case VORefreshPositionLeft:
			self.leftRefresh = refreshView;
			break;
		case VORefreshPositionRight:
			self.rightRefresh = refreshView;
			break;
		default:
			break;
	}
}

- (void)addTopRefreshWithTarget:(id)target
						 action:(SEL)action{
	VORefreshView *refreshView = [VORefreshView refreshControlWithFrame:self.bounds atPosition:VORefreshPositionTop];
	refreshView.refreshingTaget = target;
	refreshView.refreshingAction = action;
	[self addSubview:refreshView];
	self.topRefresh = refreshView;
}

- (void)removeTopRefresh{
	[self.topRefresh removeFromSuperview];
}

- (void)addBottomRefreshWithTarget:(id)target
						 action:(SEL)action{
	VORefreshView *refreshView = [VORefreshView refreshControlWithFrame:self.bounds atPosition:VORefreshPositionBottom];
	refreshView.refreshingTaget = target;
	refreshView.refreshingAction = action;
	[self addSubview:refreshView];
	self.bottomRefresh = refreshView;
}

- (void)removeBottomRefresh{
	[self.bottomRefresh removeFromSuperview];
}

- (void)addLeftRefreshWithTarget:(id)target
						  action:(SEL)action{
	VORefreshView *refreshView = [VORefreshView refreshControlWithFrame:self.bounds atPosition:VORefreshPositionLeft];
	refreshView.refreshingTaget = target;
	refreshView.refreshingAction = action;
	[self addSubview:refreshView];
	self.leftRefresh = refreshView;
}

- (void)removeLeftRefresh{
	[self.leftRefresh removeFromSuperview];
}

- (void)addRightRefreshWithTarget:(id)target
						   action:(SEL)action{
	VORefreshView *refreshView = [VORefreshView refreshControlWithFrame:self.bounds atPosition:VORefreshPositionRight];
	refreshView.refreshingTaget = target;
	refreshView.refreshingAction = action;
	[self addSubview:refreshView];
	self.rightRefresh = refreshView;
}

- (void)removeRightRefresh{
	[self.rightRefresh removeFromSuperview];
}

@end
