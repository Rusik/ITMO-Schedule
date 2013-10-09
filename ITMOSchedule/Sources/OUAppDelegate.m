//
//  OUAppDelegate.m
//  ITMOSchedule
//
//  Created by Ruslan Kavetsky on 10/9/13.
//  Copyright (c) 2013 Ruslan Kavetsky. All rights reserved.
//

#import "OUAppDelegate.h"
#import "OURequestCoordinator.h"

@implementation OUAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.window.backgroundColor = [UIColor whiteColor];
    self.delVC = [[OUDelVC alloc ]initWithNibName:@"OUDelVC" bundle:nil];
    self.window.rootViewController = self.delVC;


	[self.window makeKeyAndVisible];
    [[OURequestCoordinator sharedInstance] performMainRequest];
	return YES;
}

@end
