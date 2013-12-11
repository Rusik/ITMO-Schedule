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
#import "OUAppDelegate.h"
#import "OUStorage.h"

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

    IBOutlet UIView *_tutorialView;
    IBOutlet UILabel *_tutorialDataLabel;
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

            [self updateWeekType];

        } else {
            [self showSearch];
            [_topView setState:OUTopViewStateInit];
        }
    } else {
        [self showSearch];
        [_topView setState:OUTopViewStateClear];
        [self updateMainInfoWithLoadingOverlay:YES block:^{
            [_topView setState:OUTopViewStateInit];
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

#pragma mark - Tutorial

#define TUTORIAL_ANIMATION_DURATION 0.3

- (void)showTutorial {
    [[OUStorage sharedInstance] setIsAlreadyShowTutorial:YES];

    [_topView setBlurEnabled:NO];

    _tutorialView.alpha = 0;
    [self.view addSubview:_tutorialView];
    _tutorialView.frame = self.view.bounds;

    [_tutorialDataLabel removeFromSuperview];
    _tutorialDataLabel = [UILabel new];
    _tutorialDataLabel.frame = [_topView convertRect:_topView.dataLabel.frame toView:_tutorialView];
    _tutorialDataLabel.text = _topView.dataLabel.text;
    _tutorialDataLabel.textColor = [UIColor colorWithRed:0.000 green:0.561 blue:0.910 alpha:1.000];
    _tutorialDataLabel.font = _topView.dataLabel.font;
    [_tutorialView addSubview:_tutorialDataLabel];

    CGFloat animationDelay = 0.3;

    [UIView animateWithDuration:TUTORIAL_ANIMATION_DURATION
                          delay:animationDelay
                        options:0
                     animations:^{

                         _tutorialView.alpha = 1;

                     } completion:nil];

    double delayInSeconds = animationDelay - 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    });
}

- (IBAction)hideTutorial {

    [_topView setBlurEnabled:YES];

    [[OUStorage sharedInstance] setIsAlreadyShowTutorial:YES];

    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];

    [UIView animateWithDuration:TUTORIAL_ANIMATION_DURATION
                          delay:0.1
                        options:0
                     animations:^{

                         _tutorialView.alpha = 0;

                     } completion:^(BOOL finished) {
                         [_tutorialView removeFromSuperview];
                     }];
}

#pragma mark - Other

- (void)updateWeekType {
    if ([[OUScheduleCoordinator sharedInstance] expectedWeekNumber]) {
        int week = [[OUScheduleCoordinator sharedInstance] expectedWeekNumber].intValue;
        OULessonWeekType weekType;
        if (week % 2 == 0) {
            weekType = OULessonWeekTypeEven;
        } else {
            weekType = OULessonWeekTypeOdd;
        }

        [_scheduleVC setWeekType:weekType animated:NO];
    }
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
            if (block) block();
        }
        if (showLoadingOverlay) {
            [self hideLoadingOverlay];
        } else {
            [_refreshControl endRefreshing];

            if (_tableView.contentOffset.y < 0 && _tableView.contentOffset.y < -_tableView.contentInset.top) {
                [_tableView setContentOffset:CGPointMake(0, -_tableView.contentInset.top) animated:YES];
            }
        }
    }];
}

#pragma mark - Notifications

- (void)subscribeToNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateFonts)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(statusBarDidTap)
                                                 name:OUApplicationStatusBarDidTap
                                               object:nil];
}

- (void)unsubscribeFromNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateFonts {
    [OUSearchCell resetHeightCache];
    [_tableView reloadData];
}

- (void)statusBarDidTap {
    [_tableView setContentOffset:CGPointMake(0, -_tableView.contentInset.top) animated:YES];
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

    [_scheduleVC stopScroll];

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

            if (![[OUStorage sharedInstance] isAlreadyShowTutorial]) {
                [self showTutorial];
            }
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
