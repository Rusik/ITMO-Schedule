//
//  OUAuditoryCell.m
//  ITMOSchedule
//
//  Created by Ruslan Kavetsky on 10/14/13.
//  Copyright (c) 2013 Ruslan Kavetsky. All rights reserved.
//

#import "OUAuditoryCell.h"
#import "UIView+Helpers.h"
#import "UILabel+Adjust.h"

@implementation OUAuditoryCell {
    IBOutlet UILabel *_addressLabel;
}

- (void)setLesson:(OULesson *)lesson {
    _addressLabel.text = lesson.address;
    [super setLesson:lesson];
}

- (void)updateTopLabel {
    self.topLabel.text = [self groupsString];
}

- (void)updateBottomLabel {
    self.bottomLabel.text = self.lesson.teacher.teacherName;
}

+ (CGFloat)cellHeightForLesson:(OULesson *)lesson {

    static OUAuditoryCell *cell = nil;
    if (!cell) {
        cell = [self loadFromNib];
    }
    cell.lesson = lesson;

    return [cell height];
}

- (CGFloat)height {
    return [super height] + _addressLabel.$height;
}

- (void)adjustLabelsSize {
    [super adjustLabelsSize];
    [_addressLabel adjustSizeWithMaximumWidth:self.bottomLabelView.$width];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    _addressLabel.$y = self.bottomLabel.$bottom;
    self.timeLabel.$height += _addressLabel.$height;
}

@end
