//
//  OUTeacher.m
//  ITMOSchedule
//
//  Created by Misha on 10/9/13.
//  Copyright (c) 2013 Ruslan Kavetsky. All rights reserved.
//

#import "OUTeacher.h"

@implementation OUTeacher

+ (OUTeacher *)teacherWithName:(NSString *)teacherName id:(NSString *)teacherId {
    OUTeacher *teacher = [OUTeacher new];
    teacher.teacherName = teacherName;
    teacher.teacherId = teacherId;
    return teacher;
}

+ (OUTeacher *)teacherWithName:(NSString *)teacherName {
    return [self teacherWithName:teacherName id:nil];
}

+ (OUTeacher *)teacherWithId:(NSString *)teacherId {
    return [self teacherWithName:nil id:teacherId];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ {id : %@, name : %@}", NSStringFromClass([self class]), _teacherId, _teacherName];
}

@end
