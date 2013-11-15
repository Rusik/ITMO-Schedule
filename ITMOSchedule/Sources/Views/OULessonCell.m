//
//  OULessonCell.m
//  ITMOSchedule
//
//  Created by Ruslan Kavetsky on 10/14/13.
//  Copyright (c) 2013 Ruslan Kavetsky. All rights reserved.
//

#import "OULessonCell.h"
#import "UILabel+Adjust.h"

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

    [self adjustLabelsSize];
}

- (void)adjustLabelsSize {
    [self.topLabel adjustSizeWithMaximumWidth:self.topLabelView.$width];
    [self.centerLabel adjustSizeWithMaximumWidth:self.centerLabelView.$width];
    [self.bottomLabel adjustSizeWithMaximumWidth:self.bottomLabelView.$width];
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

- (void)layoutSubviews {
    [super layoutSubviews];

    self.topLabel.$y = 0;
    self.centerLabel.$y = self.topLabel.$bottom;
    self.bottomLabel.$y = self.centerLabel.$bottom;
    self.timeLabel.$height = self.topLabel.$height + self.centerLabel.$height + self.bottomLabel.$height;
}

#pragma mark - Height

+ (CGFloat)cellHeightForLesson:(OULesson *)lesson {
    static OULessonCell *cell = nil;
    if (!cell) {
        cell = [self loadFromNib];
    }
    cell.lesson = lesson;
    return [cell height];
}

- (CGFloat)height {
    return _topLabel.$height + _centerLabel.$height + _bottomLabel.$height;
}

@end
