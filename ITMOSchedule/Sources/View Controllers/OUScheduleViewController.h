//
//  OUScheduleViewController.h
//  ITMOSchedule
//
//  Created by Ruslan Kavetsky on 10/14/13.
//  Copyright (c) 2013 Ruslan Kavetsky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OUTopView.h"

@interface OUScheduleViewController : UIViewController

- (void)reloadData;

- (void)setContentInset:(UIEdgeInsets)inset;

- (void)scrollToAnotherWeek;

- (void)stopScroll;

- (void)setWeekType:(OULessonWeekType)weekType animated:(BOOL)animated;

@property (nonatomic, weak) OUTopView *topView;

@end
