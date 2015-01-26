//
//  CircleView.m
//  03-手势解锁
//
//  Created by Kevin on 14/10/18.
//  Copyright (c) 2014年 HGG. All rights reserved.
//

#import "CircleView.h"

@implementation CircleView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

/**
 *  初始化
 */
- (void)setup
{
    // 设置按钮不可用
    self.userInteractionEnabled = NO;
    
    // 设置默认的背景图片
    [self setBackgroundImage:[UIImage imageNamed:@"gesture_node_normal"] forState:UIControlStateNormal];
    
    // 设置选中时的背景图片(selected)
    [self setBackgroundImage:[UIImage imageNamed:@"gesture_node_highlighted"] forState:UIControlStateSelected];
}

@end
