//
//  OUParser.m
//  ITMOSchedule
//
//  Created by Misha on 10/9/13.
//  Copyright (c) 2013 Ruslan Kavetsky. All rights reserved.
//

#import "OUParser.h"
#import "RXMLElement.h"
#import "OUScheduleCoordinator.h"
#import "NSArray+Helpers.h"
#import "NSString+Helpers.h"
#import "OUScheduleDownloader.h"

@implementation OUParser

+ (NSDictionary *)parseMainInfo:(NSData *)XMLData {

    NSMutableArray *groups = [NSMutableArray array];
    NSMutableArray *teachers = [NSMutableArray array];
    NSMutableArray *auditories = [NSMutableArray array];

    RXMLElement *rootElement = [RXMLElement elementFromXMLData:XMLData];

    [rootElement iterate:@"GROUPS.GROUP_ID" usingBlock: ^(RXMLElement *groupElement) {
        OUGroup *group = [OUGroup new];
        group.groupName = groupElement.text;
        [groups addObject:group];
    }];

    [rootElement iterate:@"TEACHERS.TEACHER" usingBlock:^(RXMLElement *teacherElement) {
        OUTeacher *teacher = [OUTeacher new];
        teacher.teacherId = [teacherElement child:@"TEACHER_ID"].text;
        teacher.teacherName = [[teacherElement child:@"TEACHER_FIO"].text stringByDeletingDataInBrackets];
        teacher.teaherPosition = [[teacherElement child:@"TEACHER_FIO"].text stringFromBrackets];
        [teachers addObject:teacher];
    }];

    [rootElement iterate:@"AUDITORIES.AUDITORY_INFO" usingBlock:^(RXMLElement *auditoryElement) {
        OUAuditory *auditory = [OUAuditory new];
        auditory.auditoryName = [auditoryElement child:@"AUDITORY_NAME"].text;
        auditory.auditoryId = [auditoryElement child:@"AUDITORY_ID"].text;
        auditory.auditoryAddress = [auditoryElement child:@"PLACE"].text;
        [auditories addObject:auditory];
    }];


    //sort
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


    NSDictionary *info = @{GROUPS_INFO_KEY: sortedGroups, TEACHERS_INFO_KEY: sortedTeachers, AUDITORIES_INFO_KEY: sortedAuditories};

    [[OUScheduleCoordinator sharedInstance] setMainInfo:info];

    return info;
}

+ (NSArray *)parseLessons:(NSData *)XMLData forGroup:(OUGroup *)group {
    NSMutableArray *lessons = [NSMutableArray  array];

    RXMLElement *rootElement = [RXMLElement elementFromXMLData:XMLData];

    __block NSString *weekDay;

    [rootElement iterate:@"WEEKDAY" usingBlock:^(RXMLElement *weekDayElement) {
        weekDay = [weekDayElement attribute:@"value"];
        [weekDayElement iterate:@"DESCRIPTION.SCHEDULE.SCHEDULE_PARAM" usingBlock:^(RXMLElement *lessonElement) {
            OULesson *lesson = [OULesson new];

            if (group) lesson.groups = @[group];
            lesson.weekDay = [OULesson weekDayFromString:weekDay];
            [self parseLessonInfoForElement:lessonElement intoLesson:lesson];
            lesson.teacher = [[OUScheduleCoordinator sharedInstance] teacherWithId:[lessonElement child:@"LECTUTER_ID"].text];

            [lessons addObject:lesson];
        }];
    }];

    return lessons;
}

+ (NSArray *)parseLessons:(NSData *)XMLData forAuditory:(OUAuditory *)auditory {
    NSMutableArray *lessons = [NSMutableArray  array];

    RXMLElement *rootElement = [RXMLElement elementFromXMLData:XMLData];

    __block NSString *weekDay;

    [rootElement iterate:@"WEEKDAY" usingBlock:^(RXMLElement *weekDayElement) {
        weekDay = [weekDayElement attribute:@"value"];
        [weekDayElement iterate:@"DESCRIPTION_A.SCHEDULE.SCHEDULE_PARAM_A" usingBlock:^(RXMLElement *lessonElement) {
            OULesson *lesson = [OULesson new];

            lesson.groups = [self groupsFromString:[lessonElement child:@"GROUP_NUMBER"].text];
            lesson.weekDay = [OULesson weekDayFromString:weekDay];
            [self parseLessonInfoForElement:lessonElement intoLesson:lesson];
            lesson.teacher = [[OUScheduleCoordinator sharedInstance] teacherWithId:[lessonElement child:@"TEACHER_ID"].text];

            [lessons addObject:lesson];
        }];
    }];

    return lessons;
}

