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
#import "UIActionSheet+Blocks.h"
#import "OUScheduleDownloader.h"
#import "NSString+Helpers.h"
#import "MRProgressOverlayView.h"

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
    [self subscribeToNotifications];

    _tableView1.tableFooterView = [UIView new];
    _tableView2.tableFooterView = [UIView new];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _scrollView.contentSize = CGSizeMake(_scrollView.$width * 2, self.view.$height);
}

- (void)dealloc {
    [self unsubscribeFromNotifications];
}

#pragma mark - Notifications

- (void)subscribeToNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateFonts)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
}

- (void)unsubscribeFromNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}

- (void)updateFonts {
    [_tableView1 reloadData];
    [_tableView2 reloadData];
}

- (void)registerTableViewsForCells {
    [_tableView1 registerNib:[OUGroupCell nibForCell] forCellReuseIdentifier:[OUGroupCell cellIdentifier]];
    [_tableView1 registerNib:[OUTeacherCell nibForCell] forCellReuseIdentifier:[OUTeacherCell cellIdentifier]];
    [_tableView1 registerNib:[OUAuditoryCell nibForCell] forCellReuseIdentifier:[OUAuditoryCell cellIdentifier]];
    [_tableView2 registerNib:[OUGroupCell nibForCell] forCellReuseIdentifier:[OUGroupCell cellIdentifier]];
    [_tableView2 registerNib:[OUTeacherCell nibForCell] forCellReuseIdentifier:[OUTeacherCell cellIdentifier]];
    [_tableView2 registerNib:[OUAuditoryCell nibForCell] forCellReuseIdentifier:[OUAuditoryCell cellIdentifier]];
}

- (void)reloadData {

    [_tableView1 setContentOffset:CGPointMake(0, -_tableView1.contentInset.top) animated:NO];
    [_tableView2 setContentOffset:CGPointMake(0, -_tableView2.contentInset.top) animated:NO];

    _weekDays1 = [[OUScheduleCoordinator sharedInstance] weekDaysForWeekType:OULessonWeekTypeOdd];
    _weekDays2 = [[OUScheduleCoordinator sharedInstance] weekDaysForWeekType:OULessonWeekTypeEven];

    [_tableView1 reloadData];
    [_tableView2 reloadData];
}

#pragma mark - Actions

