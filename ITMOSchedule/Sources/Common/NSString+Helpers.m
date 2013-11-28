//
//  NSString+Helpers.m
//  ITMOSchedule
//
//  Created by Ruslan Kavetsky on 10/14/13.
//  Copyright (c) 2013 Ruslan Kavetsky. All rights reserved.
//

#import "NSString+Helpers.h"

@implementation NSString (Helpers)

- (NSString *)stringByDeletingDataInBrackets {
    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:@"\\(.*\\)" options:0 error:0];
    return [regexp stringByReplacingMatchesInString:self options:0 range:NSMakeRange(0, self.length) withTemplate:@""];
}

- (NSString *)stringFromBrackets {
    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:@"\\(.*\\)" options:0 error:0];
    NSTextCheckingResult *result = [[regexp matchesInString:self options:0 range:NSMakeRange(0, self.length)] firstObject];
    return [self substringWithRange:NSMakeRange(result.range.location + 1, result.range.length - 2)];
}

- (NSString *)stringByDeletingNewLineCharacters {
    return [self stringByReplacingOccurrencesOfString:@"\n" withString:@"," options:0 range:NSMakeRange(0, self.length)];
}

- (NSString *)stringWithSpaceAfterCommaAndDot {

    NSMutableString *newString = [NSMutableString new];

    for (int i = 0; i < self.length; i++) {

        NSString *c = [self substringWithRange:NSMakeRange(i, 1)];

        if ([c isEqualToString:@","]) {


            if (i + 1 < self.length) {

                NSString *next = [self substringWithRange:NSMakeRange(i + 1, 1)];

                if ([next rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].location != NSNotFound) {
                    [newString appendString:c];
                } else {
                    [newString appendFormat:@", "];
                }
            }


        } else if ([c isEqualToString:@"."]) {


            if (i + 1 < self.length) {

                NSString *next = [self substringWithRange:NSMakeRange(i + 1, 1)];

                if ([next rangeOfCharacterFromSet:[NSCharacterSet alphanumericCharacterSet]].location != NSNotFound) {
                    [newString appendFormat:@". "];
                } else {
                    [newString appendString:c];
                }
            }


        } else {
            [newString appendString:c];
        }
        
    }

    return [newString copy];

//    return [self stringByReplacingOccurrencesOfString:@"," withString:@", " options:0 range:NSMakeRange(0, self.length)];
}

@end
