//
//  OUStorage.h
//  ITMOSchedule
//
//  Created by Ruslan Kavetsky on 04/12/13.
//  Copyright (c) 2013 Ruslan Kavetsky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OUStorage : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic) NSDictionary *mainInfo;
@property (nonatomic) NSArray *lessons;
@property (nonatomic) id lessonType; // return OUGroup, OUTeacher or OUAuditory

@property (nonatomic) NSNumber *weekNumber;
@property (nonatomic) NSDate *lastWeekNumberUpdate;

@property (nonatomic) BOOL isAlreadyShowTutorial;

@end
