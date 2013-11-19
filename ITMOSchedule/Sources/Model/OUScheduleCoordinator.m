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

    //TODO: подправить поиск: выдавать в начале если совпадет полностью, или совпалает с начала слова а не в середине

    NSArray *groups = _mainInfo[GROUPS_INFO_KEY];
    NSArray *teachers = _mainInfo[TEACHERS_INFO_KEY];
    NSArray *auditories = _mainInfo[AUDITORIES_INFO_KEY];

    NSMutableArray *results = [NSMutableArray array];
    for (OUGroup *group in groups) {
        if ([group.groupName rangeOfString:string options:NSCaseInsensitiveSearch].location != NSNotFound) {
            [results addObject:group];
        }
    }
    for (OUTeacher *teacher in teachers) {
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
