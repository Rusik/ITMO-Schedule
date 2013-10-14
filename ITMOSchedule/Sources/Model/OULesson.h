//
//  OULesson.h
//  ITMOSchedule
//
//  Created by Ruslan Kavetsky on 10/10/13.
//  Copyright (c) 2013 Ruslan Kavetsky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OUTeacher.h"

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
@property (nonatomic) NSString *typeString;

@property (nonatomic, copy) NSString *weekDay;

@property (nonatomic) NSArray *groups; // Либо одна группа, либо список групп (для преподов и аудиторий)

+ (OULessonWeekType)weekTypeFromString:(NSString *)string;

+ (OULessonType)lessonTypeFromString:(NSString *)string;
+ (NSString *)fullStringForLessonType:(OULessonType)lessonType;
+ (NSString *)shortStringForLessonType:(OULessonType)lessonType;


@end
