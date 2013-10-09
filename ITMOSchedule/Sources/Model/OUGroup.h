//
//  OUGroup.h
//  ITMOSchedule
//
//  Created by Misha on 10/9/13.
//  Copyright (c) 2013 Ruslan Kavetsky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OUGroup : NSObject

+ (OUGroup *)groupWithName:(NSString *)groupName;

@property (nonatomic, copy) NSString *groupName;

@end
