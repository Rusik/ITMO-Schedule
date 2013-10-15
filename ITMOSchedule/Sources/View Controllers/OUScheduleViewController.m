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

    NSArray *_weekDays1;
    NSArray *_weekDays2;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerTableViewsForCells];
}

- (void)registerTableViewsForCells {
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

    _weekDays1 = [[OUScheduleCoordinator sharedInstance] weekDaysForWeekType:OULessonWeekTypeOdd];
    _weekDays2 = [[OUScheduleCoordinator sharedInstance] weekDaysForWeekType:OULessonWeekTypeEven];

    [_tableView1 reloadData];
    [_tableView2 reloadData];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView == _tableView1) {
        return _weekDays1[section];
    } else {
        return _weekDays2[section];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == _tableView1) {
        return _weekDays1.count;
    } else {
        return _weekDays2.count;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == _tableView1) {
        NSString *weekDay = _weekDays1[section];
        return [[OUScheduleCoordinator sharedInstance] lessonsForDayString:weekDay weekType:OULessonWeekTypeOdd].count;
    } else {
        NSString *weekDay = _weekDays2[section];
        return [[OUScheduleCoordinator sharedInstance] lessonsForDayString:weekDay weekType:OULessonWeekTypeEven].count;
    }
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
    NSArray *lessons;
    if (tableView == _tableView1) {
        NSString *weekDay = _weekDays1[indexPath.section];
        lessons = [[OUScheduleCoordinator sharedInstance] lessonsForDayString:weekDay weekType:OULessonWeekTypeOdd];
    } else {
        NSString *weekDay = _weekDays2[indexPath.section];
        lessons = [[OUScheduleCoordinator sharedInstance] lessonsForDayString:weekDay weekType:OULessonWeekTypeEven];
    }
    id lesson = lessons[indexPath.row];

    UITableViewCell *cell;
    if ([type isKindOfClass:[OUGroup class]]) {
        OUGroupCell *groupCell = [tableView dequeueReusableCellWithIdentifier:[OUGroupCell cellIdentifier]];
        groupCell.lesson = lesson;
        cell = groupCell;
    }
    if ([type isKindOfClass:[OUTeacher class]]) {
        OUTeacherCell *teacherCell = [tableView dequeueReusableCellWithIdentifier:[OUTeacherCell cellIdentifier]];
        teacherCell.lesson = lesson;
        cell = teacherCell;
    }
    if ([type isKindOfClass:[OUAuditory class]]) {
        OUAuditoryCell *auditoryCell = [tableView dequeueReusableCellWithIdentifier:[OUAuditoryCell cellIdentifier]];
        auditoryCell.lesson = lesson;
        return auditoryCell;
    }

    return cell;
}

@end
