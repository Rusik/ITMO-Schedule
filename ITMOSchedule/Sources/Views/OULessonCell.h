//
//  OULessonCell.h
//  ITMOSchedule
//
//  Created by Ruslan Kavetsky on 10/14/13.
//  Copyright (c) 2013 Ruslan Kavetsky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OULessonCell : UITableViewCell <UITableViewCellHeight>

+ (CGFloat)cellHeight;
+ (CGFloat)cellHeightForLesson:(OULesson *)lesson;

@property (nonatomic, strong) OULesson *lesson;

@property (nonatomic, strong) IBOutlet UILabel *timeLabel;
@property (nonatomic, strong) IBOutlet UILabel *topLabel;
@property (nonatomic, strong) IBOutlet UILabel *centerLabel;
@property (nonatomic, strong) IBOutlet UILabel *bottomLabel;

@property (nonatomic, strong) IBOutlet UIView *topLabelView;
@property (nonatomic, strong) IBOutlet UIView *centerLabelView;
@property (nonatomic, strong) IBOutlet UIView *bottomLabelView;


- (void)updateTimeLabel;
- (void)updateTopLabel;
- (void)updateCenterLabel;
- (void)updateBottomLabel;

- (void)adjustLabelsSize;

- (NSString *)groupsString;

- (CGFloat)height;

@end
