//
//  OUAuditoryCell.m
//  ITMOSchedule
//
//  Created by Ruslan Kavetsky on 10/14/13.
//  Copyright (c) 2013 Ruslan Kavetsky. All rights reserved.
//

#import "OUAuditoryCell.h"

@implementation OUAuditoryCell {
    IBOutlet UILabel *_adressLabel;
}

- (void)setLesson:(OULesson *)lesson {
    [super setLesson:lesson];

    _adressLabel.text = lesson.address;
}

- (void)updateTopLabel {
    self.topLabel.text = [self groupsString];
}

- (void)updateBottomLabel {
    self.bottomLabel.text = self.lesson.teacher.teacherName;
}

@end
