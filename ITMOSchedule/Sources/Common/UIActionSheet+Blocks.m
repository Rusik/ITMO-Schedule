//
//  UIActionSheet+Blocks.m
//  Sample
//
//  Created by Ruslan Kavetsky on 10/11/13.
//  Copyright (c) 2013 Ruslan Kavetsky. All rights reserved.
//

#import "UIActionSheet+Blocks.h"
#import <objc/runtime.h>


static NSString *RK_BUTTON_ASS_KEY = @"com.rk.items";
static NSString *RK_DISMISSAL_ACTION_KEY = @"rk.dismissal_action";


@interface RKBlockItem : NSObject

@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) RKBlockAction action;

+ (RKBlockItem *)item;
+ (RKBlockItem *)itemWithString:(NSString *)string;
+ (RKBlockItem *)itemWithString:(NSString *)string action:(RKBlockAction)action;

@end

@implementation RKBlockItem

+ (RKBlockItem *)item {
	return [self itemWithString:nil action:nil];
}

+ (RKBlockItem *)itemWithString:(NSString *)string {
	return [self itemWithString:string action:nil];
}

+ (RKBlockItem *)itemWithString:(NSString *)string action:(RKBlockAction)action {
	RKBlockItem *item = [[RKBlockItem alloc] init];
	item.text = string;
	item.action = action;
	return item;
}

@end




@interface UIActionSheet (blocks_implementation) <UIActionSheetDelegate>

- (id)      initWithTitle:(NSString *)title
         cancelButtonItem:(RKBlockItem *)cancelButtonItem
    destructiveButtonItem:(RKBlockItem *)destructiveItem
         otherButtonItems:(RKBlockItem *)otherButtonItems, ...NS_REQUIRES_NIL_TERMINATION;

- (NSInteger)addButtonItem:(RKBlockItem *)item;

@property (copy, nonatomic) RKBlockAction dismissAction_;

@end


@implementation UIActionSheet (blocks_implementation)

- (id)      initWithTitle:(NSString *)title
         cancelButtonItem:(RKBlockItem *)cancelButtonItem
    destructiveButtonItem:(RKBlockItem *)destructiveItem
         otherButtonItems:(RKBlockItem *)otherButtonItems, ...{
	if ((self = [self initWithTitle:title
                           delegate:self
                  cancelButtonTitle:nil
             destructiveButtonTitle:nil
                  otherButtonTitles:nil])) {
		NSMutableArray *buttonsArray = [NSMutableArray array];

		RKBlockItem *eachItem;
		va_list argumentList;

		if (otherButtonItems) {
			[buttonsArray addObject:otherButtonItems];
			va_start(argumentList, otherButtonItems);
			while ((eachItem = va_arg(argumentList, RKBlockItem *))) {
				[buttonsArray addObject:eachItem];
			}
			va_end(argumentList);
		}

		for (RKBlockItem *item in buttonsArray) {
			[self addButtonWithTitle:item.text];
		}

		if (destructiveItem) {
			[buttonsArray addObject:destructiveItem];
			NSInteger destIndex = [self addButtonWithTitle:destructiveItem.text];
			[self setDestructiveButtonIndex:destIndex];
		}

		if (cancelButtonItem) {
			[buttonsArray addObject:cancelButtonItem];
			NSInteger cancelIndex = [self addButtonWithTitle:cancelButtonItem.text];
			[self setCancelButtonIndex:cancelIndex];
		}

		objc_setAssociatedObject(self, (__bridge const void *)RK_BUTTON_ASS_KEY, buttonsArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	return self;
}

- (NSInteger)addButtonItem:(RKBlockItem *)item {
	NSMutableArray *buttonsArray = objc_getAssociatedObject(self, (__bridge const void *)RK_BUTTON_ASS_KEY);

	NSInteger buttonIndex = [self addButtonWithTitle:item.text];
	[buttonsArray addObject:item];

	return buttonIndex;
}

- (void)setDismissAction_:(RKBlockAction)dismissAction {
	objc_setAssociatedObject(self, (__bridge const void *)RK_DISMISSAL_ACTION_KEY, nil, OBJC_ASSOCIATION_COPY);
	objc_setAssociatedObject(self, (__bridge const void *)RK_DISMISSAL_ACTION_KEY, dismissAction, OBJC_ASSOCIATION_COPY);
}

- (RKBlockAction)dismissAction_ {
	return objc_getAssociatedObject(self, (__bridge const void *)RK_DISMISSAL_ACTION_KEY);
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	// Action sheets pass back -1 when they're cleared for some reason other than a button being
	// pressed.
	if (buttonIndex >= 0) {
		NSArray *buttonsArray = objc_getAssociatedObject(self, (__bridge const void *)RK_BUTTON_ASS_KEY);
		RKBlockItem *item = [buttonsArray objectAtIndex:buttonIndex];
		if (item.action)
			item.action();
	}

	if (self.dismissAction_) self.dismissAction_();

	objc_setAssociatedObject(self, (__bridge const void *)RK_BUTTON_ASS_KEY, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	objc_setAssociatedObject(self, (__bridge const void *)RK_DISMISSAL_ACTION_KEY, nil, OBJC_ASSOCIATION_COPY);
}

@end




@implementation UIActionSheet (MyBlocks)

+ (UIActionSheet *)actionSheetWithTitle:(NSString *)title {
	return [[UIActionSheet alloc] initWithTitle:title cancelButtonItem:nil destructiveButtonItem:nil otherButtonItems:nil];
}

- (void)addButtonWithTitle:(NSString *)title action:(UIActionSheetAction)action {
	[self addButtonItem:[RKBlockItem itemWithString:title action:action]];
}

- (void)addCancelButtonWithTitle:(NSString *)title action:(UIActionSheetAction)action {
	[self addButtonItem:[RKBlockItem itemWithString:title action:action]];
	self.cancelButtonIndex = self.numberOfButtons - 1;
}

- (void)addDestructiveButtonWithTitle:(NSString *)title action:(UIActionSheetAction)action {
	[self addButtonItem:[RKBlockItem itemWithString:title action:action]];
	self.destructiveButtonIndex = self.numberOfButtons - 1;
}

- (void)setDismissAction:(UIActionSheetAction)action {
	self.dismissAction_ = action;
}

@end
