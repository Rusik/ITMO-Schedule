//
//  UIFont+PreferedFontSize.m
//  ITMOSchedule
//
//  Created by Ruslan Kavetsky on 21/11/13.
//  Copyright (c) 2013 Ruslan Kavetsky. All rights reserved.
//

#import "UIFont+PreferedFontSize.h"

@implementation UIFont (PreferedFontSize)

+ (UIFont *)preferredTimeFont {
    CGFloat fontSize = 0.0;
    NSString *fontName = nil;
	NSString *contentSize = [UIApplication sharedApplication].preferredContentSizeCategory;

	if ([contentSize isEqualToString:UIContentSizeCategoryExtraSmall]) {
		fontSize = 10.0;
        fontName = @"HelveticaNeue-Bold";

	} else if ([contentSize isEqualToString:UIContentSizeCategorySmall]) {
		fontSize = 11.0;
        fontName = @"HelveticaNeue-Bold";

	} else if ([contentSize isEqualToString:UIContentSizeCategoryMedium]) {
		fontSize = 12.0;
        fontName = @"HelveticaNeue-Bold";

	} else if ([contentSize isEqualToString:UIContentSizeCategoryLarge]) {
		fontSize = 12.0;
        fontName = @"HelveticaNeue-Bold";

	} else if ([contentSize isEqualToString:UIContentSizeCategoryExtraLarge]) {
		fontSize = 13.0;
        fontName = @"HelveticaNeue-Medium";

	} else if ([contentSize isEqualToString:UIContentSizeCategoryExtraExtraLarge]) {
		fontSize = 14.0;
        fontName = @"HelveticaNeue-Medium";

	} else if ([contentSize isEqualToString:UIContentSizeCategoryExtraExtraExtraLarge]) {
		fontSize = 15.0;
        fontName = @"HelveticaNeue-Medium";
	}

    return [UIFont fontWithName:fontName size:fontSize];
}

@end
