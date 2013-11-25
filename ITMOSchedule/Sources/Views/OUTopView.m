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
}

- (BOOL)resignFirstResponder {
    [_textField resignFirstResponder];
    return [super resignFirstResponder];
}

- (void)awakeFromNib {
    _textField.text = nil;
    [self setState:OUTopViewStateShow];
}

- (void)setContainerView:(UIView *)containerView {
    _containerView = containerView;
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
    [_textField becomeFirstResponder];
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

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [_delegate topViewDidBecomeActive:self];
    [self setState:OUTopViewStateEdit];
}

- (void)setActive:(BOOL)active {
    _label.hidden = active;
    _textField.hidden = !active;
    _button.hidden = active;
    _cancelButton.hidden = !active;

    if (active) {
        _textField.text = nil;
    }
}

@end
