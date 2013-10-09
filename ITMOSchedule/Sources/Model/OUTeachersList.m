//
//  OUTeachersList.m
//  ITMOSchedule
//
//  Created by Misha on 10/9/13.
//  Copyright (c) 2013 Ruslan Kavetsky. All rights reserved.
//

#import "OUTeachersList.h"

static NSArray *_teachers;

@implementation OUTeachersList

+ (void) initTeachers:(NSArray *)teachers {
    _teachers = teachers;
}

+ (NSArray *)teachers {
    return _teachers;
}

@end
