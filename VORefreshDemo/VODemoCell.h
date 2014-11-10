//
//  VODemoCell.h
//  VORefreshDemo
//
//  Created by Valo Lee on 14-11-8.
//  Copyright (c) 2014年 valo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VODemoCell : UICollectionViewCell

@property (nonatomic, copy) NSString *text;
+ (NSString *)reuseIdentifier;

@end
