//
//  OUGroupCell.m
//  ITMOSchedule
//
//  Created by Ruslan Kavetsky on 10/14/13.
//  Copyright (c) 2013 Ruslan Kavetsky. All rights reserved.
//

#import "OUGroupCell.h"

@implementation OUGroupCell

- (void)setLesson:(OULesson *)lesson {
    [super setLesson:lesson];

    if (lesson.timeInterval) {
        self.timeLabel.text = lesson.timeInterval;
    } else {
        NSString *startTime = [NSString stringWithFormat:@"%2d:%.2d", lesson.startTime / 100, lesson.startTime % 100];
        NSString *finishTime = [NSString stringWithFormat:@"%2d:%.2d", lesson.finishTime / 100, lesson.finishTime % 100];
        self.timeLabel.text = [NSString stringWithFormat:@"%@\n%@", startTime, finishTime];
    }
    self.centerLabel.text = lesson.lessonName;

    NSString *topSring = @"";
    if (lesson.lessonType != OULessonTypeUnknown) {
        topSring = [topSring stringByAppendingFormat:@"%@", [OULesson fullStringForLessonType:lesson.lessonType]];
    } else if (lesson.lessonTypeString) {
        topSring = [topSring stringByAppendingFormat:@"%@", lesson.lessonTypeString];
    }
    if (lesson.teacher.teacherName) {
        if (![topSring isEqualToString:@""]) {
            topSring = [topSring stringByAppendingString:@", "];
        }
        topSring  = [topSring stringByAppendingString:lesson.teacher.teacherName];
    }

    self.topLabel.text = topSring;
    self.bottomLabel.text = lesson.address;
}

@end
