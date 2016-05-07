//
//  MessageInputView.m
//  Echo
//
//  Created by Jonny Power on 06/05/2016.
//  Copyright © 2016 JonnyPower. All rights reserved.
//

#import "MessageInputView.h"

#define INPUT_VIEW_HEIGHT 40.0f
#define SEND_BUTTON_WIDTH 50.0f
#define PADDING 3.0f

#define PLACEHOLDER_TEXT @"Type a message..."

@interface MessageInputView ()
@property (strong, nonatomic) UITextView *textView;
@property (strong, nonatomic) UIButton *sendButton;
@end

@implementation MessageInputView

@synthesize textView;
@synthesize sendButton;
@synthesize delegate;

- (id)init {
    CGRect screen = [[UIScreen mainScreen] bounds];
    CGRect frame = CGRectMake(0,0, CGRectGetWidth(screen), INPUT_VIEW_HEIGHT);
    self = [self initWithFrame:frame];
    
    if(self) {
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if(self) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        textView = [[UITextView alloc]initWithFrame:CGRectMake(PADDING, PADDING, frame.size.width - (PADDING*2) - SEND_BUTTON_WIDTH, INPUT_VIEW_HEIGHT - (PADDING*2))];
        textView.delegate = self;
        textView.text = PLACEHOLDER_TEXT;
        textView.textColor = [UIColor lightGrayColor];
        [textView setFont:[UIFont systemFontOfSize:15.0f]];
        [self addSubview:self.textView];
        
        sendButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [sendButton setFrame:CGRectMake(self.textView.frame.origin.x + self.textView.frame.size.width + PADDING, PADDING, SEND_BUTTON_WIDTH, INPUT_VIEW_HEIGHT - (PADDING*2))];
        [sendButton setTitle:@"Send" forState:UIControlStateNormal];
        [[sendButton titleLabel] setFont:[UIFont boldSystemFontOfSize:15.0f]];
        [sendButton addTarget:self action:@selector(actionSend:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:sendButton];
        
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
    if([sender isEqual:sendButton]) {
        [delegate sendMessage:textView.text];
        [textView setText:@""];
        [textView resignFirstResponder];
    }
}

@end
