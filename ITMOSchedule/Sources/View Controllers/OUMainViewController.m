//
//  OUMainViewController.m
//  ITMOSchedule
//
//  Created by Ruslan Kavetsky on 10/9/13.
//  Copyright (c) 2013 Ruslan Kavetsky. All rights reserved.
//

#import "OUMainViewController.h"
#import "OUScheduleDownloader.h"
#import "OUScheduleCoordinator.h"
#import "UITableViewCell+Helpers.h"
#import "OUSearchCell.h"
#import "OUScheduleViewController.h"
#import "OUTopView.h"
#import "MRProgressOverlayView.h"

@interface OUMainViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, OUTopViewDelegate>

@end

@implementation OUMainViewController {
    IBOutlet UITableView *_tableView;
    IBOutlet UIView *_topViewContainer;

    NSArray *_tableData;
    OUScheduleViewController *_scheduleVC;

    OUTopView *_topView;

    UIRefreshControl *_refreshControl;
    UITableViewController *_tvc;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self updateViews];
    [self subscribeToNotifications];

    [self addRefreshControl];

    if ([[OUScheduleCoordinator sharedInstance] mainInfo]) {
        if ([[OUScheduleCoordinator sharedInstance] lessons] && [[OUScheduleCoordinator sharedInstance] lessonsType]) {
            [self showSchedule];
            [_scheduleVC reloadData];
            [_topView setData:[[OUScheduleCoordinator sharedInstance] lessonsType]];

            //высчитываем высоту ячеек заранее, чтобы таблица открывалась без задержки
            _tableData = [[OUScheduleCoordinator sharedInstance] mainInfoDataForString:nil];
            [_tableView reloadData];

        } else {
            [self showSearch];
            [_topView setState:OUTopViewStateEdit];
        }
    } else {
        [self showSearch];
        [_topView setState:OUTopViewStateClear];
        [self updateMainInfoWithLoadingOverlay:YES block:^{
            [_topView setState:OUTopViewStateEdit];
        }];
    }
}

- (void)dealloc {
    [self unsubscribeFromNotifications];
}

- (void)updateViews {
    [_tableView registerNib:[OUSearchCell nibForCell] forCellReuseIdentifier:[OUSearchCell cellIdentifier]];
    _tableView.tableFooterView = [UIView new];
    _tableView.contentInset = UIEdgeInsetsMake(_topViewContainer.$height, 0, 0, 0);
    _tableView.scrollIndicatorInsets = _tableView.contentInset;

    _scheduleVC = [OUScheduleViewController new];
    [self addChildViewController:_scheduleVC];
    [self.view insertSubview:_scheduleVC.view belowSubview:_tableView];
    _scheduleVC.view.frame = self.view.bounds;
    [_scheduleVC setContentInset:UIEdgeInsetsMake(_topViewContainer.$height, 0, 0, 0)];
    [_scheduleVC didMoveToParentViewController:self];

    [self.view addSubview:_topViewContainer];

    _topView = [OUTopView loadFromNib];
    _topView.delegate = self;
    _topView.containerView = self.view;
    [_topViewContainer addSubview:_topView];

    _scheduleVC.topView = _topView;
}

#pragma mark - Downloading

- (void)updateMainInfoWithLoadingOverlay:(BOOL)showLoadingOverlay block:(void(^)(void))block {

    if (showLoadingOverlay) {
        [self showLoadingOverlay];
    }
    [[OUScheduleDownloader sharedInstance] downloadMainInfo:^(NSError *error){

        if (!error) {
            _tableData = [[OUScheduleCoordinator sharedInstance] mainInfoDataForString:[_topView text]];
            [_tableView reloadData];
        }
        if (showLoadingOverlay) {
            [self hideLoadingOverlay];
        } else {
            [_refreshControl endRefreshing];

            if (_tableView.contentOffset.y < 0 && _tableView.contentOffset.y < -_tableView.contentInset.top) {
                [_tableView setContentOffset:CGPointMake(0, -_tableView.contentInset.top) animated:YES];
            }
        }
        if (block) {
            block();
        }
    }];
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
    [OUSearchCell resetHeightCache];
    [_tableView reloadData];
}

#pragma mark - OUTopViewDelegate

- (void)topViewDidBecomeActive:(OUTopView *)topView {
    [self showSearch];
}

- (void)topView:(OUTopView *)topView didChangeText:(NSString *)text {
    _tableData = [[OUScheduleCoordinator sharedInstance] mainInfoDataForString:text];
    [_tableView reloadData];
    [_tableView setContentOffset:CGPointMake(0, -_tableView.contentInset.top) animated:NO];
}

- (void)topViewDidCancel:(OUTopView *)topView {
    [self showSchedule];
}

- (void)weekDidTap:(OUTopView *)topView {
    [_scheduleVC scrollToAnotherWeek];
}

#pragma mark - Subviews managing

- (void)showSearch {
    _tableView.hidden = NO;
    _scheduleVC.view.hidden = YES;

    _tableData = [[OUScheduleCoordinator sharedInstance] mainInfoDataForString:nil];
    [_tableView reloadData];
    [_tableView setContentOffset:CGPointMake(0, -_tableView.contentInset.top) animated:NO];
}

- (void)showSchedule {
    _tableView.hidden = YES;
    _scheduleVC.view.hidden = NO;
}

#pragma mark - Pull to refresh

- (void)addRefreshControl {

    [self removeRefreshControl];

    _refreshControl = [UIRefreshControl new];
    [_refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [_tableView insertSubview:_refreshControl atIndex:0];

    _tvc = [UITableViewController new];
    _tvc.tableView = _tableView;
    _tvc.refreshControl = _refreshControl;
}

- (void)removeRefreshControl {
    [_refreshControl removeFromSuperview];
    _refreshControl = nil;
}

- (void)refresh {
    [self updateMainInfoWithLoadingOverlay:NO block:nil];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [OUSearchCell heightForData:_tableData[indexPath.row]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _tableData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OUSearchCell *cell = (OUSearchCell *)[tableView dequeueReusableCellWithIdentifier:[OUSearchCell cellIdentifier]];
    cell.data = _tableData[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    id data = _tableData[indexPath.row];
    CompleteBlock block = ^(NSError *error){
        [self hideLoadingOverlay];
        if (!error) {
            [_topView setData:data];
            [_scheduleVC reloadData];
        }
    };
    if ([data isKindOfClass:[OUGroup class]]) {
        [[OUScheduleDownloader sharedInstance] downloadLessonsForGroup:data complete:block];
    } else if ([data isKindOfClass:[OUTeacher class]]) {
        [[OUScheduleDownloader sharedInstance] downloadLessonsForTeacher:data complete:block];
    } else if ([data isKindOfClass:[OUAuditory class]]) {
        [[OUScheduleDownloader sharedInstance] downloadLessonsForAuditory:data complete:block];
    }

    [self showSchedule];
    [self showLoadingOverlay];

    [_topView setState:OUTopViewStateShow];
}

#pragma mark - Loading

- (void)showLoadingOverlay {
    [MRProgressOverlayView showOverlayAddedTo:self.view
                                        title:@"Загрузка"
                                         mode:MRProgressOverlayViewModeIndeterminate
                                     animated:YES];
}

- (void)hideLoadingOverlay {
    [MRProgressOverlayView dismissAllOverlaysForView:self.view animated:YES];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [_topView resignFirstResponder];
}

@end
