//
//  OURequestCoordinator.m
//  ITMOSchedule
//
//  Created by Misha on 10/9/13.
//  Copyright (c) 2013 Ruslan Kavetsky. All rights reserved.
//

#import "OUScheduleDownloader.h"
#import "AFNetworking.h"
#import "OUParser.h"

typedef void(^ParsingBlock)(NSData *data);

@implementation OUScheduleDownloader

+ (OUScheduleDownloader *) sharedInstance {
    static OUScheduleDownloader *requestCoord = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        requestCoord = [[OUScheduleDownloader alloc] init];
    });

    return requestCoord;
}

- (void)downloadMainInfo {
    NSString *pageUrlString = [NSString stringWithFormat:@"http://isu.ifmo.ru/pls/apex/PK_ADM_GETXML.GET_SCHEDULE_INFO"];
    [self performRequestWithStringUrl:pageUrlString parsingBlock:^(NSData *data) {
        [OUParser parseMainInfo:data];
    }];
}

- (void)downloadLessonsForGroup:(OUGroup *)group {
    NSString *pageUrlString = [NSString stringWithFormat:@"http://isu.ifmo.ru/pls/apex/PK_ADM_GETXML.GET_SCHEDULE_XML?group_number=%@", group.groupName];
    [self performRequestWithStringUrl:pageUrlString parsingBlock:^(NSData *data) {
        [OUParser parseLessons:data forGroup:group];
    }];
}

- (void)downloadLessonsForAuditory:(OUAuditory *)auditory {
    NSString *pageUrlString = [NSString stringWithFormat:@"http://isu.ifmo.ru/pls/apex/PK_ADM_GETXML.GET_SCHEDULE_XML?p_auditory_id=%@", auditory.auditoryName];
    [self performRequestWithStringUrl:pageUrlString parsingBlock:^(NSData *data) {
        [OUParser parseLessons:data forAuditory:auditory];
    }];
}

- (void)downloadLessonsForTeacher:(OUTeacher *)teacher {
    NSString *pageUrlString = [NSString stringWithFormat:@"http://isu.ifmo.ru/pls/apex/PK_ADM_GETXML.GET_SCHEDULE_XML?p_id=%@", teacher.teacherId];
    [self performRequestWithStringUrl:pageUrlString parsingBlock:^(NSData *data) {
        [OUParser parseLessons:data forTeacher:teacher];
    }];
}

- (void)downloadWeekNumber {
    NSString *pageUrlString = [NSString stringWithFormat:@"http://isu.ifmo.ru/pls/apex/PK_ADM_GETXML.GET_WEEK_NUMBER"];
    [self performRequestWithStringUrl:pageUrlString parsingBlock:^(NSData *data) {
        [OUParser parseWeekNumber:data];
    }];
}

- (void)performRequestWithStringUrl:(NSString *)stringUrl parsingBlock:(ParsingBlock)parsingBlock {
    NSURL *pageUrl = [NSURL URLWithString:stringUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:pageUrl];

    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (parsingBlock) {
            parsingBlock(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"DOWNLOAD ERROR: %@", error.localizedDescription);
    }];
    [operation start];
}

@end
