//
//  OUTopView.m
//  ITMOSchedule
//
//  Created by Ruslan Kavetsky on 21/11/13.
//  Copyright (c) 2013 Ruslan Kavetsky. All rights reserved.
//

#import "OUTopView.h"
#import "FXBlurView.h"
#import "OUScheduleCoordinator.h"
#import "OUStorage.h"
#import "OUScheduleDownloader.h"
#import "UIView+Helpers.h"

#import <sys/types.h>
#import <sys/sysctl.h>


@interface OUTopView () <UITextFieldDelegate>

@end

@implementation OUTopView {
    IBOutlet UITextField *_textField;
    IBOutlet UIButton *_cancelButton;
    IBOutlet UILabel *_label;
    IBOutlet UIButton *_button;

    IBOutlet FXBlurView *_blurView;
    IBOutlet UIView *_blurViewBackground;

    IBOutlet UIButton *_weekButton;

    IBOutlet UILabel *_notWeekLabel;
    IBOutlet UILabel *_infoLabel;
    IBOutlet UILabel *_weekLabel;
    IBOutlet UILabel *_tutorialLabel;

    OULessonWeekType _currentWeekType;
}

- (BOOL)resignFirstResponder {
    [_textField resignFirstResponder];
    return [super resignFirstResponder];
}

- (void)awakeFromNib {
    _textField.text = nil;

    _blurView.blurRadius = 20.0;
    _blurView.viewToBlur = _containerView;
    _blurView.viewsToHide = @[self];

    _blurView.dynamic = [self supportBlur];

    [self updateInfoLabel];

    _currentWeekType = OULessonWeekTypeOdd;
    [self setActive:NO animated:NO];

    [self subscribeToNotifications];
}

#pragma mark - Notifications

- (void)subscribeToNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateInfoLabel)
                                                 name:UIApplicationSignificantTimeChangeNotification
                                               object:nil];
}

- (void)unsubscribeFromNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)weekNumberUpdate {
    [self updateInfoLabel];
}

- (void)setContainerView:(UIView *)containerView {
    _containerView = containerView;
    _blurView.viewToBlur = containerView;
}

- (void)setData:(id)data {
    _data = data;

    if ([data isKindOfClass:[OUGroup class]]) {
        OUGroup *group = (OUGroup *)data;
        _label.text = [NSString stringWithFormat:@"Группа %@", group.groupName];
    } else if ([data isKindOfClass:[OUTeacher class]]) {
        OUTeacher *teacher = (OUTeacher *)data;
        _label.text = teacher.teacherName;
    } else if ([data isKindOfClass:[OUAuditory class]]) {
        OUAuditory *auditory = (OUAuditory *)data;
        _label.text = [auditory correctAuditoryName];
    }
}

- (NSString *)text {
    return _textField.text;
}

- (void)setState:(OUTopViewState)state {
    [self setState:state animated:YES];
}

- (void)setState:(OUTopViewState)state animated:(BOOL)animated {
    switch (state) {
        case OUTopViewStateEdit:

            [self recursiveEnumerateSubviewsUsingBlock:^(UIView *view, BOOL *stop) {
                view.hidden = NO;
            }];

            if (_state == OUTopViewStateClear) {
                _label.alpha = 0;
                _infoLabel.alpha = 0;
                _weekLabel.alpha = 0;
                _notWeekLabel.alpha = 0;
            }

            [self setActive:YES animated:animated];
            [_textField becomeFirstResponder];
            break;

        case OUTopViewStateShow:

            [self recursiveEnumerateSubviewsUsingBlock:^(UIView *view, BOOL *stop) {
                view.hidden = NO;
            }];
            [self resignFirstResponder];
            [self setActive:NO animated:animated];
            break;

        case OUTopViewStateClear:

            [self recursiveEnumerateSubviewsUsingBlock:^(UIView *view, BOOL *stop) {
                if (view != _blurView && view != _blurViewBackground) {
                    view.hidden = YES;
                }
            }];
            break;
    }
    _state = state;
}

- (void)setWeekProgress:(float)weekProgress {
    CGFloat alpha = 1 - weekProgress;
    _notWeekLabel.alpha = alpha;
    if (alpha == 1) {
        _currentWeekType = OULessonWeekTypeOdd;
    } else if (alpha == 0) {
        _currentWeekType = OULessonWeekTypeEven;
    }
}

- (void)updateInfoLabel {
    NSString *weekDayString;
    NSString *dateString;

    NSDate *today = [NSDate date];

    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"ru_ru"]];

    [dateFormatter setDateFormat:@"eeee"];
    weekDayString = [dateFormatter stringFromDate:today];

    [dateFormatter setDateFormat:@"d MMMM"];
    dateString = [dateFormatter stringFromDate:today];

    if ([[OUStorage sharedInstance] weekNumber]) {
        int todayWeek;
        int lastSaveWeek;
        [dateFormatter setDateFormat:@"w"];
        todayWeek = [dateFormatter stringFromDate:today].intValue;
        lastSaveWeek = [dateFormatter stringFromDate:[[OUStorage sharedInstance] lastWeekNumberUpdate]].intValue;

        int currentWeek = [[OUStorage sharedInstance] weekNumber].intValue + (todayWeek - lastSaveWeek);
        _infoLabel.text = [NSString stringWithFormat:@"%@ | %@ | %d неделя", weekDayString, dateString, currentWeek];

        if (![[OUScheduleCoordinator sharedInstance] currentWeekNumber]) {
            [self updateWeekNumber];
        }
    } else {
        _infoLabel.text = [NSString stringWithFormat:@"%@ | %@", weekDayString, dateString];
        [self updateWeekNumber];
    }
}

