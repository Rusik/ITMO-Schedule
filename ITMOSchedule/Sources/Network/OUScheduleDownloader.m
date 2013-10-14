//
//  OURequestCoordinator.m
//  ITMOSchedule
//
//  Created by Misha on 10/9/13.
//  Copyright (c) 2013 Ruslan Kavetsky. All rights reserved.
//

#import "OUScheduleDownloader.h"
#import "OUScheduleCoordinator.h"
#import "AFNetworking.h"
#import "OUParser.h"

#define LOG 1

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

- (void)downloadMainInfo:(CompleteBlock)block {
    NSString *pageUrlString = [NSString stringWithFormat:@"http://isu.ifmo.ru/pls/apex/PK_ADM_GETXML.GET_SCHEDULE_INFO"];
    [self performRequestWithStringUrl:pageUrlString parsingBlock:^(NSData *data) {
        [[OUScheduleCoordinator sharedInstance] setMainInfo:[OUParser parseMainInfo:data]];
    } complete:block];
}

- (void)downloadLessonsForGroup:(OUGroup *)group complete:(CompleteBlock)block {
    NSString *pageUrlString = [NSString stringWithFormat:@"http://isu.ifmo.ru/pls/apex/PK_ADM_GETXML.GET_SCHEDULE_XML?group_number=%@", group.groupName];
    [self performRequestWithStringUrl:pageUrlString parsingBlock:^(NSData *data) {
        [[OUScheduleCoordinator sharedInstance] setLessons:[OUParser parseLessons:data forGroup:group] forGroup:group];
    } complete:block];
}

- (void)downloadLessonsForAuditory:(OUAuditory *)auditory complete:(CompleteBlock)block {
    NSString *pageUrlString = [NSString stringWithFormat:@"http://isu.ifmo.ru/pls/apex/PK_ADM_GETXML.GET_SCHEDULE_XML?p_auditory_id=%@", auditory.auditoryName];
    [self performRequestWithStringUrl:pageUrlString parsingBlock:^(NSData *data) {
        [[OUScheduleCoordinator sharedInstance] setLessons:[OUParser parseLessons:data forAuditory:auditory] forAuditory:auditory];
    } complete:block];
}

- (void)downloadLessonsForTeacher:(OUTeacher *)teacher complete:(CompleteBlock)block {
    NSString *pageUrlString = [NSString stringWithFormat:@"http://isu.ifmo.ru/pls/apex/PK_ADM_GETXML.GET_SCHEDULE_XML?p_id=%@", teacher.teacherId];
    [self performRequestWithStringUrl:pageUrlString parsingBlock:^(NSData *data) {
        [[OUScheduleCoordinator sharedInstance] setLessons:[OUParser parseLessons:data forTeacher:teacher] forTeacher:teacher];
    } complete:block];
}

- (void)downloadWeekNumber:(CompleteBlock)block {
    NSString *pageUrlString = [NSString stringWithFormat:@"http://isu.ifmo.ru/pls/apex/PK_ADM_GETXML.GET_WEEK_NUMBER"];
    [self performRequestWithStringUrl:pageUrlString parsingBlock:^(NSData *data) {
        [[OUScheduleCoordinator sharedInstance] setWeekNumber:[OUParser parseWeekNumber:data]];
    } complete:block];
}

- (void)performRequestWithStringUrl:(NSString *)stringUrl parsingBlock:(ParsingBlock)parsingBlock complete:(CompleteBlock)completeBlock {
    NSURL *pageUrl = [NSURL URLWithString:[stringUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURLRequest *request = [NSURLRequest requestWithURL:pageUrl];

    if (LOG) NSLog(@"REQUEST: %@", pageUrl);

    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {

        if (parsingBlock) parsingBlock(responseObject);
        if (completeBlock) completeBlock();

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"DOWNLOAD ERROR: %@", error.localizedDescription);
    }];
    [operation start];
}

@end
