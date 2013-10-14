//
//  UITableViewCell+Helpers.h
//  choicer
//
//  Created by Ruslan Kavetsky on 5/21/13.
//  Copyright (c) 2013 oumob. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UITableViewCellHeight <NSObject>

@required
+ (CGFloat)cellHeight;

@end

@interface UITableViewCell (Helpers)

+ (NSString *)cellIdentifier;
+ (UINib *)nibForCell;
+ (id)cellWithCellIdentifier:(NSString *)identifier fromTableView:(UITableView *)tableView;

@end
