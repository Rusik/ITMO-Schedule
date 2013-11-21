//
//  UILabel+Adjust.h
//  ITMOSchedule
//
//  Created by Ruslan Kavetsky on 10/21/13.
//  Copyright (c) 2013 Ruslan Kavetsky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (Adjust)

- (void)adjustSizeWithMaximumWidth:(CGFloat)minWidth;
- (void)adjustSizeWithMaximumWidth:(CGFloat)minWidth withFont:(UIFont *)font;

@end
