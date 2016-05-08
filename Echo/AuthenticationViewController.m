//
//  AuthenticationViewController.m
//  Echo
//
//  Created by Jonny Power on 05/05/2016.
//  Copyright © 2016 JonnyPower. All rights reserved.
//

#import "AuthenticationViewController.h"
#import "MessagingViewController.h"
#import "AppDelegate.h"

#import <Crashlytics/Crashlytics.h>

#define RGB(r, g, b) [UIColor colorWithRed:r/225.0f green:g/225.0f blue:b/225.0f alpha:1]


@interface AuthenticationViewController ()
@property (weak, nonatomic) IBOutlet UIView *viewForm;

@end

@implementation AuthenticationViewController

@synthesize fieldDeviceName;
@synthesize fieldUsername;
@synthesize fieldPassword;
@synthesize textAlert;
@synthesize webSocketClient;
@synthesize spinnerLogin;
@synthesize viewDarken;
@synthesize viewForm;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [fieldDeviceName setText:[[UIDevice currentDevice] name]];
    
    // 137, 202, 255
    [viewForm.layer setBorderColor: [UIColor darkGrayColor].CGColor];
    [viewForm.layer setBorderWidth: 1.5f];
    
    [viewForm.layer setShadowColor: [UIColor blackColor].CGColor];
    [viewForm.layer setShadowOpacity: 0.3];
    [viewForm.layer setShadowRadius: 32.0];
    [viewForm.layer setShadowOffset: CGSizeZero];
}

- (void)viewWillAppear:(BOOL)animated {
    [fieldPassword setText: @""];
    [self.navigationController setNavigationBarHidden:YES];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidAppear:(BOOL)animated {
    [webSocketClient addDelegate: self];
    
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    Session *savedSession = [appDelegate savedSession];
    if(savedSession) {
        [self startSpinner];
        [Answers logCustomEventWithName:@"Loaded Saved Session" customAttributes:nil];
        [webSocketClient connectWithSession: savedSession];
    }
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [webSocketClient removeDelegate: self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)actionLogin:(id)sender {
    EchoWebServiceClient *client = [[EchoWebServiceClient alloc] init];
    client.delegate = self;
    [client loginUsername:fieldUsername.text password:fieldPassword.text deviceName:fieldDeviceName.text deviceToken:@"testing"];

    [Answers logCustomEventWithName:@"Login Attempted" customAttributes:@{@"Username":fieldUsername.text,
                                                                          @"deviceName":fieldDeviceName.text,
                                                                          @"deviceToken":@"testing"}];
    [self startSpinner];
}

- (void)startSpinner {
    [spinnerLogin setAlpha: 1.0];
    [UIView animateWithDuration:2 animations:^{
        [spinnerLogin startAnimating];
        [spinnerLogin setHidden: NO];
        [viewDarken setHidden: NO];
    }];
}

- (void)stopSpinner {
    [UIView animateWithDuration:2 animations:^{
        [spinnerLogin stopAnimating];
        [spinnerLogin setHidden: YES];
        [spinnerLogin setAlpha: 0];
        [viewDarken setHidden: YES];
    }];
}

- (void)requestFailed:(NSError *)error {
    
}

- (void)loginFailed:(NSString *)reason {
    [textAlert setText: reason];
    [textAlert setHidden: NO];
    [self stopSpinner];
}

- (void)loginSuccessful:(Session *)session {
    [textAlert setHidden: YES];
    [webSocketClient connectWithSession: session];
}

- (void)connectFinished {
    [self performSegueWithIdentifier: @"messaging" sender: self];
    [self stopSpinner];
}

- (void)connectFailed:(NSString*)reason {
    [textAlert setText: reason];
    [textAlert setHidden: NO];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"messaging"]) {
        MessagingViewController *messagingVC = segue.destinationViewController;
        messagingVC.webSocketClient = self.webSocketClient;
        messagingVC.managedObjectContext = ((AppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext;
    }
}

@end
