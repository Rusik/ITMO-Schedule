//
//  OUGroupsList.m
//  ITMOSchedule
//
//  Created by Misha on 10/9/13.
//  Copyright (c) 2013 Ruslan Kavetsky. All rights reserved.
//

#import "OUGroupsList.h"

static NSArray *_groups;

@implementation OUGroupsList

+ (void) initGroups:(NSArray *)groups {
    _groups = groups;
}

+ (NSArray *)groups {
    return _groups;
}

@end
