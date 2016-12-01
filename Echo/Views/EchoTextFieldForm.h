//
//  EchoTextFieldForm.h
//  Echo
//
//  Created by Jonny Power on 08/05/2016.
//  Copyright © 2016 JonnyPower. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EchoTextFieldValidationError;

@interface EchoTextFieldForm : UITextField

@property BOOL allowedEmpty;
@property int minimumLength;
@property int maximumLength;

- (NSArray<EchoTextFieldValidationError*>*)validate;
- (void)setToErrorState;
- (void)setToNormalState;

@end
