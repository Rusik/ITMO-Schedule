//
//  UIView+Helpers.m
//  helpers
//
//  Created by Ruslan on 12/13/12.
//  Copyright (c) 2012 Ruslan. All rights reserved.
//


#import "UIView+Helpers.h"

@implementation UIView (Helpers)

#pragma mark - Nib

+ (NSString *)nibName {
	return NSStringFromClass([self class]);
}

+ (id)loadFromNib {
	return [self loadFromNibNamed:[self nibName]];
}

+ (id)loadFromNibNamed:(NSString *)nibName {
	Class cls = [self class];
	NSArray *objects = [[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil];
	for (id object in objects) {
		if ([object isKindOfClass:cls]) {
			return object;
		}
	}
	[NSException raise:@"WrongNibFormat" format:@"Nib for '%@' must contain one UIView, and its class must be '%@'", nibName, NSStringFromClass(cls)];
	return nil;
}

#pragma mark - Rotation

- (void)rotateViewToOrientation:(UIInterfaceOrientation)orientation animated:(BOOL)animated {
	CGPoint center = self.center;
	CGRect bounds = self.bounds;
	CGAffineTransform transform = CGAffineTransformIdentity;
	switch (orientation) {
		case UIInterfaceOrientationPortrait:
			transform = CGAffineTransformIdentity;
			break;

		case UIInterfaceOrientationPortraitUpsideDown:
			transform = CGAffineTransformMakeRotation(M_PI);
			break;

		case UIInterfaceOrientationLandscapeLeft:
			transform = CGAffineTransformMakeRotation(-M_PI_2);
			break;

		case UIInterfaceOrientationLandscapeRight:
			transform = CGAffineTransformMakeRotation(M_PI_2);
			break;
	}
	if (animated) {
		[UIView beginAnimations:nil context:nil];
	}
	self.transform = transform;
	bounds = CGRectApplyAffineTransform(bounds, transform);
	self.bounds = CGRectMake(0, 0, bounds.size.width, bounds.size.height);
	self.center = center;
	if (animated) {
		[UIView commitAnimations];
	}
}

#pragma mark - Other

- (void)recursiveEnumerateSubviewsUsingBlock:(void (^)(UIView *view, BOOL *stop))block {
	if (self.subviews.count == 0) {
		return;
	}
	for (UIView *subview in self.subviews) {
		BOOL stop = NO;
		block(subview, &stop);
		if (stop) {
			return;
		}
		[subview recursiveEnumerateSubviewsUsingBlock:block];
	}
}

#pragma mark - Frame

- (void)adjustFrame:(UIViewFrameAdjustBlock)block {
	self.frame = block(self.frame);
}

- (void)moveBy:(CGPoint)offset {
	[self adjustFrame: ^CGRect (CGRect frame) {
	    frame.origin.x += offset.x;
	    frame.origin.y += offset.y;
	    return frame;
	}];
}

- (void)moveTo:(CGPoint)origin {
	[self adjustFrame: ^CGRect (CGRect frame) {
	    frame.origin = origin;
	    return frame;
	}];
}

- (void)resizeTo:(CGSize)size {
	[self adjustFrame: ^CGRect (CGRect frame) {
	    frame.size = size;
	    return frame;
	}];
}

- (void)expand:(CGSize)size {
	[self adjustFrame: ^CGRect (CGRect frame) {
	    frame.size.width += size.width;
	    frame.size.height += size.height;
	    return frame;
	}];
}

- (CGPoint)$origin {
	return self.frame.origin;
}

- (void)set$origin:(CGPoint)origin {
	self.frame = (CGRect) {.origin = origin, .size = self.frame.size };
}

- (CGFloat)$x {
	return self.frame.origin.x;
}

- (void)set$x:(CGFloat)x {
	self.frame = (CGRect) {.origin.x = x, .origin.y = self.frame.origin.y, .size = self.frame.size };
}

- (CGFloat)$y {
	return self.frame.origin.y;
}

- (void)set$y:(CGFloat)y {
	self.frame = (CGRect) {.origin.x = self.frame.origin.x, .origin.y = y, .size = self.frame.size };
}

- (CGSize)$size {
	return self.frame.size;
}

- (void)set$size:(CGSize)size {
	self.frame = (CGRect) {.origin = self.frame.origin, .size = size };
}

- (CGFloat)$width {
	return self.frame.size.width;
}

- (void)set$width:(CGFloat)width {
	self.frame = (CGRect) {.origin = self.frame.origin, .size.width = width, .size.height = self.frame.size.height };
}

- (CGFloat)$height {
	return self.frame.size.height;
}

- (void)set$height:(CGFloat)height {
	self.frame = (CGRect) {.origin = self.frame.origin, .size.width = self.frame.size.width, .size.height = height };
}

- (CGFloat)$left {
	return self.frame.origin.x;
}

- (void)set$left:(CGFloat)left {
	self.frame = (CGRect) {.origin.x = left, .origin.y = self.frame.origin.y, .size.width = fmaxf(self.frame.origin.x + self.frame.size.width - left, 0), .size.height = self.frame.size.height };
}

- (CGFloat)$top {
	return self.frame.origin.y;
}

- (void)set$top:(CGFloat)top {
	self.frame = (CGRect) {.origin.x = self.frame.origin.x, .origin.y = top, .size.width = self.frame.size.width, .size.height = fmaxf(self.frame.origin.y + self.frame.size.height - top, 0) };
}

- (CGFloat)$right {
	return self.frame.origin.x + self.frame.size.width;
}

- (void)set$right:(CGFloat)right {
	self.frame = (CGRect) {.origin = self.frame.origin, .size.width = fmaxf(right - self.frame.origin.x, 0), .size.height = self.frame.size.height };
}

- (CGFloat)$bottom {
	return self.frame.origin.y + self.frame.size.height;
}

- (void)set$bottom:(CGFloat)bottom {
	self.frame = (CGRect) {.origin = self.frame.origin, .size.width = self.frame.size.width, .size.height = fmaxf(bottom - self.frame.origin.y, 0) };
}

@end
