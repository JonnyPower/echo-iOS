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

@interface AuthenticationViewController : BaseViewController <EchoWebServiceClientDelegate, EchoWebSocketClientDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *fieldLoginDeviceName;
@property (weak, nonatomic) IBOutlet UITextField *fieldLoginUsername;
@property (weak, nonatomic) IBOutlet UITextField *fieldLoginPassword;
@property (weak, nonatomic) IBOutlet UIView *viewLoginDarken;
@property (weak, nonatomic) IBOutlet UILabel *textLoginAlert;
@property (weak, nonatomic) IBOutlet EchoButtonPrimary *buttonLogin;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinnerLogin;

@property (weak, nonatomic) IBOutlet UITextField *fieldRegisterUsername;
@property (weak, nonatomic) IBOutlet UITextField *fieldRegisterPassword;
@property (weak, nonatomic) IBOutlet UITextField *fieldRegisterConfirmPassword;
@property (weak, nonatomic) IBOutlet UIView *viewRegisterDarken;
@property (weak, nonatomic) IBOutlet UILabel *textRegisterAlert;
@property (weak, nonatomic) IBOutlet UIButton *buttonRegister;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinnerRegister;


@property (weak, nonatomic) EchoWebSocketClient *webSocketClient;

- (IBAction)actionLogin:(id)sender;
- (IBAction)actionRegister:(id)sender;

@end

