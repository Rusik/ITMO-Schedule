//
//  OUScheduleCoordinator.h
//  ITMOSchedule
//
//  Created by Ruslan Kavetsky on 10/9/13.
//  Copyright (c) 2013 Ruslan Kavetsky. All rights reserved.
//

#import <Foundation/Foundation.h>

#define GROUPS_INFO_KEY     @"groups"
#define TEACHERS_INFO_KEY   @"teachers"
#define AUDITORIES_INFO_KEY @"auditories"

@interface OUScheduleCoordinator : NSObject

+ (OUScheduleCoordinator *)sharedInstance;

- (NSArray *)mainInfoDataForString:(NSString *)string;

@property (nonatomic, retain) NSDictionary *mainInfo;

- (void)setLessons:(NSArray *)lessons forGroup:(OUGroup *)group;
- (void)setLessons:(NSArray *)lessons forTeacher:(OUTeacher *)teacher;
- (void)setLessons:(NSArray *)lessons forAuditory:(OUAuditory *)auditory;

- (id)lessonsType; // return OUGroup, OUTeacher or OUAuditory
- (NSArray *)lessons;

- (NSArray *)weekDaysForWeekType:(OULessonWeekType)weekType;
- (NSArray *)lessonsForDay:(OULessonWeekDay)weekDay weekType:(OULessonWeekType)weekType;
- (NSArray *)lessonsForDayString:(NSString *)weekDayString weekType:(OULessonWeekType)weekType;

@property (nonatomic) int currentWeekNumber;

- (OULessonWeekType)currentWeekType;

@end
