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

    [self updateFonts];
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

- (void)updateFonts {
    NSString *topBottomStyle = UIFontTextStyleCaption1;

    self.topLabel.font = [UIFont preferredFontForTextStyle:topBottomStyle];
    self.centerLabel.font =[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    self.bottomLabel.font = [UIFont preferredFontForTextStyle:topBottomStyle];
    self.timeLabel.font = [UIFont preferredTimeFont];
}

- (void)adjustLabelsSize {
    [self.topLabel adjustSizeWithMaximumWidth:self.topLabelView.$width];
    [self.centerLabel adjustSizeForAttributedStringWithMaximumWidth:self.centerLabelView.$width];
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

#define LESSON_TYPE_TEXT_COLOR [UIColor colorWithWhite:0.500 alpha:1.000]

- (void)updateCenterLabel {

    UIColor *typeTextColor = LESSON_TYPE_TEXT_COLOR;

    if (_lesson.additionalInfo) {
        [self applyAttributesToNameWithColor:typeTextColor];
    } else if (_lesson.lessonType != OULessonTypeUnknown) {
        [self applyAttributesToNameWithColor:typeTextColor];
    } else {
        _centerLabel.text = _lesson.lessonName;
    }
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

#pragma mark - Highlited & attributed

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];

    UIColor *textColor;
    if (highlighted) {
        textColor = [UIColor whiteColor];
    } else {
        textColor = LESSON_TYPE_TEXT_COLOR;
    }
    [self applyAttributesToNameWithColor:textColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    UIColor *textColor;
    if (selected) {
        textColor = [UIColor whiteColor];
    } else {
        textColor = LESSON_TYPE_TEXT_COLOR;
    }

    // Чтобы смена цветов была плавная и соответствовала анимации смены цвета фона
    if (animated) {
        double delayInSeconds = 0.25;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self applyAttributesToNameWithColor:textColor];
        });
    } else {
        [self applyAttributesToNameWithColor:textColor];
    }
}

- (void)applyAttributesToNameWithColor:(UIColor *)color {
    NSString *shortLessontType = [OULesson shortStringForLessonType:_lesson.lessonType];
    UIColor *typeTextColor = color;
    NSString *typeTextStyle = UIFontTextStyleBody;
    NSDictionary *typeAttributes = @{NSForegroundColorAttributeName : typeTextColor,
                                     NSFontAttributeName : [UIFont preferredFontForTextStyle:typeTextStyle],
                                     };

    if (_lesson.additionalInfo) {
        NSString *text = [NSString stringWithFormat:@"%@ (%@)\n%@", _lesson.lessonName, shortLessontType, _lesson.additionalInfo];

        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:text];
        [attrString addAttributes:@{NSFontAttributeName : _centerLabel.font}
                            range:NSMakeRange(0, attrString.length)];
        [attrString addAttributes:typeAttributes
                            range:[text rangeOfString:[NSString stringWithFormat:@"(%@)", shortLessontType]]];

        _centerLabel.attributedText = attrString;

    } else if (_lesson.lessonType != OULessonTypeUnknown) {
        NSString *text = [NSString stringWithFormat:@"%@ (%@)", _lesson.lessonName, shortLessontType];

        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:text];
        [attrString addAttributes:@{NSFontAttributeName : _centerLabel.font}
                            range:NSMakeRange(0, attrString.length)];
        [attrString addAttributes:typeAttributes
                            range:[text rangeOfString:[NSString stringWithFormat:@"(%@)", shortLessontType]]];

        _centerLabel.attributedText = attrString;
    }
}

@end
