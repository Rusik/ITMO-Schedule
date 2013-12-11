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
#import "OUStorage.h"

@implementation OUScheduleCoordinator {
    id _lessonsType;
    NSArray *_lessons;

    NSDictionary *_cacheMainInfo;

    NSArray *_allInfoForEmptyString;
}

+ (OUScheduleCoordinator *)sharedInstance {
    static OUScheduleCoordinator *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [OUScheduleCoordinator new];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _cacheMainInfo = [[OUStorage sharedInstance] mainInfo];
        _lessons = [[OUStorage sharedInstance] lessons];
        _lessonsType = [[OUStorage sharedInstance] lessonType];
    }
    return self;
}

- (NSArray *)mainInfoDataForString:(NSString *)string {

    NSArray *groups = _cacheMainInfo[GROUPS_INFO_KEY];
    NSArray *teachers = _cacheMainInfo[TEACHERS_INFO_KEY];
    NSArray *auditories = _cacheMainInfo[AUDITORIES_INFO_KEY];

    if (!groups || !teachers || !auditories) {
        return nil;
    }

    NSMutableArray *results = [[NSMutableArray alloc] init];

    if (!string || [string isEqualToString:@""]) {
        NSMutableArray *all = [[NSMutableArray alloc] initWithCapacity:groups.count + teachers.count + auditories.count];
        if (!_allInfoForEmptyString) {
            [all addObjectsFromArray:groups];
            [all addObjectsFromArray:teachers];
            [all addObjectsFromArray:auditories];
            _allInfoForEmptyString = [all copy];
        }
        return _allInfoForEmptyString;
    }

    NSMutableArray *findGroups = [NSMutableArray new];
    NSMutableArray *findTeachers = [NSMutableArray new];
    NSMutableArray *findAuditories = [NSMutableArray new];

    for (OUGroup *group in groups) {
        if ([group.groupName rangeOfString:string options:NSCaseInsensitiveSearch].location != NSNotFound) {
            [findGroups addObject:group];
        }
    }
    for (OUTeacher *teacher in teachers) {
        if ([teacher.teacherName rangeOfString:string options:NSCaseInsensitiveSearch].location != NSNotFound) {
            [findTeachers addObject:teacher];
        }
    }
    for (OUAuditory *auditory in auditories) {
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

#pragma mark - Current week

- (void)setCurrentWeekNumber:(NSNumber *)currentWeekNumber {
    _currentWeekNumber = currentWeekNumber;

    [[OUStorage sharedInstance] setWeekNumber:currentWeekNumber];
    [[OUStorage sharedInstance] setLastWeekNumberUpdate:[NSDate date]];

    [[NSNotificationCenter defaultCenter] postNotificationName:OUScheduleCoordinatorWeekNumberUpdateNotification object:self];
}

- (OULessonWeekType)currentWeekType {
    if (_currentWeekNumber.intValue % 2) {
        return OULessonWeekTypeOdd;
    } else {
        return OULessonWeekTypeEven;
    }
}

- (NSNumber *)expectedWeekNumber {

    if (![[OUStorage sharedInstance] weekNumber] || ![[OUStorage sharedInstance] lastWeekNumberUpdate]) {
        return nil;
    }

    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"ru_ru"]];

    int todayWeek;
    int lastSaveWeek;

    [dateFormatter setDateFormat:@"w"];
    todayWeek = [dateFormatter stringFromDate:today].intValue;
    lastSaveWeek = [dateFormatter stringFromDate:[[OUStorage sharedInstance] lastWeekNumberUpdate]].intValue;

    int currentWeek = [[OUStorage sharedInstance] weekNumber].intValue + (todayWeek - lastSaveWeek);
    return @(currentWeek);
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

#pragma mark - Storage

- (void)setMainInfo:(NSDictionary *)mainInfo {
    [[OUStorage sharedInstance] setMainInfo:mainInfo];
    _cacheMainInfo = mainInfo;
}

- (NSDictionary *)mainInfo {
    return _cacheMainInfo;
}

- (void)setLessons:(NSArray *)lessons forGroup:(OUGroup *)group {
    _lessons = lessons;
    _lessonsType = group;
    [self saveLessons];
}

- (void)setLessons:(NSArray *)lessons forTeacher:(OUTeacher *)teacher {
    _lessons = lessons;
    _lessonsType = teacher;
    [self saveLessons];
}

- (void)setLessons:(NSArray *)lessons forAuditory:(OUAuditory *)auditory {
    _lessons = lessons;
    _lessonsType = auditory;
    [self saveLessons];
}

- (id)lessonsType {
    return _lessonsType;
}

- (NSArray *)lessons {
    return _lessons;
}

- (void)saveLessons {
    [[OUStorage sharedInstance] setLessons:_lessons];
    [[OUStorage sharedInstance] setLessonType:_lessonsType];
}

#pragma mark - Get main info

- (OUAuditory *)auditoryWithId:(NSString *)auditoryId {
    NSArray *auditories = [_cacheMainInfo objectForKey:AUDITORIES_INFO_KEY];
    NSArray *filter = [auditories filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"auditoryId == %@", auditoryId]];
    return [filter firstObject];
}

- (OUTeacher *)teacherWithId:(NSString *)teacherId {
    NSArray *teachers = [_cacheMainInfo objectForKey:TEACHERS_INFO_KEY];
    NSArray *filter = [teachers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"teacherId == %@", teacherId]];
    return [filter firstObject];
}

@end
