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

    NSString *topSring = @"";
    if (self.lesson.lessonType != OULessonTypeUnknown) {
        topSring = [topSring stringByAppendingFormat:@"%@", [OULesson fullStringForLessonType:self.lesson.lessonType]];
    } else if (self.lesson.lessonTypeString) {
        topSring = [topSring stringByAppendingFormat:@"%@", self.lesson.lessonTypeString];
    }
    if (self.lesson.teacher.teacherName) {
        if (![topSring isEqualToString:@""]) {
            topSring = [topSring stringByAppendingString:@", "];
        }
        topSring  = [topSring stringByAppendingString:self.lesson.teacher.teacherName];
    }
    self.topLabel.text = topSring;
}

- (void)updateBottomLabel {
    [super updateBottomLabel];
    self.bottomLabel.text = [self.lesson.auditory auditoryDescription];
}

@end
