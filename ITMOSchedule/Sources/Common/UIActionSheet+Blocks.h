//
//  UIActionSheet+Blocks.h
//  Sample
//
//  Created by Ruslan Kavetsky on 10/11/13.
//  Copyright (c) 2013 Ruslan Kavetsky. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^RKBlockAction)(void);
typedef RKBlockAction UIActionSheetAction;

@interface UIActionSheet (MyBlocks)

+ (UIActionSheet *)actionSheetWithTitle:(NSString *)title;
- (void)addButtonWithTitle:(NSString *)title action:(UIActionSheetAction)action;
- (void)addCancelButtonWithTitle:(NSString *)title action:(UIActionSheetAction)action;
- (void)addDestructiveButtonWithTitle:(NSString *)title action:(UIActionSheetAction)action;

- (void)setDismissAction:(UIActionSheetAction)action;

@end