//
//  OUTeacherCell.m
//  ITMOSchedule
//
//  Created by Ruslan Kavetsky on 10/14/13.
//  Copyright (c) 2013 Ruslan Kavetsky. All rights reserved.
//

#import "OUTeacherCell.h"

@implementation OUTeacherCell

- (void)setLesson:(OULesson *)lesson {
    [super setLesson:lesson];
    [self fillDataWithLesson:lesson];
}

- (void)fillDataWithLesson:(OULesson *)lesson {
    if (lesson.timeInterval) {
        self.timeLabel.text = lesson.timeInterval;
    } else {
        NSString *startTime = [NSString stringWithFormat:@"%2d:%.2d", lesson.startTime / 100, lesson.startTime % 100];
        NSString *finishTime = [NSString stringWithFormat:@"%2d:%.2d", lesson.finishTime / 100, lesson.finishTime % 100];
        self.timeLabel.text = [NSString stringWithFormat:@"%@\n%@", startTime, finishTime];
    }

    NSMutableString *groupsString = [[NSMutableString alloc] init];
    for (OUGroup *group in lesson.groups) {
        [groupsString appendFormat:@"%@, ",group.groupName];
    }
    [groupsString replaceCharactersInRange:NSMakeRange(groupsString.length - 2, 2) withString:@""];


    self.topLabel.text = groupsString;
    self.centerLabel.text = lesson.lessonName;
    self.bottomLabel.text = lesson.address;
}

@end



/*
 typedef enum {
 OULessonWeekTypeAny     = 0,    // пара каждую неделю
 OULessonWeekTypeOdd     = 1,    // пара по нечётным дням
 OULessonWeekTypeEven    = 2     // пара по чётным дням
 } OULessonWeekType;

 typedef enum {
 OULessonTypeLecture     = 0,    // Лекция
 OULessonTypeLaboratory  = 1,    // Лабораторная
 OULessonTypeStudent     = 2,    // СРС
 OULessonTypePractice    = 3,    // Практика
 OULessonTypeUnknown     = 4
 } OULessonType;

 typedef enum {
 OULessonWeekDayMonday       = 0,
 OULessonWeekDayTuesdya      = 1,
 OULessonWeekDayWednesday    = 2,
 OULessonWeekDayThursday     = 3,
 OULessonWeekDayFriday       = 4,
 OULessonWeekDaySunday       = 5,
 OULessonWeekDaySaturday     = 6,
 } OULessonWeekDay;


 typedef int OULessonTime;

 @interface OULesson : NSObject

 @property (nonatomic, copy) NSString *timeInterval;
 @property (nonatomic) OULessonTime startTime;
 @property (nonatomic) OULessonTime finishTime;

 @property (nonatomic) OULessonWeekType weekType;

 @property (nonatomic, copy) NSString *address;

 @property (nonatomic, copy) NSString *lessonName;

 @property (nonatomic, strong) OUTeacher *teacher;

 @property (nonatomic) OULessonType lessonType;
 @property (nonatomic) NSString *lessonTypeString;

 @property (nonatomic) OULessonWeekDay weekDay;

 @property (nonatomic) NSArray *groups; // Либо одна группа, либо список групп (для преподов и аудиторий)

 + (OULessonWeekType)weekTypeFromString:(NSString *)string;

 + (OULessonType)lessonTypeFromString:(NSString *)string;
 + (NSString *)fullStringForLessonType:(OULessonType)lessonType;
 + (NSString *)shortStringForLessonType:(OULessonType)lessonType;

 + (OULessonWeekDay)weekDayFromString:(NSString *)string;
 + (NSString *)stringFromWeekDay:(OULessonWeekDay)weekDay;
 + (NSArray *)weekDays;

*/