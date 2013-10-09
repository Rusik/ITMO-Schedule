//
//  OUParser.h
//  ITMOSchedule
//
//  Created by Misha on 10/9/13.
//  Copyright (c) 2013 Ruslan Kavetsky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OUAuditory.h"
#import "OUTeacher.h"
#import "OUGroup.h"

@interface OUParser : NSObject

+ (void)parseMainInfo:(NSData *)XMLData;
+ (void)parseLessons:(NSData *)XMLData forGroup:(OUGroup *)group;
+ (void)parseLessons:(NSData *)XMLData forAuditory:(OUAuditory *)auditory;
+ (void)parseLessons:(NSData *)XMLData forTeacher:(OUTeacher *)teacher;
+ (void)parseWeekNumber:(NSData *)XMLData;

@end
