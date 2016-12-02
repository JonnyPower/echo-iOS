//
//  EchoTextFieldForm.m
//  Echo
//
//  Created by Jonny Power on 08/05/2016.
//  Copyright © 2016 JonnyPower. All rights reserved.
//

#import "EchoTextFieldForm.h"
#import "EchoTextFieldValidationError.h"

#import "Helpers.h"

typedef enum : NSUInteger {
    EchoTextFieldFormViewStateNormal,
    EchoTextFieldFormViewStateError
} EchoTextFieldFormViewState;

@interface EchoTextFieldForm ()

@property EchoTextFieldFormViewState viewState;

@end

@implementation EchoTextFieldForm

@synthesize allowedEmpty;
@synthesize minimumLength;
@synthesize maximumLength;

@synthesize viewState = _viewState;

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
    border.borderColor = [self borderColor];
    border.frame = CGRectMake(0, self.frame.size.height - borderWidth, self.frame.size.width, borderWidth);
    border.borderWidth = borderWidth;
    [self.layer addSublayer:border];
    self.layer.masksToBounds = YES;
}

- (CGColorRef)borderColor {
    return (_viewState == EchoTextFieldFormViewStateNormal ? [UIColor darkGrayColor] : [UIColor redColor]).CGColor;
}

- (void)setToErrorState {
    _viewState = EchoTextFieldFormViewStateError;
    [self setNeedsDisplay];
}

- (void)setToNormalState {
    _viewState = EchoTextFieldFormViewStateNormal;
    [self setNeedsDisplay];
}

- (BOOL)becomeFirstResponder {
    BOOL superBecomeFirstResponder = [super becomeFirstResponder];
    _viewState = EchoTextFieldFormViewStateNormal;
    [self setNeedsDisplay];
    return superBecomeFirstResponder;
}

- (NSArray<EchoTextFieldValidationError*>*)validate {
    NSMutableArray<EchoTextFieldValidationError*> *errors = [NSMutableArray array];
    
    NSString *trimmedText = [self trimmedText];
    
    if(!self.allowedEmpty && IS_EMPTY(trimmedText)) {
        [errors addObject:[EchoTextFieldValidationError errorFor: self
                                                          reason: EchoTextFieldValidationErrorTypeEmpty]];
    } else if([trimmedText length] > maximumLength) {
        [errors addObject:[EchoTextFieldValidationError errorFor: self
                                                          reason: EchoTextFieldValidationErrorTypeMaximumLength]];
    } else if([trimmedText length] < minimumLength) {
        [errors addObject:[EchoTextFieldValidationError errorFor: self
                                                          reason: EchoTextFieldValidationErrorTypeMinimumLength]];
    }
    
    return [NSArray arrayWithArray: errors];
}

- (NSString *)trimmedText {
    return [self.text stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
}

@end
