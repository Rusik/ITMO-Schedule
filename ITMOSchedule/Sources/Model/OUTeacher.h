//
//  OUTeacher.h
//  ITMOSchedule
//
//  Created by Misha on 10/9/13.
//  Copyright (c) 2013 Ruslan Kavetsky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OUTeacher : NSObject

+ (OUTeacher *)teacherWithName:(NSString *)teacherName id:(NSString *)teacherId;
+ (OUTeacher *)teacherWithName:(NSString *)teacherName;
+ (OUTeacher *)teacherWithId:(NSString *)teacherId;

@property (nonatomic, copy) NSString *teacherName;
@property (nonatomic, copy) NSString *teaherPosition; //должность
@property (nonatomic, copy) NSString *teacherId;

@end
