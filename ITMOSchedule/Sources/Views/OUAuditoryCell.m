//
//  OUAuditoryCell.m
//  ITMOSchedule
//
//  Created by Ruslan Kavetsky on 10/14/13.
//  Copyright (c) 2013 Ruslan Kavetsky. All rights reserved.
//

#import "OUAuditoryCell.h"

@implementation OUAuditoryCell

- (void)setLesson:(OULesson *)lesson {
    [super setLesson:lesson];
    [self fillDataWithLesson:(OULesson *)lesson];
}

- (void)fillDataWithLesson:(OULesson *)lesson {
    if (lesson.timeInterval) {
        self.timeLabel.text = lesson.timeInterval;
    } else {
        NSString *startTime = [NSString stringWithFormat:@"%2d:%.2d", lesson.startTime / 100, lesson.startTime % 100];
        NSString *finishTime = [NSString stringWithFormat:@"%2d:%.2d", lesson.finishTime / 100, lesson.finishTime % 100];
        self.timeLabel.text = [NSString stringWithFormat:@"%@\n%@", startTime, finishTime];
    }

    NSMutableString *groupsString = [[NSMutableString alloc] init];
    for (OUGroup *group in lesson.groups) {
        [groupsString appendFormat:@"%@, ",group.groupName];
    }
    [groupsString replaceCharactersInRange:NSMakeRange(groupsString.length - 2, 2) withString:@""];

    self.topLabel.text = groupsString;
    self.centerLabel.text = lesson.lessonName;
    self.bottomLabel.text = lesson.teacher.teacherName;
}

@end
