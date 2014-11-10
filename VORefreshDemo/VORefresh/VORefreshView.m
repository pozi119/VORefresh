//
//  VORefresh.m
//  VORefreshDemo
//
//  Created by Valo Lee on 14-11-7.
//  Copyright (c) 2014年 valo. All rights reserved.
//

#import "VORefreshView.h"
#import "VORingIndicator.h"
#import "VORingProgressView.h"

#pragma mark - 防止[self performSelector:sel]警告
#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

@interface VORefreshView ()
#pragma mark 父控件
@property (nonatomic, weak, readonly  ) UIScrollView *scrollView;
@property (nonatomic, assign, readonly) UIEdgeInsets scrollViewOriginalInset;

@end

const CGFloat VORefreshViewLength      = 64.0;
const CGFloat VORefreshViewPullLength  = 64.0;
const CGFloat VORefreshDuration        = 0.3;
NSString *const VORefreshContentOffset = @"contentOffset";
NSString *const VORefreshContentSize   = @"contentSize";

// 如果RefreshView是竖着的(左右拉动刷新)
#define SELF_IS_ERECT ((self.position == VORefreshPositionLeft) || (self.position == VORefreshPositionRight))
// 如果RefreshView是在前面(在上边和左边)
#define SELF_IN_FRONT ((self.position == VORefreshPositionTop) || (self.position == VORefreshPositionLeft))

@interface VORefreshView ()
@property (nonatomic, assign) VORefreshPosition   position;
@property (nonatomic, strong) UILabel             *stateLabel;
@property (nonatomic, assign) VORefreshState      state;
@property (nonatomic, strong) NSMutableDictionary *refreshTextDic;
@end

@implementation VORefreshView

+ (NSArray *)defaultRefreshTexts{
	return @[@"拉动加载更多",
			 @"拉动加载更多",
			 @"释放立即加载",
			 @"加载中..."];
}

- (instancetype)initWithFrame:(CGRect)frame
				   atPosition:(VORefreshPosition)position{
	return [self initWithFrame:frame atPosition:position withActivityView:nil andProgressView:nil andRefreshTexts:nil];
}

- (instancetype)initWithFrame:(CGRect)frame
				   atPosition:(VORefreshPosition)position
			 withActivityView:(UIView *)activityView
			  andProgressView:(UIView *)progressView
			  andRefreshTexts:(NSArray *)refreshTexts{
	self.position = position;
	if (position == VORefreshPositionLeft || position == VORefreshPositionRight) {
		frame.size.width = VORefreshViewLength;
	}
	else{
		frame.size.height = VORefreshViewLength;
	}
	self = [super initWithFrame:frame];
	if (self) {
		// 1.自己的属性
        self.backgroundColor  = [UIColor clearColor];
        self.position         = position;
        self.activityView     = activityView;
        self.progressView     = progressView;
        self.refreshTexts     = refreshTexts;
		// 2.设置默认状态
		self.state = VORefreshStateNormal;
	}
	return self;
}

+ (instancetype)refreshControlWithFrame: (CGRect)frame atPosition: (VORefreshPosition)position{
    VORingIndicator *indicator       = [[VORingIndicator alloc] init];
    VORingProgressView *progressView = [[VORingProgressView alloc] init];
	return [[VORefreshView alloc] initWithFrame:frame atPosition:position withActivityView:indicator andProgressView:progressView andRefreshTexts:[VORefreshView defaultRefreshTexts]];
}

#pragma mark - 重写set/get方法
- (UILabel *)stateLabel {
	if (!_stateLabel) {
        UILabel *stateLabel        = [[UILabel alloc] init];
        stateLabel.font            = [UIFont boldSystemFontOfSize:13];
        stateLabel.textColor       = [UIColor grayColor];
        stateLabel.backgroundColor = [UIColor clearColor];
        stateLabel.textAlignment   = NSTextAlignmentCenter;
        stateLabel.numberOfLines   = 2;
        _stateLabel                = stateLabel;
		[self addSubview: _stateLabel];
	}
	return _stateLabel;
}

- (void)setActivityView:(UIView *)activityView{
	[_activityView removeFromSuperview];
	if (activityView) {
		[self addSubview:activityView];
	}
	_activityView = activityView;
}

- (void)setProgressView:(UIView *)progressView{
	[_progressView removeFromSuperview];
	if (progressView) {
		[self addSubview:progressView];
	}
	_progressView = progressView;
}

- (NSMutableDictionary *)refreshTextDic{
	if (!_refreshTextDic) {
		_refreshTextDic = [NSMutableDictionary dictionary];
	}
	return _refreshTextDic;
}

