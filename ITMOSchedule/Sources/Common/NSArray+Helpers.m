//
//  NSArray+Helpers.m
//  ITMOSchedule
//
//  Created by Ruslan Kavetsky on 10/9/13.
//  Copyright (c) 2013 Ruslan Kavetsky. All rights reserved.
//

#import "NSArray+Helpers.h"

@implementation NSArray (Helpers)

- (NSString *)logElements {
    NSMutableString *string = [NSMutableString string];
    [string appendString:@"(\n"];
    for (NSObject *o in self) {
        if ([o isKindOfClass:[NSArray class]]) {
            [string appendFormat:@"%@\n", [(NSArray *)o logElements]];
        } else {
            [string appendFormat:@"%@\n", o];
        }
    }
    [string appendString:@")"];
    return [string copy];
}

@end
