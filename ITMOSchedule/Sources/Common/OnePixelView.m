//
//  OnePixelView.m
//  Rezzie
//
//  Created by Ruslan Kavetsky on 25/10/13.
//  Copyright (c) 2013 Oumobile. All rights reserved.
//

#import "OnePixelView.h"

#define IS_RETINA ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && ([UIScreen mainScreen].scale == 2.0))

@implementation OnePixelView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initilize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initilize];
    }
    return self;
}

- (void)initilize {
    CGRect frame = self.frame;
    if (IS_RETINA) {
        frame.size.height = 0.5;
        frame.origin.y += 0.5;
    } else {
        frame.size.height = 1;
    }
    self.frame = frame;
}

@end
