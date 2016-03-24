//
//  OUAppDelegate.m
//  ITMOSchedule
//
//  Created by Ruslan Kavetsky on 10/9/13.
//  Copyright (c) 2013 Ruslan Kavetsky. All rights reserved.
//

#import "OUAppDelegate.h"
#import "OUMainViewController.h"
#import "Flurry.h"

#define TEST_FLIGHT_TOKEN @"cc89d045-c78f-44df-b47b-81820f4d743e"
#define FLURRY_TOKEN @"F84KH8SH2KX28W8PPC4F"

@implementation OUAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [Flurry setCrashReportingEnabled:YES];
    [Flurry startSession:FLURRY_TOKEN];

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.tintColor = ICON_COLOR;
	self.window.backgroundColor = [UIColor whiteColor];
    OUMainViewController *mainViewController = [OUMainViewController new];
    self.window.rootViewController = mainViewController;
	[self.window makeKeyAndVisible];
	return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    CGPoint location = [[[event allTouches] anyObject] locationInView:self.window];
    CGFloat statusBarHeight = 20;
    if (location.y > 0 && location.y < statusBarHeight) {
        [[NSNotificationCenter defaultCenter] postNotificationName:OUApplicationStatusBarDidTap object:nil];
    }
}

@end
