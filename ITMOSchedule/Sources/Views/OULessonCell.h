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

@property (nonatomic, strong) OULesson *lesson;

@property (nonatomic, strong) IBOutlet UILabel *timeLabel;
@property (nonatomic, strong) IBOutlet UILabel *topLabel;
@property (nonatomic, strong) IBOutlet UILabel *centerLabel;
@property (nonatomic, strong) IBOutlet UILabel *bottomLabel;

@end
