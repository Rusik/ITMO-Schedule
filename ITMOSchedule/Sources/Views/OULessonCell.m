//
//  OULessonCell.m
//  ITMOSchedule
//
//  Created by Ruslan Kavetsky on 10/14/13.
//  Copyright (c) 2013 Ruslan Kavetsky. All rights reserved.
//

#import "OULessonCell.h"

@implementation OULessonCell

+ (CGFloat)cellHeight {
    return 100.0;
}

- (void)setLesson:(OULesson *)lesson {
    _lesson = lesson;

    [self updateTimeLabel];
    [self updateTopLabel];
    [self updateCenterLabel];
    [self updateBottomLabel];
}

- (void)updateTimeLabel {
    if (_lesson.timeInterval) {
        _timeLabel.text = _lesson.timeInterval;
    } else {
        NSString *startTime = [NSString stringWithFormat:@"%2d:%.2d", _lesson.startTime / 100, _lesson.startTime % 100];
        NSString *finishTime = [NSString stringWithFormat:@"%2d:%.2d", _lesson.finishTime / 100, _lesson.finishTime % 100];
        _timeLabel.text = [NSString stringWithFormat:@"%@\n%@", startTime, finishTime];
    }
}

- (void)updateCenterLabel {
    _centerLabel.text = _lesson.lessonName;
}

- (void)updateTopLabel {}

- (void)updateBottomLabel {}

- (NSString *)groupsString {
    NSMutableString *groupsString = [@"" mutableCopy];
    for (OUGroup *group in self.lesson.groups) {
        [groupsString appendFormat:@"%@, ", group.groupName];
    }
    [groupsString replaceCharactersInRange:NSMakeRange(groupsString.length - 2, 2) withString:@""];
    return [groupsString copy];
}

@end
