//
//  LockView.h
//  03-手势解锁
//
//  Created by Kevin on 14/10/18.
//  Copyright (c) 2014年 HGG. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LockView;

@protocol LockViewDelegate <NSObject>

@optional
- (void)lockView:(LockView *)lockView didFinishPath:(NSString *)path;

@end

@interface LockView : UIView

@property (nonatomic,weak) IBOutlet id<LockViewDelegate> delegate;

@end
