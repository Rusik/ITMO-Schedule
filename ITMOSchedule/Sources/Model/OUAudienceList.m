//
//  OUAudienceList.m
//  ITMOSchedule
//
//  Created by Misha on 10/9/13.
//  Copyright (c) 2013 Ruslan Kavetsky. All rights reserved.
//

#import "OUAudienceList.h"

static NSArray *_audiences;

@implementation OUAudienceList

+ (void) initAudiences:(NSArray *)audiences {
    _audiences = audiences;
}

+ (NSArray *)audiences {
    return _audiences;
}

@end
