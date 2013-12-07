//
//  OUGroupCell.m
//  ITMOSchedule
//
//  Created by Ruslan Kavetsky on 10/14/13.
//  Copyright (c) 2013 Ruslan Kavetsky. All rights reserved.
//

#import "OUGroupCell.h"
#import "UILabel+Adjust.h"

@implementation OUGroupCell

#pragma mark - Update labels

- (void)updateTopLabel {
    [super updateTopLabel];
    self.topLabel.text = self.lesson.teacher.teacherName;
}

- (void)updateBottomLabel {
    [super updateBottomLabel];
    self.bottomLabel.text = [self.lesson.auditory auditoryDescription];
}

@end