- (void)setRefreshTexts:(NSArray *)refreshTexts{
	[self.refreshTextDic removeAllObjects];
	if (refreshTexts) {
		for (NSInteger i = 0; i < refreshTexts.count; i ++) {
			[self setRefreshText:refreshTexts[i] forRefreshState:i + VORefreshStateNormal];
		}
	}
}

- (void)setRefreshText: (id)text forRefreshState: (VORefreshState)state{
	if ([text isKindOfClass:[NSString class]]) {
		self.refreshTextDic[@(state)] = text;
	}
	else if([text isKindOfClass:[NSAttributedString class]]){
		self.refreshTextDic[@(state)] = text;
	}
	else{
		[self.refreshTextDic removeObjectForKey:@(state)];
	}
}

#pragma mark - 显示相关
- (void)layoutSubviews{
	[super layoutSubviews];
	
	CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
	// 设置stateLabel
	self.stateLabel.frame = self.bounds;
	if (SELF_IS_ERECT) {
		self.stateLabel.transform = CGAffineTransformMakeRotation(M_PI_2 * (SELF_IN_FRONT ? -1: 1));
	}
	else{
	}
	// 设置activityView和progressView
	if (self.activityView) {
		self.activityView.center = center;
	}
	if (self.progressView) {
		self.progressView.center = center;
	}
}

- (void)willMoveToSuperview:(UIView *)newSuperview{
	[super willMoveToSuperview:newSuperview];
	
	// 旧的父控件
	[self.superview removeObserver:self forKeyPath:VORefreshContentOffset context:nil];
	[self.superview removeObserver:self forKeyPath:VORefreshContentSize context:nil];
	
	if (newSuperview) { // 新的父控件
		// 记录UIScrollView
		_scrollView = (UIScrollView *)newSuperview;
		// 记录UIScrollView最开始的contentInset
		_scrollViewOriginalInset = self.scrollView.contentInset;
		[newSuperview addObserver:self forKeyPath:VORefreshContentOffset options:NSKeyValueObservingOptionNew context:nil];
		[newSuperview addObserver:self forKeyPath:VORefreshContentSize options:NSKeyValueObservingOptionNew context:nil];
		[self adjustFrame];
	}
}

- (void)adjustFrame{
	CGRect frame = self.frame;
	if (SELF_IS_ERECT) {
		CGFloat contentWidth = self.scrollView.contentSize.width;
		CGFloat scrollWidth = self.scrollView.bounds.size.width - self.scrollViewOriginalInset.left - self.scrollViewOriginalInset.right;
		frame.size.width = VORefreshViewLength;
		frame.origin.x = SELF_IN_FRONT ? -self.bounds.size.width: MAX(contentWidth, scrollWidth);
		frame.origin.y = 0;
		frame.size.height = self.scrollView.bounds.size.height;
		self.frame = frame;
	}
	else{
		CGFloat contentHeight = self.scrollView.contentSize.height;
		CGFloat scrollHeight = self.scrollView.bounds.size.height - self.scrollViewOriginalInset.top - self.scrollViewOriginalInset.bottom;
		frame.size.height = VORefreshViewLength;
		frame.origin.x = 0;
		frame.origin.y = SELF_IN_FRONT ? -self.bounds.size.height: MAX(contentHeight, scrollHeight);
		frame.size.width = self.scrollView.bounds.size.width;
		self.frame = frame;
	}
}

#pragma mark scrollView内容 超出 内容显示大小 的长度
- (CGFloat)exceedLength{
	CGFloat exceeded;
	if(SELF_IS_ERECT){
		exceeded = self.scrollView.contentSize.width - (self.scrollView.frame.size.width - self.scrollViewOriginalInset.right - self.scrollViewOriginalInset.left);
	}
	else{
		exceeded = self.scrollView.contentSize.height - (self.scrollView.frame.size.height - self.scrollViewOriginalInset.bottom - self.scrollViewOriginalInset.top);
	}
	return exceeded;
}