- (void)setContentInset:(UIEdgeInsets)inset {
    [_tableView1 setContentInset:inset];
    [_tableView2 setContentInset:inset];
    [_tableView1 setScrollIndicatorInsets:inset];
    [_tableView2 setScrollIndicatorInsets:inset];
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

    OULesson *lesson = [self lessonForIndexPath:indexPath intableView:tableView];
    id type = [[OUScheduleCoordinator sharedInstance] lessonsType];

    CGFloat height = 44.0;

    if ([type isKindOfClass:[OUGroup class]]) {
        height = [OUGroupCell cellHeightForLesson:lesson];
    } else if ([type isKindOfClass:[OUTeacher class]]) {
        height = [OUTeacherCell cellHeightForLesson:lesson];
    } else if ([type isKindOfClass:[OUAuditory class]]) {
        height = [OUAuditoryCell cellHeightForLesson:lesson];
    }

    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    OULesson *lesson = [self lessonForIndexPath:indexPath intableView:tableView];
    OULessonCell *cell;

    id type = [[OUScheduleCoordinator sharedInstance] lessonsType];

    if ([type isKindOfClass:[OUGroup class]]) {
        cell = [tableView dequeueReusableCellWithIdentifier:[OUGroupCell cellIdentifier]];
    }
    if ([type isKindOfClass:[OUTeacher class]]) {
        cell = [tableView dequeueReusableCellWithIdentifier:[OUTeacherCell cellIdentifier]];
    }
    if ([type isKindOfClass:[OUAuditory class]]) {
        cell = [tableView dequeueReusableCellWithIdentifier:[OUAuditoryCell cellIdentifier]];
    }

    cell.lesson = lesson;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath  {
    OULesson *lesson = [self lessonForIndexPath:indexPath intableView:tableView];

    UIActionSheet *actionSheet = [UIActionSheet actionSheetWithTitle:@"Посмотреть расписание"];

    id type = [[OUScheduleCoordinator sharedInstance] lessonsType];

    BOOL show = NO;

    MRProgressOverlayView __block *loadingView;
    void (^beforeLoading)(void) = ^{
         loadingView = [self showOverlay];
    };
    void (^afterLoading)(void) = ^{
        [self updateScheduleTables];
        [loadingView hide:YES];
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    };

    if (lesson.teacher && ([type isKindOfClass:[OUGroup class]] || [type isKindOfClass:[OUAuditory class]])) {
        show = YES;
        [actionSheet addButtonWithTitle:[NSString stringWithFormat:@"%@", lesson.teacher.teacherName] action:^{

            beforeLoading();

            [[OUScheduleDownloader sharedInstance] downloadLessonsForTeacher:lesson.teacher complete:^{
                afterLoading();
                [_topView setData:lesson.teacher];
            }];
        }];
    }
    if (lesson.auditory && ([type isKindOfClass:[OUGroup class]] || [type isKindOfClass:[OUTeacher class]])) {
        show = YES;
        [actionSheet addButtonWithTitle:[lesson.auditory.correctAuditoryName stringWithSpaceAfterCommaAndDot] action:^{

            beforeLoading();

            [[OUScheduleDownloader sharedInstance] downloadLessonsForAuditory:lesson.auditory complete:^{
                afterLoading();
                [_topView setData:lesson.auditory];
            }];
        }];
    }
    if (lesson.groups.count && ([type isKindOfClass:[OUAuditory class]] || [type isKindOfClass:[OUTeacher class]])) {
        show = YES;
        if (lesson.groups.count == 1) {
            OUGroup *group = lesson.groups.firstObject;
            [actionSheet addButtonWithTitle:[NSString stringWithFormat:@"Группа %@", group.groupName] action:^{

                beforeLoading();

                [[OUScheduleDownloader sharedInstance] downloadLessonsForGroup:group complete:^{
                    afterLoading();
                    [_topView setData:group];
                }];
            }];
        } else {
            [actionSheet addButtonWithTitle:@"Группа" action:^{

                UIActionSheet *groupsActionSheet = [UIActionSheet actionSheetWithTitle:@"Выберите группу"];
                for (OUGroup *g in lesson.groups) {
                    [groupsActionSheet addButtonWithTitle:g.groupName action:^{

                        beforeLoading();

                        [[OUScheduleDownloader sharedInstance] downloadLessonsForGroup:g complete:^{
                            afterLoading();
                            [_topView setData:g];
                        }];
                    }];
                }
                [groupsActionSheet addCancelButtonWithTitle:@"Отмена" action:nil];
                [groupsActionSheet setCancelButtonIndex:lesson.groups.count];
                [groupsActionSheet showInView:self.view.superview];
                [self customizeActionSheet:groupsActionSheet];
            }];
        }
    }

    if (show) {
        [actionSheet addCancelButtonWithTitle:@"Отмена" action:^{
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }];
        [actionSheet setCancelButtonIndex:actionSheet.numberOfButtons - 1];
        [actionSheet showInView:self.view.superview];
        [self customizeActionSheet:actionSheet];        
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void)customizeActionSheet:(UIActionSheet *)actionSheet {
    for (UIView *subview in actionSheet.subviews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subview;
            [button setTitleColor:ICON_COLOR forState:UIControlStateNormal];
            [button setTitleColor:ICON_COLOR forState:UIControlStateSelected];
            [button setTitleColor:ICON_COLOR forState:UIControlStateHighlighted];
        }
    }
}

- (OULesson *)lessonForIndexPath:(NSIndexPath *)indexPath intableView:(UITableView *)tableView {
    NSArray *lessons;
    if (tableView == _tableView1) {
        NSString *weekDay = _weekDays1[indexPath.section];
        lessons = [[OUScheduleCoordinator sharedInstance] lessonsForDayString:weekDay weekType:OULessonWeekTypeOdd];
    } else {
        NSString *weekDay = _weekDays2[indexPath.section];
        lessons = [[OUScheduleCoordinator sharedInstance] lessonsForDayString:weekDay weekType:OULessonWeekTypeEven];
    }

    return lessons[indexPath.row];
}

- (void)updateScheduleTables {
    [self reloadData];
    [self hideOverlay];
}

#pragma mark - Loading

- (MRProgressOverlayView *)showOverlay {
    return [MRProgressOverlayView showOverlayAddedTo:self.view.window
                                        title:@"Загрузка"
                                         mode:MRProgressOverlayViewModeIndeterminate
                                     animated:YES];
}

- (void)hideOverlay {
    [MRProgressOverlayView dismissAllOverlaysForView:self.view.window animated:YES];
}

@end
