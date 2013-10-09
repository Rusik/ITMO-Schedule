//
//  OURequestCoordinator.m
//  ITMOSchedule
//
//  Created by Misha on 10/9/13.
//  Copyright (c) 2013 Ruslan Kavetsky. All rights reserved.
//

#import "OURequestCoordinator.h"
#import "AFNetworking.h"
#import "OUParser.h"

@implementation OURequestCoordinator

+(OURequestCoordinator *) sharedInstance {
    static OURequestCoordinator *requestCoord = nil;
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^
                  {
                      requestCoord = [[OURequestCoordinator alloc] init];
                  });

    return requestCoord;
}

- (void)performMainRequest {
    NSString *pageUrlString = [NSString stringWithFormat:@"http://isu.ifmo.ru/pls/apex/PK_ADM_GETXML.GET_SCHEDULE_INFO"];
    NSURL *pageUrl = [NSURL URLWithString:pageUrlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:pageUrl];

    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation
     setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         [OUParser parseMainInfoXML:responseObject];

     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"error!");
     }
     ];
    [operation start];
}

@end
