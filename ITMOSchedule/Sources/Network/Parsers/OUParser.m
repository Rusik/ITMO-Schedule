//
//  OUParser.m
//  ITMOSchedule
//
//  Created by Misha on 10/9/13.
//  Copyright (c) 2013 Ruslan Kavetsky. All rights reserved.
//

#import "OUParser.h"
#import "RXMLElement.h"
#import "OULesson.h"
#import "NSArray+Helpers.h"

@implementation OUParser

+ (void)parseMainInfo:(NSData *)XMLData {

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
        teacher.teacherName = [teacherElement child:@"TEACHER_FIO"].text;
        [teachers addObject:teacher];
    }];

    [rootElement iterate:@"AUDITORIES.AUDITORY_ID" usingBlock:^(RXMLElement *auditoryElement) {
        OUAuditory *auditory = [OUAuditory new];
        auditory.auditoryName = auditoryElement.text;
        [auditories addObject:auditory];
    }];

    NSLog(@"%@", [groups logElements]);
    NSLog(@"%@", [teachers logElements]);
    NSLog(@"%@", [auditories logElements]);
}

+ (void)parseLessons:(NSData *)XMLData forGroup:(OUGroup *)group {
    NSMutableArray *lessons = [NSMutableArray  array];

    RXMLElement *rootElement = [RXMLElement elementFromXMLData:XMLData];

    __block NSString *weekDay;

    [rootElement iterate:@"WEEKDAY" usingBlock:^(RXMLElement *weekDayElement) {
        weekDay = [weekDayElement attribute:@"value"];
        [weekDayElement iterate:@"DESCRIPTION.SCHEDULE.SCHEDULE_PARAM" usingBlock:^(RXMLElement *lessonElement) {
            OULesson *lesson = [OULesson new];

            if (group) {
                lesson.groups = @[group];
            }

            lesson.weekDay = weekDay;

            lesson.timeInterval = [[lessonElement child:@"TIME_INTERVAL"] text];
            OULessonTime startTime;
            OULessonTime finishTime;
            if (![self startTime:&startTime finishTime:&finishTime fromString:lesson.timeInterval]) {
                lesson.startTime = startTime;
                lesson.finishTime = finishTime;
            }

            lesson.weekType = [OULesson weekTypeFromString:[[lessonElement child:@"WEEK"] text]];

            lesson.address = [[lessonElement child:@"PLACE"] text];

            lesson.title = [[lessonElement child:@"SUBJECT"] text];

            lesson.type = [OULesson lessonTypeFromString:lesson.title];

            OUTeacher *teacher = [[OUTeacher alloc] init];
            teacher.teacherName = [[lessonElement child:@"LECTURER"] text];
            teacher.teacherId = [[lessonElement child:@"LECTUTER_ID"] text];
            lesson.teacher = teacher;

            [lessons addObject:lesson];
        }];
    }];

    NSLog(@"%@", [lessons logElements]);
}

+ (void)parseLessons:(NSData *)XMLData forAuditory:(OUAuditory *)auditory {
    NSMutableArray *lessons = [NSMutableArray  array];

    RXMLElement *rootElement = [RXMLElement elementFromXMLData:XMLData];

    __block NSString *weekDay;

    [rootElement iterate:@"WEEKDAY" usingBlock:^(RXMLElement *weekDayElement) {
        weekDay = [weekDayElement attribute:@"value"];
        [weekDayElement iterate:@"DESCRIPTION_A.SCHEDULE.SCHEDULE_PARAM_A" usingBlock:^(RXMLElement *lessonElement) {
            OULesson *lesson = [OULesson new];

            lesson.groups = [self groupsFromString:[lessonElement child:@"GROUP_NUMBER"].text];
            lesson.weekDay = weekDay;

            lesson.timeInterval = [[lessonElement child:@"TIME_INTERVAL"] text];
            OULessonTime startTime;
            OULessonTime finishTime;
            if (![self startTime:&startTime finishTime:&finishTime fromString:lesson.timeInterval]) {
                lesson.startTime = startTime;
                lesson.finishTime = finishTime;
            }

            lesson.weekType = [OULesson weekTypeFromString:[[lessonElement child:@"WEEK"] text]];
            lesson.address = [[lessonElement child:@"PLACE"] text];
            lesson.title = [[lessonElement child:@"SUBJECT"] text];
            lesson.type = [OULesson lessonTypeFromString:lesson.title];

            OUTeacher *teacher = [[OUTeacher alloc] init];
            teacher.teacherName = [[lessonElement child:@"LECTURER"] text];
            teacher.teacherId = [[lessonElement child:@"LECTUTER_ID"] text];
            lesson.teacher = teacher;
            
            [lessons addObject:lesson];
        }];
    }];

    NSLog(@"%@", [lessons logElements]);
}

+ (void)parseLessons:(NSData *)XMLData forTeacher:(OUTeacher *)teacher {
    NSMutableArray *lessons = [NSMutableArray  array];

    RXMLElement *rootElement = [RXMLElement elementFromXMLData:XMLData];

    __block NSString *weekDay;

    [rootElement iterate:@"WEEKDAY" usingBlock:^(RXMLElement *weekDayElement) {
        weekDay = [weekDayElement attribute:@"value"];
        [weekDayElement iterate:@"DESCRIPTION_P.SCHEDULE.SCHEDULE_PARAM_P" usingBlock:^(RXMLElement *lessonElement) {
            OULesson *lesson = [OULesson new];

            lesson.groups = [self groupsFromString:[lessonElement child:@"GROUP_NUMBER"].text];
            lesson.weekDay = weekDay;

            lesson.timeInterval = [[lessonElement child:@"TIME_INTERVAL"] text];
            OULessonTime startTime;
            OULessonTime finishTime;
            if (![self startTime:&startTime finishTime:&finishTime fromString:lesson.timeInterval]) {
                lesson.startTime = startTime;
                lesson.finishTime = finishTime;
            }

            lesson.weekType = [OULesson weekTypeFromString:[[lessonElement child:@"WEEK"] text]];
            lesson.address = [[lessonElement child:@"PLACE"] text];
            lesson.title = [[lessonElement child:@"SUBJECT"] text];
            lesson.type = [OULesson lessonTypeFromString:lesson.title];

            lesson.teacher = teacher;

            [lessons addObject:lesson];
        }];
    }];
    NSLog(@"%@", [lessons logElements]);
}

+ (void)parseWeekNumber:(NSData *)XMLData {
    RXMLElement *rootElement = [RXMLElement elementFromXMLData:XMLData];

    NSLog(@"%@", rootElement.text);
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
    *startTime = [startTimeComponents[0] intValue] * 100 + [startTimeComponents[1] intValue];

    NSArray *finishTimeComponents = [finishTimeString componentsSeparatedByString:@":"];
    *finishTime = [finishTimeComponents[0] intValue] * 100 + [finishTimeComponents[1] intValue];

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
