//
//  OUSearchCell.m
//  ITMOSchedule
//
//  Created by Ruslan Kavetsky on 10/13/13.
//  Copyright (c) 2013 Ruslan Kavetsky. All rights reserved.
//

#import "OUSearchCell.h"
#import "NSObject+NIB.h"

@interface OUSearchCell ()

@property (nonatomic, retain) IBOutlet UILabel *textLabelForSize;

@end

@implementation OUSearchCell {
    IBOutlet UILabel *_textLabel;
}

+ (CGFloat)cellHeight {
    return 44.0;
}

- (void)setData:(id)data {
    _data = data;
    _textLabel.text = [OUSearchCell stringFromData:data];
}

+ (CGFloat)heightForData:(id)data {
    if ([data isKindOfClass:[OUAuditory class]] || [data isKindOfClass:[OUGroup class]]) {
        return [self cellHeight];
    } else {

        static OUSearchCell *cell = nil;
        if (!cell) {
            cell = [OUSearchCell loadFromNib];
        }

        return [self cellHeight];
    }
}

+ (NSString *)stringFromData:(id)data {
    NSString *text;
    if ([data isKindOfClass:[OUGroup class]]) {
        OUGroup *group = (OUGroup *)data;
        text = [NSString stringWithFormat:@"Группа %@", group.groupName];
    }
    if ([data isKindOfClass:[OUTeacher class]]) {
        OUTeacher *teacher = (OUTeacher *)data;
        text = teacher.teacherName;
    }
    if ([data isKindOfClass:[OUAuditory class]]) {
        OUAuditory *auditory = (OUAuditory *)data;
        text = [NSString stringWithFormat:@"Аудитория %@", auditory.auditoryName];
    }
    return text;
}

@end
