//
//  UILabel+Adjust.m
//  ITMOSchedule
//
//  Created by Ruslan Kavetsky on 10/21/13.
//  Copyright (c) 2013 Ruslan Kavetsky. All rights reserved.
//

#import "UILabel+Adjust.h"

@implementation UILabel (Adjust)

- (void)adjustSizeWithMaximumWidth:(CGFloat)minWidth {
    [self adjustSizeWithMaximumWidth:minWidth withFont:self.font];
}

- (void)adjustSizeWithMaximumWidth:(CGFloat)minWidth withFont:(UIFont *)font {

    CGRect rect;
    if (!self.attributedText) {
        rect = [self.text boundingRectWithSize:CGSizeMake(minWidth, MAXFLOAT)
                                       options:NSLineBreakByWordWrapping | NSStringDrawingUsesLineFragmentOrigin
                                    attributes:@{NSFontAttributeName: self.font}
                                       context:0];
    } else {
        rect = [self.attributedText boundingRectWithSize:CGSizeMake(minWidth, MAXFLOAT)
                                                 options:NSLineBreakByWordWrapping | NSStringDrawingUsesLineFragmentOrigin
                                                 context:0];
    }

    self.$size = rect.size;
    CGPoint origin = self.$origin;
    self.frame = CGRectIntegral(self.frame);
    self.$origin = origin;
}

@end
