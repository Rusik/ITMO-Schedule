//
//  OUScheduleCoordinator.m
//  ITMOSchedule
//
//  Created by Ruslan Kavetsky on 10/9/13.
//  Copyright (c) 2013 Ruslan Kavetsky. All rights reserved.
//

#import "OUScheduleCoordinator.h"
#import "OUGroup.h"
#import "OUTeacher.h"
#import "OUAuditory.h"

@implementation OUScheduleCoordinator {
    id _lessonsType;
    NSArray *_lessons;
}

+ (OUScheduleCoordinator *)sharedInstance {
    static OUScheduleCoordinator *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [OUScheduleCoordinator new];
    });
    return instance;
}

- (NSArray *)mainInfoDataForString:(NSString *)string {
    NSArray *groups = _mainInfo[GROUPS_INFO_KEY];
    NSArray *teachers = _mainInfo[TEACHERS_INFO_KEY];
    NSArray *auditories = _mainInfo[AUDITORIES_INFO_KEY];

    NSMutableArray *results = [NSMutableArray array];
    for (OUGroup *group in groups) {
        if ([group.groupName rangeOfString:string options:NSCaseInsensitiveSearch].location != NSNotFound) {
            [results addObject:group];
        }
    }
    int max = 0;
    for (OUTeacher *teacher in teachers) {
//        if (teacher.teacherName.length > max) {
//            max = teacher.teacherName.length;
//            NSLog(@"%d %@", max, teacher.teacherName);
//        }
        if ([teacher.teacherName rangeOfString:string options:NSCaseInsensitiveSearch].location != NSNotFound) {
            [results addObject:teacher];
        }
    }
    for (OUAuditory *auditory in auditories) {
        if ([auditory.auditoryName rangeOfString:string options:NSCaseInsensitiveSearch].location != NSNotFound) {
            [results addObject:auditory];
        }
    }
    return results;
}

- (void)setLessons:(NSArray *)lessons forGroup:(OUGroup *)group {
    _lessons = lessons;
    _lessonsType = group;
}

- (void)setLessons:(NSArray *)lessons forTeacher:(OUTeacher *)teacher {
    _lessons = lessons;
    _lessonsType = teacher;
}

- (void)setLessons:(NSArray *)lessons forAuditory:(OUAuditory *)auditory {
    _lessons = lessons;
    _lessonsType = auditory;
}

- (id)lessonsType {
    return _lessonsType;
}

- (NSArray *)lessons {
    return _lessons;
}


@end
