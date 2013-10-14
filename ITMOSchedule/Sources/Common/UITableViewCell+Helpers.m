//
//  UITableViewCell+Helpers.m
//  choicer
//
//  Created by Ruslan Kavetsky on 5/21/13.
//  Copyright (c) 2013 oumob. All rights reserved.
//

#import "UITableViewCell+Helpers.h"

@implementation UITableViewCell (Helpers)

+ (NSString *)cellIdentifier {
    return NSStringFromClass(self);
}

+ (UINib *)nibForCell {
    return [UINib nibWithNibName:[self cellIdentifier] bundle:nil];
}

+ (id)cellWithCellIdentifier:(NSString *)identifier fromTableView:(UITableView *)tableView {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!identifier) {
        identifier = [self cellIdentifier];
    }
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    return cell;
}

@end
