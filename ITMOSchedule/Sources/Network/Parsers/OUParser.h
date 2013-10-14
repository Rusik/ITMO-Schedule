//
//  OUParser.h
//  ITMOSchedule
//
//  Created by Misha on 10/9/13.
//  Copyright (c) 2013 Ruslan Kavetsky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OUParser : NSObject

+ (NSDictionary *)parseMainInfo:(NSData *)XMLData;
+ (NSArray *)parseLessons:(NSData *)XMLData forGroup:(OUGroup *)group;
+ (NSArray *)parseLessons:(NSData *)XMLData forAuditory:(OUAuditory *)auditory;
+ (NSArray *)parseLessons:(NSData *)XMLData forTeacher:(OUTeacher *)teacher;
+ (int)parseWeekNumber:(NSData *)XMLData;

@end
