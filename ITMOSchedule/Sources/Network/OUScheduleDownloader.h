//
//  OURequestCoordinator.h
//  ITMOSchedule
//
//  Created by Misha on 10/9/13.
//  Copyright (c) 2013 Ruslan Kavetsky. All rights reserved.
//

/*
 Получение служебной инфы:                  http://isu.ifmo.ru/pls/apex/PK_ADM_GETXML.GET_SCHEDULE_INFO
 Получение расписания по номеру группы:     http://isu.ifmo.ru/pls/apex/PK_ADM_GETXML.GET_SCHEDULE_XML?group_number=6110
 Получение по номеру аудитории:             http://isu.ifmo.ru/pls/apex/PK_ADM_GETXML.GET_SCHEDULE_XML?p_auditory_id=302
 Получение по идентификатору преподавателя: http://isu.ifmo.ru/pls/apex/PK_ADM_GETXML.GET_SCHEDULE_XML?p_id=3E12A8828CA9D74485FA259722E10215 
 Поиск по преподавателям:                   http://isu.ifmo.ru/pls/apex/PK_ADM_GETXML.GET_SCHEDULE_XML?p_name=Цветков
 Номер недели:                              http://isu.ifmo.ru/pls/apex/PK_ADM_GETXML.GET_WEEK_NUMBER
 Чётность недели (на всякий случай):        http://isu.ifmo.ru/pls/apex/PK_ADM_GETXML.GET_ODD_WEEK
*/

#import <Foundation/Foundation.h>
#import "OUGroup.h"
#import "OUTeacher.h"
#import "OUAuditory.h"

typedef void(^CompleteBlock)(void);

@interface OUScheduleDownloader : NSObject

+ (OUScheduleDownloader *)sharedInstance;

- (void)downloadMainInfo:(CompleteBlock)block;
- (void)downloadLessonsForGroup:(OUGroup *)group complete:(CompleteBlock)block;
- (void)downloadLessonsForAuditory:(OUAuditory *)auditory complete:(CompleteBlock)block;
- (void)downloadLessonsForTeacher:(OUTeacher *)teacher complete:(CompleteBlock)block;

- (void)downloadWeekNumber:(CompleteBlock)block;

@end
