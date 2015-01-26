//
//  LockView.m
//  03-手势解锁
//
//  Created by Kevin on 14/10/18.
//  Copyright (c) 2014年 HGG. All rights reserved.
//

#import "LockView.h"

#import "CircleView.h"

@interface LockView ()

@property (nonatomic, strong) NSMutableArray *selectedButtons;
@property (nonatomic, assign) CGPoint currentMovePoint;

@end

@implementation LockView

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

- (void)drawRect:(CGRect)rect
{
    if (self.selectedButtons.count == 0) return;
 
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    // 遍历所有的按钮
    for (NSInteger index = 0; index < self.selectedButtons.count; index++) {
        CircleView *btn = self.selectedButtons[index];
        
        if (index == 0) {
            [path moveToPoint:btn.center];
        } else {
            [path addLineToPoint:btn.center];
        }
    }
    
    // 连接
    if (CGPointEqualToPoint(self.currentMovePoint, CGPointZero) == NO) {
        [path addLineToPoint:self.currentMovePoint];
    }
    
    // 绘图
    path.lineWidth = 8.0f;
    path.lineJoinStyle = kCGLineJoinBevel;

    [[UIColor colorWithRed:32.0f / 255.0f green:210.0f / 255.0f blue:254.0f / 255.0f alpha:0.5f] set];
    [path stroke];
}

#pragma mark - Property

- (NSMutableArray *)selectedButtons
{
    if (_selectedButtons == nil) {
        _selectedButtons = [NSMutableArray array];
    }
    return _selectedButtons;
}

#pragma mark - Init UI

/**
 *  初始化圈圈
 */
- (void)setup
{
    for (NSInteger index = 0; index < 9; index++) {
        // 创建按钮
        CircleView *btn = [CircleView buttonWithType:UIButtonTypeCustom];
        btn.tag = index;
        // 添加
        [self addSubview:btn];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    for (NSInteger index = 0; index < self.subviews.count; index++) {
        // 取出按钮
        CircleView *btn = self.subviews[index];
        
        // 设置frame
        CGFloat btnW = 74.0f;
        CGFloat btnH = 74.0f;
        
        NSInteger totalColumns = 3;
        NSInteger col = index % totalColumns;
        NSInteger row = index / totalColumns;
        
        CGFloat marginX = (self.frame.size.width - totalColumns * btnW) / (totalColumns + 1);
        CGFloat marginY = marginX;
        
        CGFloat btnX = marginX + col * (btnW + marginX);
        CGFloat btnY = row * (btnH + marginY);
        btn.frame = CGRectMake(btnX, btnY, btnW, btnH);
    }
}

#pragma mark - Private Method

/**
 *  根据touches集合获得对应的触摸点位置
 */
- (CGPoint)pointWithTouches:(NSSet *)touches
{
    UITouch *touch = [touches anyObject];
    
    return [touch locationInView:touch.view];
}

/**
 *  根据触摸点位置获得对应的按钮
 */
- (CircleView *)buttonWithPoint:(CGPoint)point
{
    for (CircleView *btn in self.subviews) {
        /**
        CGFloat wh = 24.0f;
        CGFloat frameX = btn.center.x - wh * 0.5;
        CGFloat frameY = btn.center.y - wh * 0.5;
        
        if (CGRectContainsPoint(CGRectMake(frameX, frameY, wh, wh), point)) {
            return btn;
        }
         */
        
        if (CGRectContainsPoint(btn.frame, point)) {
            return btn;
        }

    }
    return nil;
}

#pragma mark - Touches Method

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // 清空当前的触摸点
    self.currentMovePoint = CGPointZero;
    
    // 1.获得触摸点
    CGPoint pos = [self pointWithTouches:touches];
    
    // 2.获得触摸的按钮
    CircleView *btn = [self buttonWithPoint:pos];
    
    // 3.设置状态
    if (btn && btn.selected == NO) {
        btn.selected = YES;
        
        [self.selectedButtons addObject:btn];
    }
    
    // 4.刷新
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    // 1.获得触摸点
    CGPoint pos = [self pointWithTouches:touches];
    
    // 2.获得触摸的按钮
    CircleView *btn = [self buttonWithPoint:pos];
    
    // 3.设置状态
    if (btn && btn.selected == NO) {    // 摸到了按钮
        btn.selected = YES;
        
        [self.selectedButtons addObject:btn];
    } else {    // 没有摸到按钮
        self.currentMovePoint = pos;
    }
    
    // 4.刷新
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // 通知代理
    if ([self.delegate respondsToSelector:@selector(lockView:didFinishPath:)]) {
        NSMutableString *path = [NSMutableString string];
        
        for (CircleView *btn in self.selectedButtons) {
            [path appendFormat:@"%ld",btn.tag];
        }
        
        [self.delegate lockView:self didFinishPath:path];
    }
    
    // 取消选中所有的按钮
    [self.selectedButtons makeObjectsPerformSelector:@selector(setSelected:) withObject:@(NO)];
    
    // 清空选中的按钮
    [self.selectedButtons removeAllObjects];
    [self setNeedsDisplay];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}

@end
