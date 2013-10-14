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

    NSString *startTime = [NSString stringWithFormat:@"%2d:%.2d", lesson.startTime / 100, lesson.startTime % 100];
    NSString *finishTime = [NSString stringWithFormat:@"%2d:%.2d", lesson.finishTime / 100, lesson.finishTime % 100];
    self.timeLabel.text = [NSString stringWithFormat:@"%@\n%@", startTime, finishTime];
    self.centerLabel.text = lesson.lessonName;
    self.topLabel.text = [NSString stringWithFormat:@"%@, %@", [OULesson fullStringForLessonType:lesson.lessonType], lesson.teacher.teacherName];
    self.bottomLabel.text = lesson.address;
}

@end
