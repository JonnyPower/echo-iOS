//
//  EchoTextFieldValidationError.h
//  Echo
//
//  Created by Jonny Power on 30/11/2016.
//  Copyright © 2016 JonnyPower. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "EchoTextFieldForm.h"

typedef enum : NSUInteger {
    EchoTextFieldValidationErrorTypeMinimumLength,
    EchoTextFieldValidationErrorTypeMaximumLength,
    EchoTextFieldValidationErrorTypeEmpty
} EchoTextFieldValidationErrorType;

@interface EchoTextFieldValidationError : NSObject

@property EchoTextFieldForm *target;
@property EchoTextFieldValidationErrorType reason;

- (instancetype)initErrorFor:(EchoTextFieldForm*)textField reason:(EchoTextFieldValidationErrorType)reason;
- (NSString*)reasonString;

+ (instancetype)errorFor:(EchoTextFieldForm*)textField reason:(EchoTextFieldValidationErrorType)reason;
+ (NSArray<EchoTextFieldValidationError*>*)validateFields:(NSArray<EchoTextFieldForm*>*)fields;

@end
