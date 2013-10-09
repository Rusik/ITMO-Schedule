//
//  OUMainViewController.m
//  ITMOSchedule
//
//  Created by Ruslan Kavetsky on 10/9/13.
//  Copyright (c) 2013 Ruslan Kavetsky. All rights reserved.
//

#import "OUMainViewController.h"
#import "OUScheduleDownloader.h"

@interface OUMainViewController ()

@end

@implementation OUMainViewController

- (IBAction)mainInfo {
    [[OUScheduleDownloader sharedInstance] downloadMainInfo];
}

- (IBAction)group {
    [[OUScheduleDownloader sharedInstance] downloadLessonsForGroup:[OUGroup groupWithName:@"4528"]];
}

- (IBAction)auditory {
    [[OUScheduleDownloader sharedInstance] downloadLessonsForAuditory:[OUAuditory auditoryWithName:@"302"]];
}

- (IBAction)teacher {
    [[OUScheduleDownloader sharedInstance] downloadLessonsForTeacher:[OUTeacher teacherWithId:@"3E12A8828CA9D74485FA259722E10215"]];
}

- (IBAction)week {
    [[OUScheduleDownloader sharedInstance] downloadWeekNumber];
}

@end
