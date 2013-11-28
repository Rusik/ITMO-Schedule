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

    NSArray *sortedGroups = [groups sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        OUGroup *g1 = (OUGroup *)obj1;
        OUGroup *g2 = (OUGroup *)obj2;
        return [g1.groupName compare:g2.groupName];
    }];

    NSArray *sortedTeachers = [teachers sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        OUTeacher *t1 = (OUTeacher *)obj1;
        OUTeacher *t2 = (OUTeacher *)obj2;
        return [t1.teacherName compare:t2.teacherName];
    }];

    NSArray *sortedAuditories = [auditories sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        OUAuditory *a1 = (OUAuditory *)obj1;
        OUAuditory *a2 = (OUAuditory *)obj2;
        return [a1.auditoryName compare:a2.auditoryName];
    }];

    if (!string || [string isEqualToString:@""]) {
        [results addObjectsFromArray:sortedGroups];
        [results addObjectsFromArray:sortedTeachers];
        [results addObjectsFromArray:sortedAuditories];
        return results;
    }

    NSMutableArray *findGroups = [NSMutableArray new];
    NSMutableArray *findTeachers = [NSMutableArray new];
    NSMutableArray *findAuditories = [NSMutableArray new];

    for (OUGroup *group in sortedGroups) {
        if ([group.groupName rangeOfString:string options:NSCaseInsensitiveSearch].location != NSNotFound) {
            [findGroups addObject:group];
        }
    }
    for (OUTeacher *teacher in sortedTeachers) {
        if ([teacher.teacherName rangeOfString:string options:NSCaseInsensitiveSearch].location != NSNotFound) {
            [findTeachers addObject:teacher];
        }
    }
    for (OUAuditory *auditory in sortedAuditories) {
        if ([auditory.auditoryName rangeOfString:string options:NSCaseInsensitiveSearch].location != NSNotFound) {
            [findAuditories addObject:auditory];
        }
    }


    NSMutableArray *topGroups = [NSMutableArray new];
    for (OUGroup *group in findGroups) {
        if ([group.groupName rangeOfString:string options:NSCaseInsensitiveSearch].location == 0) {
            [topGroups addObject:group];
        }
    }
    [findGroups removeObjectsInArray:topGroups];
    NSMutableArray *filterGroups = [NSMutableArray new];
    [filterGroups addObjectsFromArray:topGroups];
    [filterGroups addObjectsFromArray:findGroups];


    NSMutableArray *topTeachersName = [NSMutableArray new];
    NSMutableArray *topTeachersSurname = [NSMutableArray new];
    NSMutableArray *topTeachersSecondName = [NSMutableArray new];
    for (OUTeacher *teacher in findTeachers) {

        NSArray *components = [teacher.teacherName componentsSeparatedByString:@" "];
        NSString *surname;
        NSString *name;
        NSString *secondName;
        if (components.count > 0) surname = components[0];
        if (components.count > 1) name = components[1];
        if (components.count > 2) secondName = components[2];

        if ([surname rangeOfString:string options:NSCaseInsensitiveSearch].location == 0) {
            [topTeachersSurname addObject:teacher];
        }
        if ([name rangeOfString:string options:NSCaseInsensitiveSearch].location == 0) {
            [topTeachersName addObject:teacher];
        }
        if ([secondName rangeOfString:string options:NSCaseInsensitiveSearch].location == 0) {
            [topTeachersSecondName addObject:teacher];
        }
    }
    [findTeachers removeObjectsInArray:topTeachersName];
    [findTeachers removeObjectsInArray:topTeachersSurname];
    [findTeachers removeObjectsInArray:topTeachersSecondName];
    NSMutableArray *filterTeachers = [NSMutableArray new];
    [filterTeachers addObjectsFromArray:topTeachersSurname];
    [filterTeachers addObjectsFromArray:topTeachersName];
    [filterTeachers addObjectsFromArray:topTeachersSecondName];
    [filterTeachers addObjectsFromArray:findTeachers];


    NSMutableArray *topAuditories = [NSMutableArray new];
    for (OUAuditory *auditory in findAuditories) {
        if ([auditory.auditoryName rangeOfString:string options:NSCaseInsensitiveSearch].location == 0) {
            [topAuditories addObject:auditory];
        }
    }
    [findAuditories removeObjectsInArray:topAuditories];
    NSMutableArray *filterAuditories = [NSMutableArray new];
    [filterAuditories addObjectsFromArray:topAuditories];
    [filterAuditories addObjectsFromArray:findAuditories];


    [results addObjectsFromArray:filterGroups];
    [results addObjectsFromArray:filterTeachers];
    [results addObjectsFromArray:filterAuditories];

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

- (OULessonWeekType)currentWeekType {
    if (_currentWeekNumber % 2) {
        return OULessonWeekTypeOdd;
    } else {
        return OULessonWeekTypeEven;
    }
}

#pragma mark - Lessons data

- (NSArray *)weekDaysForWeekType:(OULessonWeekType)weekType {
    NSArray *lessons = [self lessonsForWeekType:weekType];
    NSMutableSet *set = [NSMutableSet set];
    for (OULesson *l in lessons) {
        [set addObject:[OULesson stringFromWeekDay:l.weekDay]];
    }
    NSMutableArray *days = [NSMutableArray array];
    for (NSString *day in [OULesson weekDays]) {
        if ([set containsObject:day]) {
            if (![days containsObject:day]) {
                [days addObject:day];
            }
        }
    }
    return days;
}

- (NSArray *)lessonsForDay:(OULessonWeekDay)weekDay weekType:(OULessonWeekType)weekType {
    NSArray *weekLessons = [self lessonsForWeekType:weekType];
    NSMutableArray *lessons = [NSMutableArray array];
    for (OULesson *l in weekLessons) {
        if (l.weekDay == weekDay) {
            [lessons addObject:l];
        }
    }
    return lessons;
}

- (NSArray *)lessonsForDayString:(NSString *)weekDayString weekType:(OULessonWeekType)weekType {
    return [self lessonsForDay:[OULesson weekDayFromString:weekDayString] weekType:weekType];
}

- (NSArray *)lessonsForWeekType:(OULessonWeekType)weekType {
    NSMutableArray *lessons = [NSMutableArray array];
    for (OULesson *lesson in _lessons) {
        if (lesson.weekType == weekType || lesson.weekType == OULessonWeekTypeAny) {
            [lessons addObject:lesson];
        }
    }
    return lessons;
}

#pragma mark - Get main info

- (OUAuditory *)auditoryWithId:(NSString *)auditoryId {
    NSArray *auditories = [_mainInfo objectForKey:AUDITORIES_INFO_KEY];
    NSArray *filter = [auditories filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"auditoryId == %@", auditoryId]];
    return [filter firstObject];
}

- (OUTeacher *)teacherWithId:(NSString *)teacherId {
    NSArray *teachers = [_mainInfo objectForKey:TEACHERS_INFO_KEY];
    NSArray *filter = [teachers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"teacherId == %@", teacherId]];
    return [filter firstObject];
}

@end
