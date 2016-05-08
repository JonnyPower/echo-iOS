//
//  EchoTextFieldForm.m
//  Echo
//
//  Created by Jonny Power on 08/05/2016.
//  Copyright © 2016 JonnyPower. All rights reserved.
//

#import "EchoTextFieldForm.h"

@implementation EchoTextFieldForm

- (id)commonInit:(EchoTextFieldForm*)textField {
    if(textField) {
        [textField setBackgroundColor:[UIColor clearColor]];
        [textField setBorderStyle:UITextBorderStyleNone];
    }
    return textField;
}

- (id)init {
    self = [super init];
    [self commonInit:self];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    [self commonInit:self];
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CALayer *border = [CALayer layer];
    CGFloat borderWidth = 1;
    border.borderColor = [UIColor darkGrayColor].CGColor;
    border.frame = CGRectMake(0, self.frame.size.height - borderWidth, self.frame.size.width, borderWidth);
    border.borderWidth = borderWidth;
    [self.layer addSublayer:border];
    self.layer.masksToBounds = YES;
}

@end
