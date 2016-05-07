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

@interface AuthenticationViewController ()

@end

@implementation AuthenticationViewController

@synthesize fieldDeviceName;
@synthesize fieldUsername;
@synthesize fieldPassword;
@synthesize textAlert;
@synthesize webSocketClient;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [webSocketClient addDelegate: self];
    
    [fieldDeviceName setText:[[UIDevice currentDevice] name]];
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    Session *savedSession = [appDelegate savedSession];
    if(savedSession) {
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

}

- (void)requestFailed:(NSError *)error {
    
}

- (void)loginFailed:(NSString *)reason {
    [textAlert setText: reason];
    [textAlert setHidden: NO];
}

- (void)loginSuccessful:(Session *)session {
    [textAlert setHidden: YES];
    [webSocketClient connectWithSession: session];
}

- (void)socketDidOpen {
    [self performSegueWithIdentifier: @"messaging" sender: self];
}

- (void)socketFailedSetup {
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"messaging"]) {
        MessagingViewController *messagingVC = segue.destinationViewController;
        messagingVC.webSocketClient = self.webSocketClient;
        messagingVC.managedObjectContext = ((AppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext;
    }
}

@end
