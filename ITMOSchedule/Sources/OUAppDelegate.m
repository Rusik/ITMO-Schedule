//
//  OUAppDelegate.m
//  ITMOSchedule
//
//  Created by Ruslan Kavetsky on 10/9/13.
//  Copyright (c) 2013 Ruslan Kavetsky. All rights reserved.
//

#import "OUAppDelegate.h"
#import "OUMainViewController.h"

@implementation OUAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.tintColor = ICON_COLOR;
	self.window.backgroundColor = [UIColor whiteColor];
    OUMainViewController *mainViewController = [OUMainViewController new];
    self.window.rootViewController = mainViewController;
	[self.window makeKeyAndVisible];
	return YES;
}

@end
