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

@interface OUMainViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, OUTopViewDelegate>

@end

@implementation OUMainViewController {
    IBOutlet UITableView *_tableView;
    IBOutlet UILabel *_loadingLabel;
    IBOutlet UIView *_topViewContainer;

    NSArray *_tableData;
    OUScheduleViewController *_scheduleVC;

    OUTopView *_topView;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [_tableView registerNib:[OUSearchCell nibForCell] forCellReuseIdentifier:[OUSearchCell cellIdentifier]];

    _scheduleVC = [OUScheduleViewController new];
    [self addChildViewController:_scheduleVC];
    [self.view insertSubview:_scheduleVC.view belowSubview:_tableView];
    _scheduleVC.view.frame = self.view.bounds;
    [_scheduleVC setContentInset:UIEdgeInsetsMake(64, 0, 0, 0)];
    [_scheduleVC didMoveToParentViewController:self];

    [self.view addSubview:_topViewContainer];

    _topView = [OUTopView loadFromNib];
    _topView.delegate = self;
    _topView.containerView = self.view;
    [_topViewContainer addSubview:_topView];

    _scheduleVC.topView = _topView;

    [self subscribeToNotifications];

    _loadingLabel.text = @"Загрузка...";
    [[OUScheduleDownloader sharedInstance] downloadMainInfo:^{
        _loadingLabel.text = @"Загружено";
        NSLog(@"MAIN DOWNLOAD");

        _tableData = [[OUScheduleCoordinator sharedInstance] mainInfoDataForString:[_topView text]];
        [_tableView reloadData];
    }];
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
    [_tableView reloadData];
}

#pragma mark - OUTopViewDelegate

- (void)topViewDidBecomeActive:(OUTopView *)topView {
    _tableData = [[OUScheduleCoordinator sharedInstance] mainInfoDataForString:nil];
    [_tableView reloadData];

    [self showSearch];
}

- (void)topView:(OUTopView *)topView didChangeText:(NSString *)text {
    _tableData = [[OUScheduleCoordinator sharedInstance] mainInfoDataForString:text];
    [_tableView reloadData];
}

- (void)topViewDidCancel:(OUTopView *)topView {
    [self showSchedule];
}

#pragma mark - Subviews managing

- (void)showSearch {
    _tableView.hidden = NO;
    _scheduleVC.view.hidden = YES;
}

- (void)showSchedule {
    _tableView.hidden = YES;
    _scheduleVC.view.hidden = NO;
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
    CompleteBlock block = ^{
        [_scheduleVC reloadData];
    };
    if ([data isKindOfClass:[OUGroup class]]) {
        [[OUScheduleDownloader sharedInstance] downloadLessonsForGroup:data complete:block];
    } else if ([data isKindOfClass:[OUTeacher class]]) {
        [[OUScheduleDownloader sharedInstance] downloadLessonsForTeacher:data complete:block];
    } else if ([data isKindOfClass:[OUAuditory class]]) {
        [[OUScheduleDownloader sharedInstance] downloadLessonsForAuditory:data complete:block];
    }

    [self showSchedule];

    [_topView setData:data];
    [_topView setState:OUTopViewStateShow];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [_topView resignFirstResponder];
}

@end
