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
    IBOutlet UIScrollView *_scrollView;

    IBOutlet UITableView *_tableView1;
    IBOutlet UITableView *_tableView2;

    NSArray *_weekDays1;
    NSArray *_weekDays2;

    UIRefreshControl *_refreshControl1;
    UITableViewController *_tvc1;

    UIRefreshControl *_refreshControl2;
    UITableViewController *_tvc2;

    IBOutlet UILabel *_noDataLabel1;
    IBOutlet UILabel *_noDataLabel2;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerTableViewsForCells];
    [self subscribeToNotifications];

    _tableView1.tableFooterView = [UIView new];
    _tableView2.tableFooterView = [UIView new];

    [self addRefreshControl];

    [self reloadData];
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
    [self reloadDataResetContentOffset:YES];
}

- (void)reloadDataResetContentOffset:(BOOL)resetContentOffset {

    if (resetContentOffset) {
        [_tableView1 setContentOffset:CGPointMake(0, -_tableView1.contentInset.top) animated:NO];
        [_tableView2 setContentOffset:CGPointMake(0, -_tableView2.contentInset.top) animated:NO];
    }

    _weekDays1 = [[OUScheduleCoordinator sharedInstance] weekDaysForWeekType:OULessonWeekTypeOdd];
    _weekDays2 = [[OUScheduleCoordinator sharedInstance] weekDaysForWeekType:OULessonWeekTypeEven];

    _tableView1.hidden = _weekDays1.count == 0;
    _tableView2.hidden = _weekDays2.count == 0;
    _noDataLabel1.hidden = !_tableView1.hidden;
    _noDataLabel2.hidden = !_tableView2.hidden;
    _tableView1.userInteractionEnabled = !_tableView1.hidden;
    _tableView2.userInteractionEnabled = !_tableView2.hidden;

    [_tableView1 reloadData];
    [_tableView2 reloadData];
}

#pragma mark - Pull to refresh

