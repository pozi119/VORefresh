//
//  VODemoCell.m
//  VORefreshDemo
//
//  Created by Valo Lee on 14-11-8.
//  Copyright (c) 2014年 valo. All rights reserved.
//

#import "VODemoCell.h"

@interface VODemoCell ()
@property (weak, nonatomic) IBOutlet UILabel *label;

@end

@implementation VODemoCell

-(void)setText:(NSString *)text{
	_text = text;
	self.label.text = text;
}

+ (NSString *)reuseIdentifier{
	return @"demoCell";
}

@end
