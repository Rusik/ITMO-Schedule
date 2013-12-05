//
//  OUTopView.h
//  ITMOSchedule
//
//  Created by Ruslan Kavetsky on 21/11/13.
//  Copyright (c) 2013 Ruslan Kavetsky. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OUTopView;

typedef NS_ENUM(NSInteger, OUTopViewState) {
    OUTopViewStateEdit,
    OUTopViewStateShow,
    OUTopViewStateClear
};

@protocol OUTopViewDelegate <NSObject>

@optional
- (void)topViewDidBecomeActive:(OUTopView *)topView;
- (void)topView:(OUTopView *)topView didChangeText:(NSString *)text;
- (void)topViewDidCancel:(OUTopView *)topView;

- (void)weekDidTap:(OUTopView *)topView;

@end

@interface OUTopView : UIView

@property (nonatomic, weak) id<OUTopViewDelegate> delegate;
@property (nonatomic, strong) id data;
@property (nonatomic, weak) UIView *containerView;
@property (nonatomic) OUTopViewState state;

- (void)setWeekProgress:(float)weekProgress;

- (NSString *)text;

@end