#pragma mark 刚开始显示RefreshView时,scrollView.contentOffset的x值或者y值
- (CGFloat)willappearOffsetXorY{
	CGFloat willappear;
	if (SELF_IN_FRONT) {
		willappear = SELF_IS_ERECT ? - self.scrollViewOriginalInset.left : - self.scrollViewOriginalInset.top;
	}
	else{
		if (SELF_IS_ERECT) {
			CGFloat contentWidth = self.scrollView.contentSize.width;
			CGFloat scrollWidth = self.scrollView.bounds.size.width - self.scrollViewOriginalInset.left - self.scrollViewOriginalInset.right;
			willappear = MAX(contentWidth, scrollWidth) - self.scrollView.bounds.size.width;
		}
		else{
			CGFloat contentHeight = self.scrollView.contentSize.height;
			CGFloat scrollHeight = self.scrollView.bounds.size.height - self.scrollViewOriginalInset.top - self.scrollViewOriginalInset.bottom;
			willappear = MAX(contentHeight, scrollHeight) - self.scrollView.bounds.size.height;
		}
	}
	return willappear;
}
#pragma mark RefreshView完全显示时,scrollView.contentOffset的x值或者y值
- (CGFloat)didappearOffsetXorY{
	if (SELF_IN_FRONT) {
		return -([self willappearOffsetXorY] + VORefreshViewLength);
	}
	else{
		if ([self exceedLength] > 0) {
			return [self willappearOffsetXorY] + VORefreshViewLength;
		}
		else{
			return [self willappearOffsetXorY] + VORefreshViewLength;
		}
	}
}

#pragma mark Refresh显示过程中scrollView.contentOffset的x值或者y值
- (CGFloat)moveDistanceForContentOffset{
	CGFloat moveDistance;
	CGFloat willappear = [self willappearOffsetXorY];
	if (SELF_IN_FRONT) {
		moveDistance = SELF_IS_ERECT ? (willappear - self.scrollView.contentOffset.x) : (willappear - self.scrollView.contentOffset.y);
	}else{
		moveDistance = SELF_IS_ERECT ? (self.scrollView.contentOffset.x - willappear) : (self.scrollView.contentOffset.y - willappear);
	}
	return moveDistance;
}

#pragma mark 根据移动进度调整RefreshView的状态
- (void)adjustState{
	if (self.scrollView.dragging) {
        CGFloat movedistance = [self moveDistanceForContentOffset];
        CGFloat progress     = movedistance / VORefreshViewLength;
		if (self.progressView){
			if ([self.progressView respondsToSelector:@selector(setProgress:)]) {
				[self.progressView setValue:@(progress) forKey:@"progress"];
			}
			if ([self.progressView respondsToSelector:@selector(setMoveDistance:)]) {
				[self.progressView setValue:@(movedistance) forKey:@"moveDistance"];
			}
		}
		if (progress < 0) {
			self.state = VORefreshStateNormal;
		}
		else if(progress > 1){
			self.state = VORefreshStateWillRefreshing;
		}
		else{
			self.state = VORefreshStatePulling;
		}
	}
	else if(self.state == VORefreshStateWillRefreshing){
		self.state = VORefreshStateRefreshing;
	}
}


#pragma mark 监听UIScrollView的属性
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	// 不能跟用户交互就直接返回
	if (!self.userInteractionEnabled || self.alpha <= 0.01 || self.hidden) return;
	
	// 当屏幕旋转时,也会调整contentSize
	if ([VORefreshContentSize isEqualToString:keyPath]) {
		[self adjustFrame];
	}
	
	if ([VORefreshContentOffset isEqualToString:keyPath]) {
		if (self.state == VORefreshStateRefreshing) return;
		[self adjustState];
	}
}
- (void)adjustSubViewFrame{
	CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
	// 设置stateLabel
	id text = self.refreshTextDic[@(self.state)];
	if (text) {
		if ([text isKindOfClass:[NSString class]]) {
			self.stateLabel.text = text;
		}
		else if([text isKindOfClass:[NSAttributedString class]]){
			self.stateLabel.attributedText = text;
		}
		self.stateLabel.hidden = NO;
		// 设置activityView和progressView
		center = SELF_IS_ERECT ? CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMaxY(self.bounds) / 4) : CGPointMake(CGRectGetMaxX(self.bounds) / 4, CGRectGetMidY(self.bounds));
	}
	else{
		self.stateLabel.hidden = YES;
	}
	
	if (self.activityView) {
		self.activityView.center = center;
	}
	if (self.progressView) {
		self.progressView.center = center;
	}
}