+ (NSArray *)parseLessons:(NSData *)XMLData forTeacher:(OUTeacher *)teacher {
    NSMutableArray *lessons = [NSMutableArray  array];

    RXMLElement *rootElement = [RXMLElement elementFromXMLData:XMLData];

    __block NSString *weekDay;

    [rootElement iterate:@"WEEKDAY" usingBlock:^(RXMLElement *weekDayElement) {
        weekDay = [weekDayElement attribute:@"value"];
        [weekDayElement iterate:@"DESCRIPTION_P.SCHEDULE.SCHEDULE_PARAM_P" usingBlock:^(RXMLElement *lessonElement) {
            OULesson *lesson = [OULesson new];

            lesson.groups = [self groupsFromString:[lessonElement child:@"GROUP_NUMBER"].text];
            lesson.weekDay = [OULesson weekDayFromString:weekDay];
            [self parseLessonInfoForElement:lessonElement intoLesson:lesson];
            lesson.teacher = teacher;

            [lessons addObject:lesson];
        }];
    }];

    return lessons;
}

+ (NSNumber *)parseWeekNumber:(NSData *)XMLData {
    RXMLElement *rootElement = [RXMLElement elementFromXMLData:XMLData];

    return [NSNumber numberWithInt:rootElement.text.intValue];
}

#pragma mark - Little parsers

+ (void)parseLessonInfoForElement:(RXMLElement *)element intoLesson:(OULesson *)lesson {
    NSString *timeInterval = [[element child:@"TIME_INTERVAL"] text];
    OULessonTime startTime;
    OULessonTime finishTime;
    if ([self startTime:&startTime finishTime:&finishTime fromString:timeInterval]) {
        lesson.startTime = startTime;
        lesson.finishTime = finishTime;
    } else {
        lesson.timeInterval = timeInterval;
    }
    lesson.weekType = [OULesson weekTypeFromString:[element child:@"WEEK"].text];

    NSString *name = [element child:@"SUBJECT"].text;

    NSRange newLineRange = [name rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]];
    if (newLineRange.location != NSNotFound) {
        NSArray *comp = [name componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        if (comp.count > 2) {
            NSLog(@"WARNING: 3 components in lesson name:\n%@", name);
        }
        if (comp.count == 1) {
            NSLog(@"WARNING: something starnge with components in lesson name:\n%@", name);
        }
        if (comp.count == 2) {
            NSString *part1 = comp[0];
            NSString *part2 = comp[1];
            lesson.lessonName = [part1 fixCommaSpaces];
            lesson.additionalInfo = [part2 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
    } else {
        lesson.lessonName = [name fixCommaSpaces];
    }

    lesson.lessonType = [OULesson lessonTypeFromString:[element child:@"TYPE"].text];
    lesson.lessonTypeString = [element child:@"TYPE"].text;
    lesson.auditory = [[OUScheduleCoordinator sharedInstance] auditoryWithId:[element child:@"PLACE"].text];
}

#pragma mark - Helpers

+ (NSString *)startTime:(OULessonTime *)startTime finishTime:(OULessonTime *)finishTime fromString:(NSString *)string {
    NSArray *components = [string componentsSeparatedByString:@"-"];

    if (components.count == 1 || components.count == 0) {
        return nil;
    }

    NSString *startTimeString = components[0];
    NSString *finishTimeString = components[1];

    NSArray *startTimeComponents = [startTimeString componentsSeparatedByString:@":"];
    OULessonTime s = [startTimeComponents[0] intValue] * 100 + [startTimeComponents[1] intValue];
    *startTime = s;

    NSArray *finishTimeComponents = [finishTimeString componentsSeparatedByString:@":"];
    OULessonTime f = [finishTimeComponents[0] intValue] * 100 + [finishTimeComponents[1] intValue];
    *finishTime = f;

    return string;
}

+ (NSArray *)groupsFromString:(NSString *)string {
    NSArray *groupsStrings = [string componentsSeparatedByString:@","];
    NSMutableArray *groups = [NSMutableArray array];
    for (NSString *s in groupsStrings) {
        OUGroup *group = [OUGroup new];
        group.groupName = s;
        [groups addObject:group];
    }
    return [groups copy];
}

@end
