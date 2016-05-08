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

@interface AuthenticationViewController : UIViewController <EchoWebServiceClientDelegate, EchoWebSocketClientDelegate>

@property (weak, nonatomic) IBOutlet UITextField *fieldDeviceName;
@property (weak, nonatomic) IBOutlet UITextField *fieldUsername;
@property (weak, nonatomic) IBOutlet UITextField *fieldPassword;
@property (weak, nonatomic) IBOutlet UILabel *textAlert;
@property (weak, nonatomic) EchoWebSocketClient *webSocketClient;
@property (weak, nonatomic) IBOutlet EchoButtonPrimary *buttonLogin;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinnerLogin;
@property (weak, nonatomic) IBOutlet UIView *viewDarken;

- (IBAction)actionLogin:(id)sender;

@end