#pragma mark - 设置状态
- (void)setState:(VORefreshState)state {
	// 0.存储当前的contentInset
	if (_state != VORefreshStateRefreshing) {
		_scrollViewOriginalInset = self.scrollView.contentInset;
	}
	// 1.一样的就直接返回
	if (_state == state) return;
	
	VORefreshState oldState = _state;
	_state = state;					// 接下来的操作会改动contentOffset或者contentSize,必须先保存状态,否则会进入死循环
	
	[self adjustSubViewFrame];
	
	// 2.根据状态执行不同的操作
	switch (state) {
		case VORefreshStateNormal: // 普通状态
		{
			if (self.activityView) {
				self.activityView.hidden = YES;
				if ([self.activityView respondsToSelector:@selector(stopAnimating)]) {
					[self.activityView performSelector:@selector(stopAnimating)];
				}
			}
			if (self.progressView) {
				self.progressView.hidden = NO;
			}
			if (VORefreshStateRefreshing == oldState) {
				[UIView animateWithDuration:VORefreshDuration animations:^{
					// 不论是哪个位置的RefreshView,恢复normal状态时都恢复之前的contentInset
					self.scrollView.contentInset = self.scrollViewOriginalInset;
				}];
			}
		}
			break;
			
		case VORefreshStatePulling:
			break;
			
		case VORefreshStateWillRefreshing:
			break;
			
		case VORefreshStateRefreshing:
		{
			if (self.activityView) {
				self.activityView.hidden = NO;
				if ([self.activityView respondsToSelector:@selector(startAnimating)]) {
					SuppressPerformSelectorLeakWarning([self.activityView performSelector:@selector(startAnimating)]);					
				}
			}
			if (self.progressView) {
				self.progressView.hidden = YES;
			}
			
			if (self.refreshingTaget &&  [self.refreshingTaget respondsToSelector:self.refreshingAction]) {
				SuppressPerformSelectorLeakWarning([self.refreshingTaget performSelector:self.refreshingAction]);
			}
			[UIView animateWithDuration:VORefreshDuration animations:^{
				if (SELF_IN_FRONT) {
					if (SELF_IS_ERECT) {
						// 1.增加滚动区域
						CGFloat left = self.scrollViewOriginalInset.left + self.frame.size.width;
						UIEdgeInsets contentInset = self.scrollView.contentInset;
						contentInset.left = left;
						self.scrollView.contentInset = contentInset;
						
						// 2.设置滚动位置
						CGPoint contentOffset = self.scrollView.contentOffset;
						contentOffset.x = -left;
						self.scrollView.contentOffset = contentOffset;
					}
					else{
						// 1.增加滚动区域
						CGFloat top = self.scrollViewOriginalInset.top + self.frame.size.height;
						UIEdgeInsets contentInset = self.scrollView.contentInset;
						contentInset.top = top;
						self.scrollView.contentInset = contentInset;
					
						// 2.设置滚动位置
						CGPoint contentOffset = self.scrollView.contentOffset;
						contentOffset.y = -top;
						self.scrollView.contentOffset = contentOffset;
					}
				}
				else{
					if (SELF_IS_ERECT) {
						// 1.增加滚动区域
						CGFloat right = self.scrollViewOriginalInset.right + self.frame.size.width;
						CGFloat exceeded = [self exceedLength];
						if (exceeded < 0) {
							right = -exceeded + self.frame.size.width;
						}
						UIEdgeInsets contentInset = self.scrollView.contentInset;
						contentInset.right = right;
						self.scrollView.contentInset = contentInset;
						
						// 2.设置滚动位置
						CGPoint contentOffset = self.scrollView.contentOffset;
						contentOffset.x = [self didappearOffsetXorY];
						self.scrollView.contentOffset = contentOffset;

					}
					else{
						// 1.增加滚动区域
						CGFloat bottom = self.scrollViewOriginalInset.bottom + self.frame.size.height;
						CGFloat exceeded = [self exceedLength];
						if (exceeded < 0) {
							bottom = -exceeded + self.frame.size.height;
						}
						UIEdgeInsets contentInset = self.scrollView.contentInset;
						contentInset.bottom = bottom;
						self.scrollView.contentInset = contentInset;
						
						// 2.设置滚动位置
						CGFloat didappear = [self didappearOffsetXorY];
						CGPoint contentOffset = self.scrollView.contentOffset;
						contentOffset.y = didappear;
						self.scrollView.contentOffset = contentOffset;
					}
				}
			}];
		}
			break;

		default:
			break;
	}
}

#pragma mark - 刷新相关
#pragma mark 是否正在刷新
- (BOOL)isRefreshing{
	return VORefreshStateRefreshing == self.state;
}

#pragma mark 开始刷新
- (void)beginRefreshing{
	if (self.window) {
		self.state = VORefreshStateRefreshing;
	} else {
		_state = VORefreshStateRefreshing;
		[super setNeedsDisplay];
	}
}

#pragma mark 结束刷新
- (void)endRefreshing{
	double delayInSeconds = 0.3;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		self.state = VORefreshStateNormal;
	});
}



@end


