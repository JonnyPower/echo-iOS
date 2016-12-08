//
//  MessageTableView.m
//  Echo
//
//  Created by Jonny Power on 06/05/2016.
//  Copyright © 2016 JonnyPower. All rights reserved.
//

#import "MessageTableView.h"
#import "MessageTextFieldView.h"

@interface MessageTableView()
@end

@implementation MessageTableView

@synthesize inputAccessoryView = _inputAccessoryView;
@synthesize messageTextFieldView = _messageTextFieldView;
@synthesize messagePresenceView = _messagePresenceView;

CGFloat const INPUT_VIEW_HEIGHT = 70.0f;

- (instancetype)init {
    self = [super init];
    
    if(self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    }
    
    return self;
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)setMessageTextFieldView:(MessageTextFieldView *)messageTextFieldView {
    _messageTextFieldView = messageTextFieldView;
}

- (MessageTextFieldView *)messageTextFieldView {
    if(!_messageTextFieldView) {
        _messageTextFieldView = [[MessageTextFieldView alloc] init];
    }
    return _messageTextFieldView;
}

- (void)setMessagePresenceView:(MessagePresenceView *)messagePresenceView {
    _messagePresenceView = messagePresenceView;
}

- (MessagePresenceView *)messagePresenceView {
    if(!_messagePresenceView) {
        _messagePresenceView = [[MessagePresenceView alloc] init];
    }
    return _messagePresenceView;
}

- (UIView *)inputAccessoryView {
    if(!_inputAccessoryView) {
        _inputAccessoryView = [[UIView alloc] init];
        
        NSLayoutConstraint *constraintViewHeight = [NSLayoutConstraint constraintWithItem: _inputAccessoryView
                                                                                attribute: NSLayoutAttributeHeight
                                                                                relatedBy: NSLayoutRelationEqual
                                                                                   toItem: nil
                                                                                attribute: NSLayoutAttributeNotAnAttribute
                                                                               multiplier: 1.0f
                                                                                 constant: INPUT_VIEW_HEIGHT];
        
        [_inputAccessoryView addConstraint: constraintViewHeight];
        [_inputAccessoryView setFrame:CGRectMake(_inputAccessoryView.frame.origin.x, _inputAccessoryView.frame.origin.y, _inputAccessoryView.frame.size.width, INPUT_VIEW_HEIGHT)];
        
        [_inputAccessoryView addSubview:self.messageTextFieldView];
        
        NSLayoutConstraint *constraintTextFieldBottom = [NSLayoutConstraint constraintWithItem: self.messageTextFieldView
                                                                                     attribute: NSLayoutAttributeBottom
                                                                                     relatedBy: NSLayoutRelationEqual
                                                                                        toItem: _inputAccessoryView
                                                                                     attribute: NSLayoutAttributeBottom
                                                                                    multiplier: 1.0f
                                                                                      constant: 0.0f];
        NSLayoutConstraint *constraintTextFieldWidth = [NSLayoutConstraint constraintWithItem: self.messageTextFieldView
                                                                                    attribute: NSLayoutAttributeWidth
                                                                                    relatedBy: NSLayoutRelationEqual
                                                                                       toItem: _inputAccessoryView
                                                                                    attribute: NSLayoutAttributeWidth
                                                                                   multiplier: 1.0f
                                                                                     constant: 0.0f];
        [_inputAccessoryView addConstraints: @[constraintTextFieldBottom, constraintTextFieldWidth]];
        
        [_inputAccessoryView addSubview:self.messagePresenceView];
        
        NSLayoutConstraint *constraintPresenceTop = [NSLayoutConstraint constraintWithItem: self.messagePresenceView
                                                                                     attribute: NSLayoutAttributeTop
                                                                                     relatedBy: NSLayoutRelationEqual
                                                                                        toItem: _inputAccessoryView
                                                                                     attribute: NSLayoutAttributeTop
                                                                                    multiplier: 1.0f
                                                                                      constant: 0.0f];
        NSLayoutConstraint *constraintPresenceWidth = [NSLayoutConstraint constraintWithItem: self.messagePresenceView
                                                                                    attribute: NSLayoutAttributeWidth
                                                                                    relatedBy: NSLayoutRelationEqual
                                                                                       toItem: _inputAccessoryView
                                                                                    attribute: NSLayoutAttributeWidth
                                                                                   multiplier: 1.0f
                                                                                     constant: 0.0f];
        NSLayoutConstraint *constraintPresenceX = [NSLayoutConstraint constraintWithItem:self.messagePresenceView
                                                                               attribute:NSLayoutAttributeCenterX
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:_inputAccessoryView
                                                                               attribute:NSLayoutAttributeCenterX
                                                                              multiplier:1.0f
                                                                                constant:0.0f];
        
        [_inputAccessoryView addConstraints: @[constraintPresenceX, constraintPresenceTop, constraintPresenceWidth]];
    }
    return _inputAccessoryView;
}

@end
