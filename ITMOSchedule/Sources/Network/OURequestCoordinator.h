//
//  OURequestCoordinator.h
//  ITMOSchedule
//
//  Created by Misha on 10/9/13.
//  Copyright (c) 2013 Ruslan Kavetsky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OURequestCoordinator : NSObject

+(OURequestCoordinator *) sharedInstance;

//add parms
- (void)performMainRequest;

@end
