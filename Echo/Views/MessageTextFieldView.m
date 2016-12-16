//
//  MessageInputView.m
//  Echo
//
//  Created by Jonny Power on 06/05/2016.
//  Copyright © 2016 JonnyPower. All rights reserved.
//

#import "MessageTextFieldView.h"
#import "EchoButtonPrimary.h"

#define TEXT_VIEW_HEIGHT 40.0f
#define SEND_BUTTON_WIDTH 50.0f
#define PADDING 3.0f

#define PLACEHOLDER_TEXT @"Type a message..."

@interface MessageTextFieldView ()
@property (strong, nonatomic) UITextView *textView;
@property (strong, nonatomic) EchoButtonPrimary *sendButton;
@end

@implementation MessageTextFieldView

@synthesize textView;
@synthesize sendButton;
@synthesize delegate;

- (id)init {
    self = [super init];
    
    NSLayoutConstraint *constraintViewHeight = [NSLayoutConstraint constraintWithItem: self
                                                                            attribute: NSLayoutAttributeHeight
                                                                            relatedBy: NSLayoutRelationEqual
                                                                               toItem: nil
                                                                            attribute: NSLayoutAttributeNotAnAttribute
                                                                           multiplier: 1.0f
                                                                             constant: TEXT_VIEW_HEIGHT];
    
    if(self) {
        [self setTranslatesAutoresizingMaskIntoConstraints: NO];
        
        self.backgroundColor = [UIColor whiteColor];
        
        textView = [[UITextView alloc] init];
        [textView setTranslatesAutoresizingMaskIntoConstraints: NO];
        
        NSLayoutConstraint *constraintTextViewHeight = [NSLayoutConstraint constraintWithItem: textView
                                                                                    attribute: NSLayoutAttributeHeight
                                                                                    relatedBy: NSLayoutRelationEqual
                                                                                       toItem: self
                                                                                    attribute: NSLayoutAttributeHeight
                                                                                   multiplier: 1.0f
                                                                                     constant: 0.0f - (PADDING*2)];
        
        NSLayoutConstraint *constraintTextViewWidth = [NSLayoutConstraint constraintWithItem: textView
                                                                                   attribute: NSLayoutAttributeWidth
                                                                                   relatedBy: NSLayoutRelationEqual
                                                                                      toItem: self
                                                                                   attribute: NSLayoutAttributeWidth
                                                                                  multiplier: 1.0f
                                                                                    constant: 0.0f - (PADDING*2) - SEND_BUTTON_WIDTH];
        
        NSLayoutConstraint *constraintTextViewY = [NSLayoutConstraint constraintWithItem: textView
                                                                               attribute: NSLayoutAttributeCenterY
                                                                               relatedBy: NSLayoutRelationEqual
                                                                                  toItem: self
                                                                               attribute: NSLayoutAttributeCenterY
                                                                              multiplier: 1.0f
                                                                                constant: 1.0f];
        
        textView.delegate = self;
        textView.text = PLACEHOLDER_TEXT;
        textView.textColor = [UIColor lightGrayColor];
        [textView setFont:[UIFont systemFontOfSize:15.0f]];
        [self addSubview:self.textView];
        
        sendButton = [[EchoButtonPrimary alloc] init];
        [sendButton setTranslatesAutoresizingMaskIntoConstraints: NO];
        
        NSLayoutConstraint *constraintSendButtonHeight = [NSLayoutConstraint constraintWithItem: sendButton
                                                                                      attribute: NSLayoutAttributeHeight
                                                                                      relatedBy: NSLayoutRelationEqual
                                                                                         toItem: self
                                                                                      attribute: NSLayoutAttributeHeight
                                                                                     multiplier: 1.0f
                                                                                       constant: 0.0f - (PADDING * 2)];
        
        NSLayoutConstraint *constraintSendButtonWidth = [NSLayoutConstraint constraintWithItem: sendButton
                                                                                     attribute: NSLayoutAttributeWidth
                                                                                     relatedBy: NSLayoutRelationEqual
                                                                                        toItem: nil
                                                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                                                    multiplier: 1.0f
                                                                                      constant: SEND_BUTTON_WIDTH];
        
        NSLayoutConstraint *constraintSendButtonY = [NSLayoutConstraint constraintWithItem: sendButton
                                                                                 attribute: NSLayoutAttributeCenterY
                                                                                 relatedBy: NSLayoutRelationEqual
                                                                                    toItem: self
                                                                                 attribute: NSLayoutAttributeCenterY
                                                                                multiplier: 1.0f
                                                                                  constant: 0.0f];
        
        NSLayoutConstraint *constraintSendButtonX = [NSLayoutConstraint constraintWithItem: sendButton
                                                                                 attribute: NSLayoutAttributeLeading
                                                                                 relatedBy: NSLayoutRelationEqual
                                                                                    toItem: textView
                                                                                 attribute: NSLayoutAttributeTrailing
                                                                                multiplier: 1.0f
                                                                                  constant: PADDING];
        
        [sendButton setTitle:@"Send" forState:UIControlStateNormal];
        [[sendButton titleLabel] setFont:[UIFont boldSystemFontOfSize:15.0f]];
        [sendButton addTarget:self action:@selector(actionSend:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:sendButton];
        
        [self setAutoresizingMask:UIViewAutoresizingNone];
        [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, TEXT_VIEW_HEIGHT)];
        [self addConstraints:@[constraintViewHeight, constraintTextViewHeight, constraintTextViewWidth, constraintTextViewY, constraintSendButtonHeight, constraintSendButtonWidth, constraintSendButtonY, constraintSendButtonX]];
    }
    
    return self;
}

- (void)textViewDidBeginEditing:(UITextView *)editingTextView {
    if ([editingTextView.text isEqualToString:PLACEHOLDER_TEXT]) {
        editingTextView.text = @"";
        editingTextView.textColor = [UIColor blackColor];
    }
    [editingTextView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)editingTextView {
    if ([editingTextView.text isEqualToString:@""]) {
        editingTextView.text = PLACEHOLDER_TEXT;
        editingTextView.textColor = [UIColor lightGrayColor];
    }
    [editingTextView resignFirstResponder];
}

- (void)actionSend:(id)sender {
    BOOL isPlaceholderText = [textView.text isEqualToString:PLACEHOLDER_TEXT] && textView.textColor == [UIColor lightGrayColor];
    if([sender isEqual:sendButton] && !isPlaceholderText) {
        [delegate sendMessage:textView.text];
        [textView setText:@""];
        [textView resignFirstResponder];
    }
}

@end
