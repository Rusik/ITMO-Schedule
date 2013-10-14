//
//  OUScheduleViewController.m
//  ITMOSchedule
//
//  Created by Ruslan Kavetsky on 10/14/13.
//  Copyright (c) 2013 Ruslan Kavetsky. All rights reserved.
//

#import "OUScheduleViewController.h"
#import "OUScheduleCoordinator.h"
#import "OUGroupCell.h"
#import "OUTeacherCell.h"
#import "OUAuditoryCell.h"

@interface OUScheduleViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation OUScheduleViewController {
    IBOutlet UITableView *_tableView1;
    IBOutlet UITableView *_tableView2;
    IBOutlet UIScrollView *_scrollView;

    NSArray *_lessons;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [_tableView1 registerNib:[OUGroupCell nibForCell] forCellReuseIdentifier:[OUGroupCell cellIdentifier]];
    [_tableView1 registerNib:[OUTeacherCell nibForCell] forCellReuseIdentifier:[OUTeacherCell cellIdentifier]];
    [_tableView1 registerNib:[OUAuditoryCell nibForCell] forCellReuseIdentifier:[OUAuditoryCell cellIdentifier]];
    [_tableView2 registerNib:[OUGroupCell nibForCell] forCellReuseIdentifier:[OUGroupCell cellIdentifier]];
    [_tableView2 registerNib:[OUTeacherCell nibForCell] forCellReuseIdentifier:[OUTeacherCell cellIdentifier]];
    [_tableView2 registerNib:[OUAuditoryCell nibForCell] forCellReuseIdentifier:[OUAuditoryCell cellIdentifier]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _scrollView.contentSize = CGSizeMake(self.view.$width * 2, self.view.$height);
}

- (void)reloadData {
    _lessons = [[OUScheduleCoordinator sharedInstance] lessons];
    [_tableView1 reloadData];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _lessons.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    id type = [[OUScheduleCoordinator sharedInstance] lessonsType];

    if ([type isKindOfClass:[OUGroup class]]) {
        return [OUGroupCell cellHeight];
    } else if ([type isKindOfClass:[OUTeacher class]]) {
        return [OUTeacherCell cellHeight];
    } else if ([type isKindOfClass:[OUAuditory class]]) {
        return [OUAuditoryCell cellHeight];
    } else {
        return 44.0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    id type = [[OUScheduleCoordinator sharedInstance] lessonsType];
    id lesson = _lessons[indexPath.row];

    UITableViewCell *cell;
    if ([type isKindOfClass:[OUGroup class]]) {
        OUGroupCell *groupCell = [tableView dequeueReusableCellWithIdentifier:[OUGroupCell cellIdentifier]];
        groupCell.lesson = lesson;
        cell = groupCell;
    }
    if ([type isKindOfClass:[OUTeacher class]]) {
        OUTeacherCell *teacherCell = [tableView dequeueReusableCellWithIdentifier:[OUTeacherCell cellIdentifier]];
        cell = teacherCell;
    }
    if ([type isKindOfClass:[OUAuditory class]]) {
        OUAuditoryCell *auditoryCell = [tableView dequeueReusableCellWithIdentifier:[OUAuditoryCell cellIdentifier]];
        return auditoryCell;
    }

    return cell;
}

@end
