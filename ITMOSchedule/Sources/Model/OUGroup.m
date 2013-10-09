//
//  OUGroup.m
//  ITMOSchedule
//
//  Created by Misha on 10/9/13.
//  Copyright (c) 2013 Ruslan Kavetsky. All rights reserved.
//

#import "OUGroup.h"

@implementation OUGroup

+ (OUGroup *)groupWithName:(NSString *)groupName {
    OUGroup *group = [OUGroup new];
    group.groupName = groupName;
    return group;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ {groupName : %@}", NSStringFromClass([self class]), _groupName];
}

@end
