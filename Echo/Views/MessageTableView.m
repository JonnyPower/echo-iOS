//
//  MessageTableView.m
//  Echo
//
//  Created by Jonny Power on 06/05/2016.
//  Copyright © 2016 JonnyPower. All rights reserved.
//

#import "MessageTableView.h"
#import "MessageInputView.h"

@interface MessageTableView()
@end

@implementation MessageTableView

@synthesize inputAccessoryView = _inputAccessoryView;

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

- (UIView *)inputAccessoryView {
    if(!_inputAccessoryView) {
        _inputAccessoryView = [[MessageInputView alloc] init];
    }
    return _inputAccessoryView;
}

@end
