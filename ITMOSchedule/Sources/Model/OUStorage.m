//
//  OUStorage.m
//  ITMOSchedule
//
//  Created by Ruslan Kavetsky on 04/12/13.
//  Copyright (c) 2013 Ruslan Kavetsky. All rights reserved.
//

#import "OUStorage.h"

@implementation OUStorage

#define STORAGE_KEY_MAIN_INFO               @"storageKeyMainInfo"
#define STORAGE_KEY_LESSONS                 @"storageKeyLessons"
#define STORAGE_KEY_LESSON_TYPE             @"storageKeyLessonType"
#define STORAGE_KEY_WEEK_NUMBER             @"storageKeyWeekNumber"
#define STORAGE_KEY_FISRT_LOAD              @"storageKeyFirstLoad"
#define STORAGE_KEY_LAST_WEEK_NUMBER_UPDATE @"storageKeyLastWeekNumberUpdate"

+ (instancetype)sharedInstance {
    static OUStorage *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [OUStorage new];
    });
    return sharedInstance;
}

#pragma mark - Main info

- (void)setMainInfo:(NSDictionary *)mainInfo {
    [self saveObject:mainInfo forKey:STORAGE_KEY_MAIN_INFO archive:YES];
}

- (NSDictionary *)mainInfo {
	NSUserDefaults *defaults = [self userDefaults];
	NSData *mainInfoData = [defaults objectForKey:STORAGE_KEY_MAIN_INFO];

	if (mainInfoData != nil) {
		return [NSKeyedUnarchiver unarchiveObjectWithData:mainInfoData];
	} else {
		return nil;
	}
}

#pragma mark - Lessons

- (void)setLessons:(NSArray *)lessons {
    [self saveObject:lessons forKey:STORAGE_KEY_LESSONS archive:YES];
}

- (NSArray *)lessons {
	NSUserDefaults *defaults = [self userDefaults];
	NSData *lessonsData = [defaults objectForKey:STORAGE_KEY_LESSONS];

	if (lessonsData != nil) {
		return [NSKeyedUnarchiver unarchiveObjectWithData:lessonsData];
	} else {
		return nil;
	}
}

#pragma mark - Lesson type

- (void)setLessonType:(id)lessonType {
    [self saveObject:lessonType forKey:STORAGE_KEY_LESSON_TYPE archive:YES];
}

- (id)lessonType {
	NSUserDefaults *defaults = [self userDefaults];
	NSData *lessonTypeData = [defaults objectForKey:STORAGE_KEY_LESSON_TYPE];

	if (lessonTypeData != nil) {
		return [NSKeyedUnarchiver unarchiveObjectWithData:lessonTypeData];
	} else {
		return nil;
	}
}

#pragma mark - Week number

- (void)setWeekNumber:(NSNumber *)weekNumber {
    [self saveObject:weekNumber forKey:STORAGE_KEY_WEEK_NUMBER archive:NO];
}

- (NSNumber *)weekNumber {
    NSUserDefaults *defaults = [self userDefaults];
    return [defaults objectForKey:STORAGE_KEY_WEEK_NUMBER];
}

#pragma mark - Last week number update date

- (void)setLastWeekNumberUpdate:(NSDate *)lastWeekNumberUpdate {
    [self saveObject:lastWeekNumberUpdate forKey:STORAGE_KEY_LAST_WEEK_NUMBER_UPDATE archive:NO];
}

- (NSDate *)lastWeekNumberUpdate {
    return [[self userDefaults] objectForKey:STORAGE_KEY_LAST_WEEK_NUMBER_UPDATE];
}

#pragma mark - is first load

- (void)setIsAlreadyShowTutorial:(BOOL)isAlreadyShowTutorial {
    NSUserDefaults *defaults = [self userDefaults];
	[defaults setBool:isAlreadyShowTutorial forKey:STORAGE_KEY_FISRT_LOAD];
	[defaults synchronize];
}

- (BOOL)isAlreadyShowTutorial {
	return [[NSUserDefaults standardUserDefaults] boolForKey:STORAGE_KEY_FISRT_LOAD];
}

#pragma mark - User defaults

- (NSUserDefaults *)userDefaults {
    return [NSUserDefaults standardUserDefaults];
}

- (void)saveObject:(id)data forKey:(id)key archive:(BOOL)archive {
    NSUserDefaults *defaults = [self userDefaults];

    if (archive) {
        NSData *dataToSave = [NSKeyedArchiver archivedDataWithRootObject:data];
        [defaults setObject:dataToSave forKey:key];
    } else {
        [defaults setObject:data forKey:key];
    }
	[defaults synchronize];
}

@end
