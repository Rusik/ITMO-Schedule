//
//  OULessonCell.m
//  ITMOSchedule
//
//  Created by Ruslan Kavetsky on 10/14/13.
//  Copyright (c) 2013 Ruslan Kavetsky. All rights reserved.
//

#import "OULessonCell.h"
#import "UILabel+Adjust.h"
#import "UIFont+PreferedFontSize.h"

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

- (void)awakeFromNib {
    [super awakeFromNib];

    self.topLabel.textColor = self.bottomLabel.textColor = [UIColor colorWithWhite:0.400 alpha:1.000];

    self.selectedBackgroundView.backgroundColor = ICON_COLOR;
}

- (void)adjustLabelsSize {
//    [self.topLabel adjustSizeWithMaximumWidth:self.topLabelView.$width];
//    [self.centerLabel adjustSizeWithMaximumWidth:self.centerLabelView.$width];
//    [self.bottomLabel adjustSizeWithMaximumWidth:self.bottomLabelView.$width];

    NSString *topBottomStyle = UIFontTextStyleCaption1;

    [self.topLabel adjustSizeWithMaximumWidth:self.topLabelView.$width withFont:[UIFont preferredFontForTextStyle:topBottomStyle]];
    [self.centerLabel adjustSizeWithMaximumWidth:self.centerLabelView.$width withFont:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]];
    [self.bottomLabel adjustSizeWithMaximumWidth:self.bottomLabelView.$width withFont:[UIFont preferredFontForTextStyle:topBottomStyle]];
    self.timeLabel.font = [UIFont preferredTimeFont];
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

#define SPACE 5.0

- (void)layoutSubviews {
    [super layoutSubviews];

    [self adjustLabelsSize];    

    self.topLabel.$y = SPACE;
    self.centerLabel.$y = self.topLabel.$bottom;
    self.bottomLabel.$y = self.centerLabel.$bottom;
    self.timeLabel.$height = self.topLabel.$height + self.centerLabel.$height + self.bottomLabel.$height + SPACE * 2;
}

#pragma mark - Height

+ (CGFloat)cellHeightForLesson:(OULesson *)lesson {
    static OULessonCell *cell = nil;
    static Class cacheClass;
    if (!cell || cacheClass != self) {
        cell = [self loadFromNib];
        cacheClass = self;
    }
    cell.lesson = lesson;
    return [cell height];
}

- (CGFloat)height {
    return _topLabel.$height + _centerLabel.$height + _bottomLabel.$height + SPACE * 2;
}

@end
