//
//  OULesson.m
//  ITMOSchedule
//
//  Created by Ruslan Kavetsky on 10/10/13.
//  Copyright (c) 2013 Ruslan Kavetsky. All rights reserved.
//

#import "OULesson.h"

@implementation OULesson

+ (OULessonWeekType)weekTypeFromString:(NSString *)string {

    if (!string) return OULessonWeekTypeAny;

    if ([string rangeOfString:@"неч" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        return OULessonWeekTypeOdd;
    } else if ([string rangeOfString:@"чет" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        return OULessonWeekTypeEven;
    } else {
        return OULessonWeekTypeAny;
    }
}

+ (OULessonType)lessonTypeFromString:(NSString *)string {

    if (!string) return OULessonTypeUnknown;

    if ([string rangeOfString:@"лекци" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        return OULessonTypeLecture;
    }
    if ([string rangeOfString:@"практи" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        return OULessonTypePractice;
    }
    if ([string rangeOfString:@"срс" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        return OULessonTypeStudent;
    }
    if ([string rangeOfString:@"лабора" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        return OULessonTypeLaboratory;
    }
    return OULessonTypeUnknown;
}

+ (NSString *)fullStringForLessonType:(OULessonType)lessonType {
    switch (lessonType) {
        case OULessonTypeLaboratory:
            return @"Лабораторная";
            break;
        case OULessonTypePractice:
            return @"Практика";
            break;
        case OULessonTypeLecture:
            return @"Лекция";
            break;
        case OULessonTypeStudent:
            return @"СРС";
            break;
        default:
            return nil;
            break;
    }
}

+ (NSString *)shortStringForLessonType:(OULessonType)lessonType {
    switch (lessonType) {
        case OULessonTypeLaboratory:
            return @"Лаб";
            break;
        case OULessonTypePractice:
            return @"Прак";
            break;
        case OULessonTypeLecture:
            return @"Лек";
            break;
        case OULessonTypeStudent:
            return @"СРС";
            break;
        default:
            return nil;
            break;
    }
}

+ (OULessonWeekDay)weekDayFromString:(NSString *)string {
    NSArray *days = @[@"пон", @"вт", @"ср", @"чет", @"пят", @"суб", @"воск"];
    for (NSString *day in days) {
        if ([string rangeOfString:day options:NSCaseInsensitiveSearch].location != NSNotFound) {
            return [days indexOfObject:day];
        }
    }
    NSLog(@"ERROR %s", __PRETTY_FUNCTION__);
    return -1;
}

+ (NSString *)stringFromWeekDay:(OULessonWeekDay)weekDay {
    NSArray *days = [self weekDays];
    return [days objectAtIndex:weekDay];
}

+ (NSArray *)weekDays {
    return @[@"Понедельник", @"Вторник", @"Среда", @"Четверг", @"Пятница", @"Суббота", @"Воскресенье"];
}

#pragma mark - Decoding

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        self.lessonName = [decoder decodeObjectForKey:@"lessonName"];
        self.lessonType = [[decoder decodeObjectForKey:@"lessonType"] intValue];
        self.lessonTypeString = [decoder decodeObjectForKey:@"lessonTypeString"];
        self.auditory = [decoder decodeObjectForKey:@"auditory"];
        self.teacher = [decoder decodeObjectForKey:@"teacher"];
        self.timeInterval = [decoder decodeObjectForKey:@"timeInterval"];
        self.startTime = [[decoder decodeObjectForKey:@"startTime"] intValue];
        self.finishTime = [[decoder decodeObjectForKey:@"finishTime"] intValue];
        self.weekType = [[decoder decodeObjectForKey:@"weekType"] intValue];
        self.weekDay = [[decoder decodeObjectForKey:@"weekDay"] intValue];
        self.additionalInfo = [decoder decodeObjectForKey:@"additionalInfo"];
        self.groups = [decoder decodeObjectForKey:@"groups"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.lessonName forKey:@"lessonName"];
    [encoder encodeObject:@(self.lessonType) forKey:@"lessonType"];
    [encoder encodeObject:self.lessonTypeString forKey:@"lessonTypeString"];
    [encoder encodeObject:self.auditory forKey:@"auditory"];
    [encoder encodeObject:self.teacher forKey:@"teacher"];
    [encoder encodeObject:self.timeInterval forKey:@"timeInterval"];
    [encoder encodeObject:@(self.startTime) forKey:@"startTime"];
    [encoder encodeObject:@(self.finishTime) forKey:@"finishTime"];
    [encoder encodeObject:@(self.weekType) forKey:@"weekType"];
    [encoder encodeObject:@(self.weekDay) forKey:@"weekDay"];
    [encoder encodeObject:self.additionalInfo forKey:@"additionalInfo"];
    [encoder encodeObject:self.groups forKey:@"groups"];
}

@end
