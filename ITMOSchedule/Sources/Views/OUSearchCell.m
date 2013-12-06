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
#import "NSString+Helpers.h"

#define SPACE 5.0

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

    _bottomTextLabel.textColor = [UIColor colorWithWhite:0.400 alpha:1.000];
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
        _bottomTextLabel.text = nil;
    }
    if ([_data isKindOfClass:[OUTeacher class]]) {
        OUTeacher *teacher = (OUTeacher *)_data;
        _textLabel.text = teacher.teacherName;
        _bottomTextLabel.text = [teacher.teaherPosition stringWithSpaceAfterCommaAndDot];
    }
    if ([_data isKindOfClass:[OUAuditory class]]) {
        OUAuditory *auditory = (OUAuditory *)_data;
        _textLabel.text = [auditory correctAuditoryName];
        _bottomTextLabel.text = auditory.auditoryAddress;
    }
}

#define DEFAULT_HEIGHT 44.0

- (void)updateLabelsSize {
    [_textLabel adjustSizeWithMaximumWidth:_viewForTextWidth.$width withFont:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]];
    [_bottomTextLabel adjustSizeWithMaximumWidth:_viewForTextWidth.$width withFont:[UIFont preferredFontForTextStyle:UIFontTextStyleFootnote]];

    if (_bottomTextLabel.$height == 0) {
        _textLabel.$height = MAX(DEFAULT_HEIGHT, _textLabel.$height + SPACE * 2);
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];

    if (_bottomTextLabel.$height == 0) {
        _textLabel.$y = 0;
    } else {
        _textLabel.$y = SPACE;
        _bottomTextLabel.$y = _textLabel.$bottom;
    }
}

static NSMutableDictionary *hashDict = nil;

+ (void)resetHeightCache {
    [hashDict removeAllObjects];
}

+ (CGFloat)heightForData:(id)data {

    static OUSearchCell *cell = nil;

    if (!hashDict) {
        hashDict = [NSMutableDictionary new];
    }
    NSString *key;
    if ([data isKindOfClass:[OUGroup class]]) {
        OUGroup *group = (OUGroup *)data;
        key = group.groupName;
    }
    if ([data isKindOfClass:[OUTeacher class]]) {
        OUTeacher *teacher = (OUTeacher *)data;
        key = [teacher.teacherName stringByAppendingString:teacher.teaherPosition];
    }
    if ([data isKindOfClass:[OUAuditory class]]) {
        OUAuditory *auditory = (OUAuditory *)data;
        key = [auditory.auditoryName stringByAppendingString:auditory.auditoryAddress];
    }
    if (hashDict[key]) {
        return [hashDict[key] floatValue];
    } else {
        if (!cell) {
            cell = [OUSearchCell loadFromNib];
        }
        cell.data = data;
        CGFloat height = [cell height];

        hashDict[key] = @(height);

        return height;
    }
}

- (CGFloat)height {
    if (_bottomTextLabel.$height == 0) {
        return _textLabel.$height;
    } else {
        return _textLabel.$height + _bottomTextLabel.$height + SPACE * 2;
    }
}

@end
