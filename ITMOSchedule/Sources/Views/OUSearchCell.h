//
//  OUSearchCell.h
//  ITMOSchedule
//
//  Created by Ruslan Kavetsky on 10/13/13.
//  Copyright (c) 2013 Ruslan Kavetsky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITableViewCell+Helpers.h"

@interface OUSearchCell : UITableViewCell <UITableViewCellHeight>

@property (nonatomic, retain) id data;

+ (CGFloat)heightForData:(id)data;
+ (void)resetHeightCache;

- (CGFloat)height;

@end