- (void)addRefreshControl {

    [self removeRefreshControl];

    _refreshControl1 = [UIRefreshControl new];
    [_refreshControl1 addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [_tableView1 insertSubview:_refreshControl1 atIndex:0];

    _tvc1 = [UITableViewController new];
    _tvc1.tableView = _tableView1;
    _tvc1.refreshControl = _refreshControl1;

    _refreshControl2= [UIRefreshControl new];
    [_refreshControl2 addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [_tableView2 insertSubview:_refreshControl2 atIndex:0];

    _tvc2 = [UITableViewController new];
    _tvc2.tableView = _tableView2;
    _tvc2.refreshControl = _refreshControl2;
}

- (void)removeRefreshControl {
    [_refreshControl1 removeFromSuperview];
    _refreshControl1 = nil;
    [_refreshControl2 removeFromSuperview];
    _refreshControl2 = nil;
    _tvc1 = nil;
    _tvc2 = nil;
}

- (void)refresh:(UIRefreshControl *)refreshControl {

    if (refreshControl == _refreshControl1) {
        [_refreshControl2 beginRefreshing];
        [_tableView2 setContentOffset:CGPointMake(0, -_tableView2.contentInset.top) animated:NO];
    } else {
        [_refreshControl1 beginRefreshing];
        [_tableView1 setContentOffset:CGPointMake(0, -_tableView1.contentInset.top) animated:NO];
    }

    [self updateSchedule];
}

- (void)updateSchedule {

    id data = [[OUScheduleCoordinator sharedInstance] lessonsType];

    CompleteBlock block = ^(NSError *error){

        [_refreshControl1 endRefreshing];
        [_refreshControl2 endRefreshing];

        // поднимаем таблицу с анимацией, если после начала обновления человек сдвинул её чуть чуть вверх
        if (_tableView1.contentOffset.y < 0 && _tableView1.contentOffset.y < -_tableView1.contentInset.top) {
            [_tableView1 setContentOffset:CGPointMake(0, -_tableView1.contentInset.top) animated:YES];
        }
        if (_tableView2.contentOffset.y < 0 && _tableView2.contentOffset.y < -_tableView2.contentInset.top) {
            [_tableView2 setContentOffset:CGPointMake(0, -_tableView2.contentInset.top) animated:YES];
        }

        if (!error) {
            [self reloadDataResetContentOffset:NO];
        }
    };

    if ([data isKindOfClass:[OUGroup class]]) {
        [[OUScheduleDownloader sharedInstance] downloadLessonsForGroup:data complete:block];
    } else if ([data isKindOfClass:[OUTeacher class]]) {
        [[OUScheduleDownloader sharedInstance] downloadLessonsForTeacher:data complete:block];
    } else if ([data isKindOfClass:[OUAuditory class]]) {
        [[OUScheduleDownloader sharedInstance] downloadLessonsForAuditory:data complete:block];
    }
}

#pragma mark - Actions

- (void)setContentInset:(UIEdgeInsets)inset {
    [_tableView1 setContentInset:inset];
    [_tableView2 setContentInset:inset];
    [_tableView1 setScrollIndicatorInsets:inset];
    [_tableView2 setScrollIndicatorInsets:inset];

    _noDataLabel1.$top = inset.top;
    _noDataLabel2.$top = inset.top;
}

- (void)scrollToAnotherWeek {
    if (_scrollView.contentOffset.x == 0) {
        [_scrollView setContentOffset:CGPointMake(_scrollView.$width, 0) animated:YES];
    } else if (_scrollView.contentOffset.x == _scrollView.$width) {
        [_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
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

    OULesson *lesson = [self lessonForIndexPath:indexPath inTableView:tableView];
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

    OULesson *lesson = [self lessonForIndexPath:indexPath inTableView:tableView];
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
    OULesson *lesson = [self lessonForIndexPath:indexPath inTableView:tableView];

    UIActionSheet *actionSheet = [UIActionSheet actionSheetWithTitle:@"Посмотреть расписание"];

    id type = [[OUScheduleCoordinator sharedInstance] lessonsType];

    BOOL show = NO;

    void (^beforeLoading)(void) = ^{
        [self showOverlay];
    };
    void (^afterLoading)(void) = ^{
        [self updateScheduleTables];
        [self hideOverlay];
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    };

    if (lesson.teacher && ([type isKindOfClass:[OUGroup class]] || [type isKindOfClass:[OUAuditory class]])) {
        show = YES;
        [actionSheet addButtonWithTitle:[NSString stringWithFormat:@"%@", lesson.teacher.teacherName] action:^{

            beforeLoading();

            [[OUScheduleDownloader sharedInstance] downloadLessonsForTeacher:lesson.teacher complete:^(NSError *error){
                afterLoading();
                if (!error) {
                    [_topView setData:lesson.teacher];
                }
            }];
        }];
    }
    if (lesson.auditory && ([type isKindOfClass:[OUGroup class]] || [type isKindOfClass:[OUTeacher class]])) {
        show = YES;
        [actionSheet addButtonWithTitle:[lesson.auditory.correctAuditoryName stringWithSpaceAfterCommaAndDot] action:^{

            beforeLoading();

            [[OUScheduleDownloader sharedInstance] downloadLessonsForAuditory:lesson.auditory complete:^(NSError *error){
                afterLoading();
                if (!error) {
                    [_topView setData:lesson.auditory];
                }
            }];
        }];
    }
    if (lesson.groups.count && ([type isKindOfClass:[OUAuditory class]] || [type isKindOfClass:[OUTeacher class]])) {
        show = YES;
        if (lesson.groups.count == 1) {
            OUGroup *group = lesson.groups.firstObject;
            [actionSheet addButtonWithTitle:[NSString stringWithFormat:@"Группа %@", group.groupName] action:^{

                beforeLoading();

                [[OUScheduleDownloader sharedInstance] downloadLessonsForGroup:group complete:^(NSError *error){
                    afterLoading();
                    if (!error) {
                        [_topView setData:group];
                    }
                }];
            }];
        } else {
            [actionSheet addButtonWithTitle:@"Группа" action:^{

                UIActionSheet *groupsActionSheet = [UIActionSheet actionSheetWithTitle:@"Выберите группу"];
                for (OUGroup *g in lesson.groups) {
                    [groupsActionSheet addButtonWithTitle:g.groupName action:^{

                        beforeLoading();

                        [[OUScheduleDownloader sharedInstance] downloadLessonsForGroup:g complete:^(NSError *error){
                            afterLoading();
                            if (!error) {
                                [_topView setData:g];
                            }
                        }];
                    }];
                }
                [groupsActionSheet addCancelButtonWithTitle:@"Отмена" action:^{
                    [tableView deselectRowAtIndexPath:indexPath animated:YES];
                }];
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

- (OULesson *)lessonForIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView {
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

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == _scrollView) {
        if (scrollView.contentOffset.x < 0) {
            [_topView setWeekProgress:0];
        } else if (scrollView.contentOffset.x < scrollView.$width) {
            [_topView setWeekProgress:scrollView.contentOffset.x / scrollView.$width];
        } else {
            [_topView setWeekProgress:1];
        }
    }
}

#pragma mark - Loading

- (void)showOverlay {
        [MRProgressOverlayView showOverlayAddedTo:self.view.superview
                                                   title:@"Загрузка"
                                                    mode:MRProgressOverlayViewModeIndeterminate
                                                animated:YES];
}

- (void)hideOverlay {
    [MRProgressOverlayView dismissAllOverlaysForView:self.view.superview animated:YES];
}

@end
