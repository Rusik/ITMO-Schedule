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

@interface OUMainViewController () <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>

@end

@implementation OUMainViewController {
    IBOutlet UITextField *_textField;
    IBOutlet UITableView *_tableView;
    IBOutlet UILabel *_loadingLabel;

    NSArray *_tableData;
    OUScheduleViewController *_scheduleVC;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [_tableView registerNib:[OUSearchCell nibForCell] forCellReuseIdentifier:[OUSearchCell cellIdentifier]];

    _loadingLabel.text = @"Загрузка...";
    [[OUScheduleDownloader sharedInstance] downloadMainInfo:^{
        _loadingLabel.text = @"Загружено";
        NSLog(@"MAIN DOWNLOAD");
    }];

    _scheduleVC = [OUScheduleViewController new];
    [self addChildViewController:_scheduleVC];
    [self.view insertSubview:_scheduleVC.view belowSubview:_tableView];
    _scheduleVC.view.$top = 50;
    _scheduleVC.view.$height -= 50;
    [_scheduleVC didMoveToParentViewController:self];

    [self subscribeToNotifications];
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

#pragma mark - Actions

- (IBAction)cancelDidPress {
    [_textField resignFirstResponder];
    _tableView.hidden = YES;
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    _tableView.hidden = NO;
}

- (IBAction)textDidChange {
    _tableData = [[OUScheduleCoordinator sharedInstance] mainInfoDataForString:_textField.text];
    [_tableView reloadData];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
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

    NSLog(@"SELECT");

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
    
    _tableView.hidden = YES;
    [_textField resignFirstResponder];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [_textField resignFirstResponder];
}

@end
