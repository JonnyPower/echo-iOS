//
//  AuthenticationViewController.h
//  Echo
//
//  Created by Jonny Power on 05/05/2016.
//  Copyright © 2016 JonnyPower. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EchoWebServiceClient.h"
#import "EchoWebSocketClient.h"
#import "EchoButtonPrimary.h"
#import "BaseViewController.h"

@class EchoTextFieldForm;

@interface AuthenticationViewController : BaseViewController <EchoWebServiceClientDelegate, EchoWebSocketClientDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet EchoTextFieldForm *fieldLoginDeviceName;
@property (weak, nonatomic) IBOutlet EchoTextFieldForm *fieldLoginUsername;
@property (weak, nonatomic) IBOutlet EchoTextFieldForm *fieldLoginPassword;
@property (weak, nonatomic) IBOutlet UIView *viewLoginDarken;
@property (weak, nonatomic) IBOutlet UILabel *textLoginAlert;
@property (weak, nonatomic) IBOutlet EchoButtonPrimary *buttonLogin;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinnerLogin;

@property (weak, nonatomic) IBOutlet EchoTextFieldForm *fieldRegisterUsername;
@property (weak, nonatomic) IBOutlet EchoTextFieldForm *fieldRegisterPassword;
@property (weak, nonatomic) IBOutlet EchoTextFieldForm *fieldRegisterConfirmPassword;
@property (weak, nonatomic) IBOutlet UIView *viewRegisterDarken;
@property (weak, nonatomic) IBOutlet UILabel *textRegisterAlert;
@property (weak, nonatomic) IBOutlet UIButton *buttonRegister;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinnerRegister;


@property (weak, nonatomic) EchoWebSocketClient *webSocketClient;

- (IBAction)actionLogin:(id)sender;
- (IBAction)actionRegister:(id)sender;

@end

