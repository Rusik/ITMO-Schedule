//
//  OUSearchCell.m
//  ITMOSchedule
//
//  Created by Ruslan Kavetsky on 10/13/13.
//  Copyright (c) 2013 Ruslan Kavetsky. All rights reserved.
//

#import "OUSearchCell.h"
#import "NSObject+NIB.h"
#import "UILabel+Adjust.h"

@implementation OUSearchCell {
    IBOutlet UILabel *_textLabel;
    IBOutlet UILabel *_bottomTextLabel;
    IBOutlet UIView *_viewForTextWidth;
}

+ (CGFloat)cellHeight {
    return 44.0;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self clearLabels];
}

- (void)clearLabels {
    _textLabel.text = nil;
    _bottomTextLabel.text = nil;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self clearLabels];
}

- (void)setData:(id)data {
    _data = data;

    [self updateLabelsText];
    [self updateLabelsSize];
}

- (void)updateLabelsText {
    if ([_data isKindOfClass:[OUGroup class]]) {
        OUGroup *group = (OUGroup *)_data;
        _textLabel.text = [NSString stringWithFormat:@"Группа %@", group.groupName];
    }
    if ([_data isKindOfClass:[OUTeacher class]]) {
        OUTeacher *teacher = (OUTeacher *)_data;
        _textLabel.text = teacher.teacherName;
        _bottomTextLabel.text = teacher.teaherPosition;
    }
    if ([_data isKindOfClass:[OUAuditory class]]) {
        OUAuditory *auditory = (OUAuditory *)_data;
        _textLabel.text = [NSString stringWithFormat:@"Аудитория %@", auditory.auditoryName];
    }
}

- (void)updateLabelsSize {
    [_textLabel adjustSizeWithMaximumWidth:_viewForTextWidth.$width];
    [_bottomTextLabel adjustSizeWithMaximumWidth:_viewForTextWidth.$width];

    CGFloat minheight = 44.0;

    if (_textLabel.$height + _bottomTextLabel.$height < minheight) {
        if (_bottomTextLabel.$height == 0) {
            _textLabel.$height = minheight;
        } else {
            _textLabel.$height = minheight / 2;
            _bottomTextLabel.$height = minheight / 2;
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];

    _textLabel.$y = 0;
    _bottomTextLabel.$y = _textLabel.$bottom;
}

+ (CGFloat)heightForData:(id)data {
    static OUSearchCell *cell = nil;
    if (!cell) {
        cell = [OUSearchCell loadFromNib];
    }
    cell.data = data;

    return [cell height];
}

- (CGFloat)height {
    return _textLabel.$height + _bottomTextLabel.$height;
}

@end
