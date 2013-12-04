//
//  OUTopView.m
//  ITMOSchedule
//
//  Created by Ruslan Kavetsky on 21/11/13.
//  Copyright (c) 2013 Ruslan Kavetsky. All rights reserved.
//

#import "OUTopView.h"
#import "FXBlurView.h"

@interface OUTopView () <UITextFieldDelegate>

@end

@implementation OUTopView {
    IBOutlet UITextField *_textField;
    IBOutlet UIButton *_cancelButton;
    IBOutlet UILabel *_label;
    IBOutlet UIButton *_button;

    IBOutlet FXBlurView *_blurView;

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
    [self setState:OUTopViewStateShow];

    _blurView.blurRadius = 20.0;
    _blurView.viewToBlur = _containerView;
    _blurView.viewsToHide = @[self];

//    turn off for debug
//    _blurView.dynamic = NO;
}

- (void)setContainerView:(UIView *)containerView {
    _containerView = containerView;
    _blurView.viewToBlur = containerView;
}

- (IBAction)textDidChange {
    [_delegate topView:self didChangeText:_textField.text];
}

- (IBAction)cancel {
    [_delegate topViewDidCancel:self];
    [self setState:OUTopViewStateShow];
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
        _label.text = [NSString stringWithFormat:@"Аудитория %@", auditory.auditoryName];
    }
}

- (IBAction)activeButtonDidTap {
    [self setState:OUTopViewStateEdit];
    [_textField becomeFirstResponder];
    [_delegate topViewDidBecomeActive:self];
}

- (NSString *)text {
    return _textField.text;
}

- (void)setState:(OUTopViewState)state {
    _state = state;
    switch (state) {
        case OUTopViewStateEdit:
            [self setActive:YES];
            break;
        case OUTopViewStateShow:
            [self resignFirstResponder];
            [self setActive:NO];
            break;
    }
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

#pragma mark - UITextFieldDelegate

- (void)setActive:(BOOL)active {

    CGFloat animationDuration = 0.2;

    [UIView animateWithDuration:animationDuration
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{

                         _label.alpha = !active;
                         _textField.alpha = active;
                         _button.alpha = !active;
                         _cancelButton.alpha = active;
                         _tutorialLabel.alpha = active;
                         _weekLabel.alpha = !active;
                         _infoLabel.alpha = !active;

                         if (active) {
                             _notWeekLabel.alpha = 0;
                         } else {
                             if (_currentWeekType == OULessonWeekTypeEven) {
                                 _notWeekLabel.alpha = 0;
                             } else if (_currentWeekType == OULessonWeekTypeOdd) {
                                 _notWeekLabel.alpha = 1;
                             }
                         }

                     } completion:^(BOOL finished) {
                         ;
                     }];
    if (active) {
        _textField.text = nil;
    }
}

@end
