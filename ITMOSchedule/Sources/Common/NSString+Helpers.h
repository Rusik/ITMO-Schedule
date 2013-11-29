//
//  NSString+Helpers.h
//  ITMOSchedule
//
//  Created by Ruslan Kavetsky on 10/14/13.
//  Copyright (c) 2013 Ruslan Kavetsky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Helpers)

- (NSString *)stringByDeletingDataInBrackets;
- (NSString *)stringFromBrackets;
- (NSString *)stringByDeletingNewLineCharacters;

- (NSString *)stringWithSpaceAfterCommaAndDot;
- (NSString *)fixCommaSpaces;

@end
