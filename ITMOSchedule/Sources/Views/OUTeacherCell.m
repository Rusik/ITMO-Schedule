//
//  OUTeacherCell.m
//  ITMOSchedule
//
//  Created by Ruslan Kavetsky on 10/14/13.
//  Copyright (c) 2013 Ruslan Kavetsky. All rights reserved.
//

#import "OUTeacherCell.h"

@implementation OUTeacherCell

- (void)updateTopLabel {
    self.topLabel.text = [self groupsString];
}

- (void)updateBottomLabel {
    self.bottomLabel.text = self.lesson.address;
}

@end