#pragma mark - Actions

- (IBAction)textDidChange {
    [_delegate topView:self didChangeText:_textField.text];
}

- (IBAction)cancel {
    [_delegate topViewDidCancel:self];
    [self setState:OUTopViewStateShow];
}

- (IBAction)activeButtonDidTap {
    [self setState:OUTopViewStateEdit];
    [_textField becomeFirstResponder];
    [_delegate topViewDidBecomeActive:self];
}

- (IBAction)weekDidTap {
    [_delegate weekDidTap:self];
}

#pragma mark - Week number

- (void)updateWeekNumber {
    [[OUScheduleDownloader sharedInstance] downloadWeekNumber:^(NSError *error){
        if (!error) {
            [self updateInfoLabel];
        }
    }];
}

#pragma mark - UITextFieldDelegate

- (void)setActive:(BOOL)active animated:(BOOL)animated {

    void(^animationBlock)(void) = ^(){
        _label.alpha = !active;
        _textField.alpha = active;
        _button.alpha = !active;
        _cancelButton.alpha = active;
        _tutorialLabel.alpha = active;
        _weekLabel.alpha = !active;
        _infoLabel.alpha = !active;
        _weekButton.alpha = !active;

        if (active) {
            _notWeekLabel.alpha = 0;
        } else {
            if (_currentWeekType == OULessonWeekTypeEven) {
                _notWeekLabel.alpha = 0;
            } else if (_currentWeekType == OULessonWeekTypeOdd) {
                _notWeekLabel.alpha = 1;
            }
        }
    };

    if (!animated) {
        animationBlock();
    } else {

        CGFloat animationDuration = 0.2;

        [UIView animateWithDuration:animationDuration
                              delay:0
                            options:UIViewAnimationOptionCurveLinear
                         animations:animationBlock
                         completion:nil];
    }

    if (active) {
        _textField.text = nil;
    }
}

- (BOOL)supportBlur {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *model = malloc(size);
    sysctlbyname("hw.machine", model, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:model encoding:NSUTF8StringEncoding];
    free(model);

    //    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    //    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    //    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    //    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    //    if ([platform isEqualToString:@"iPhone3,3"])    return @"Verizon iPhone 4";
    //    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    //    if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone 5 (GSM)";
    //    if ([platform isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    //    if ([platform isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM)";
    //    if ([platform isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (Global)";
    //    if ([platform isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM)";
    //    if ([platform isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (Global)";
    //
    //    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    //    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    //    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    //    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    //    if ([platform isEqualToString:@"iPod5,1"])      return @"iPod Touch 5G";
    //
    //    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
    //    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    //    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    //    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    //    if ([platform isEqualToString:@"iPad2,4"])      return @"iPad 2 (WiFi)";
    //    if ([platform isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    //    if ([platform isEqualToString:@"iPad2,6"])      return @"iPad Mini (GSM)";
    //    if ([platform isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    //    if ([platform isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    //    if ([platform isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    //    if ([platform isEqualToString:@"iPad3,3"])      return @"iPad 3 (GSM)";
    //    if ([platform isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    //    if ([platform isEqualToString:@"iPad3,5"])      return @"iPad 4 (GSM)";
    //    if ([platform isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    //    if ([platform isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
    //    if ([platform isEqualToString:@"iPad4,2"])      return @"iPad Air (GSM)";
    //    if ([platform isEqualToString:@"iPad4,4"])      return @"iPad Mini Retina (WiFi)";
    //    if ([platform isEqualToString:@"iPad4,5"])      return @"iPad Mini Retina (GSM)";
    //
    //    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    //    if ([platform isEqualToString:@"x86_64"])       return @"Simulator";

    NSArray *components = [platform componentsSeparatedByString:@","];
    NSString *aux;
    NSString *aux2;
    if (components.count == 2) {
        aux = components[0];
        aux2 = components[1];
    } else {
        return NO;
    }

    // начиная с пятого
    if ([aux rangeOfString:@"iPhone"].location != NSNotFound) {
        int version = [[aux stringByReplacingOccurrencesOfString:@"iPhone" withString:@""] intValue];
        return version > 4;
    }

    // начиная с длинного (пятого)
    if ([aux rangeOfString:@"iPod"].location != NSNotFound) {
        int version = [[aux stringByReplacingOccurrencesOfString:@"iPod" withString:@""] intValue];
        return version > 4;
    }

    // начиная с четвёртого
    if ([aux rangeOfString:@"iPad"].location != NSNotFound) {
        int version = [[aux stringByReplacingOccurrencesOfString:@"iPad" withString:@""] intValue];
        int number = aux2.intValue;
        if (version == 3 && number > 3) return YES;
        if (version > 3) return YES;
    }

    return NO;
}

@end
