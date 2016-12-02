//
//  EchoTextFieldValidationError.m
//  Echo
//
//  Created by Jonny Power on 30/11/2016.
//  Copyright © 2016 JonnyPower. All rights reserved.
//

#import "EchoTextFieldValidationError.h"
#import "EchoTextFieldForm.h"

@implementation EchoTextFieldValidationError

@synthesize target = _target;
@synthesize reason = _reason;

- (instancetype)initErrorFor:(EchoTextFieldForm*)target reason:(EchoTextFieldValidationErrorType)reason {
    self = [super init];
    
    if(self) {
        _target = target;
        _reason = reason;
    }
    
    return self;
}

- (NSString*)reasonString {
    switch (_reason) {
        case EchoTextFieldValidationErrorTypeMinimumLength:
            return [NSString stringWithFormat:@"'%@' must have at least %d characters", [_target placeholder], [_target minimumLength]];
        case EchoTextFieldValidationErrorTypeMaximumLength:
            return [NSString stringWithFormat:@"'%@' must have less than %d characters", [_target placeholder], [_target maximumLength]];
        case EchoTextFieldValidationErrorTypeEmpty:
            return [NSString stringWithFormat:@"'%@' can't be empty", [_target placeholder]];
    }
}

+ (instancetype)errorFor:(EchoTextFieldForm*)target reason:(EchoTextFieldValidationErrorType)reason {
    return [[EchoTextFieldValidationError alloc] initErrorFor: target
                                                       reason: reason];
}

+ (NSArray<EchoTextFieldValidationError *> *)validateFields:(NSArray<EchoTextFieldForm *> *)fields {
    NSMutableArray<EchoTextFieldValidationError *> *errors = [NSMutableArray array];
    for(EchoTextFieldForm *field in fields) {
        NSArray *fieldErrors = [field validate];
        [errors addObjectsFromArray: fieldErrors];
    }
    return [NSArray arrayWithArray: errors];
}

@end
