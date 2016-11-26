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

typedef enum : NSUInteger {
    AuthenticationViewControllerViewStateLogin,
    AuthenticationViewControllerViewStateRegister
} AuthenticationViewControllerViewState;

@interface AuthenticationViewController ()
@property (weak, nonatomic) IBOutlet UIView *viewLoginForm;
@property (weak, nonatomic) IBOutlet UIView *viewRegisterForm;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintXRegisterToLoginX;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintXLoginToBaseView;
@property (weak, nonatomic) IBOutlet UIButton *btnNeedAccountOrLogin;

@property AuthenticationViewControllerViewState viewState;

@end

@implementation AuthenticationViewController

@synthesize fieldLoginDeviceName;
@synthesize fieldLoginUsername;
@synthesize fieldLoginPassword;
@synthesize textLoginAlert;
@synthesize viewLoginDarken;
@synthesize viewLoginForm;
@synthesize spinnerLogin;

@synthesize fieldRegisterUsername;
@synthesize fieldRegisterPassword;
@synthesize fieldRegisterConfirmPassword;
@synthesize textRegisterAlert;
@synthesize viewRegisterDarken;
@synthesize viewRegisterForm;
@synthesize spinnerRegister;

@synthesize viewState = _viewState;
@synthesize btnNeedAccountOrLogin;
@synthesize webSocketClient;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [fieldLoginDeviceName setText:[[UIDevice currentDevice] name]];
    
    [self styleFormView:viewLoginForm];
    [self styleFormView:viewRegisterForm];
}

- (void)styleFormView:(UIView*)formView {
    [formView.layer setBorderColor: [UIColor darkGrayColor].CGColor];
    [formView.layer setBorderWidth: 1.5f];
    
    [formView.layer setShadowColor: [UIColor blackColor].CGColor];
    [formView.layer setShadowOpacity: 0.3];
    [formView.layer setShadowRadius: 32.0];
    [formView.layer setShadowOffset: CGSizeZero];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    [fieldLoginPassword setText: @""];
    [self.navigationController setNavigationBarHidden:YES];
    
    [self setViewState:AuthenticationViewControllerViewStateLogin];
}

- (void)setViewState:(AuthenticationViewControllerViewState)viewState {
    _viewState = viewState;
    [self animateViewState: self.view.frame.size.width];
}

- (void)animateViewState:(CGFloat)width {
    
    [btnNeedAccountOrLogin setTitle:self.viewState == AuthenticationViewControllerViewStateLogin ? @"Need an account?" : @"Have an account?" forState:UIControlStateNormal];
    
    [self.constraintXRegisterToLoginX setConstant:width];
    [self.view layoutIfNeeded];
    
    [UIView animateWithDuration:0.2f
                     animations:^{
                         switch (self.viewState) {
                             case AuthenticationViewControllerViewStateLogin:
                                 [self.constraintXLoginToBaseView setConstant: 0.0f];
                                 break;
                             case AuthenticationViewControllerViewStateRegister:
                                 [self.constraintXLoginToBaseView setConstant: 0.0f - width];
                                 break;
                         }
                         [self.view layoutIfNeeded];
                     }];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [self animateViewState: size.width];
}

- (AuthenticationViewControllerViewState)viewState {
    return _viewState;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    
    [webSocketClient addDelegate: self];
    
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    Session *savedSession = [appDelegate savedSession];
    if(savedSession) {
        [self startSpinner:spinnerLogin darkenView:viewLoginDarken];
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

- (IBAction)actionToggleViewState:(id)sender {
    if(self.viewState == AuthenticationViewControllerViewStateLogin) {
        [self setViewState: AuthenticationViewControllerViewStateRegister];
    } else {
        [self setViewState: AuthenticationViewControllerViewStateLogin];
    }
}

- (IBAction)actionLogin:(id)sender {
    EchoWebServiceClient *client = [[EchoWebServiceClient alloc] init];
    client.delegate = self;
    [client loginUsername: fieldLoginUsername.text
                 password: fieldLoginPassword.text
               deviceName: fieldLoginDeviceName.text
              deviceToken: @"testing"];

    [Answers logCustomEventWithName:@"Login Attempted" customAttributes:@{@"Username":fieldLoginUsername.text,
                                                                          @"deviceName":fieldLoginDeviceName.text,
                                                                          @"deviceToken":@"testing"}];
    [self startSpinner:spinnerLogin darkenView:viewLoginDarken];
}

- (IBAction)actionRegister:(id)sender {
    EchoWebServiceClient *client = [[EchoWebServiceClient alloc] init];
    client.delegate = self;
    [client registerUsername: fieldRegisterUsername.text
                    password: fieldRegisterPassword.text
             confirmPassword: fieldRegisterConfirmPassword.text];
    
    [Answers logCustomEventWithName:@"Register Attempted" customAttributes:@{@"Username":fieldRegisterUsername.text}];
    
    [self startSpinner:spinnerRegister darkenView:viewRegisterDarken];
}

- (void)startSpinner:(UIActivityIndicatorView*)spinner darkenView:(UIView*)darkenView {
    [btnNeedAccountOrLogin setEnabled: NO];
    [spinner setAlpha: 1.0];
    [UIView animateWithDuration:2 animations:^{
        [spinner startAnimating];
        [spinner setHidden: NO];
        [darkenView setHidden: NO];
    }];
}

- (void)stopSpinner:(UIActivityIndicatorView*)spinner darkenView:(UIView*)darkenView {
    [btnNeedAccountOrLogin setEnabled: YES];
    [UIView animateWithDuration:2 animations:^{
        [spinner stopAnimating];
        [spinner setHidden: YES];
        [spinner setAlpha: 0];
        [darkenView setHidden: YES];
    }];
}

- (void)requestFailed:(NSError *)error {
    
}

- (void)loginFailed:(NSString *)reason {
    [textLoginAlert setText: reason];
    [textLoginAlert setHidden: NO];
    [self stopSpinner:spinnerLogin darkenView:viewLoginDarken];
}

- (void)loginSuccessful:(Session *)session {
    [textLoginAlert setHidden: YES];
    [textLoginAlert setText: @""];
    [webSocketClient connectWithSession: session];
}

- (void)registerFailed:(NSString *)reason {
    [textRegisterAlert setText: reason];
    [textRegisterAlert setHidden: NO];
    [self stopSpinner:spinnerRegister darkenView:viewRegisterDarken];
}

- (void)registerSuccessful:(NSString *)username {
    [self setViewState: AuthenticationViewControllerViewStateLogin];
    [fieldLoginUsername setText: username];
    [textRegisterAlert setHidden: YES];
    [textRegisterAlert setText: @""];
    [self stopSpinner:spinnerRegister darkenView:viewRegisterDarken];
}

- (void)connectFinished {
    [self performSegueWithIdentifier: @"messaging" sender: self];
    [self stopSpinner:spinnerLogin darkenView:viewLoginDarken];
}

- (void)connectFailed:(NSString*)reason {
    [textLoginAlert setText: reason];
    [textLoginAlert setHidden: NO];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"messaging"]) {
        MessagingViewController *messagingVC = segue.destinationViewController;
        messagingVC.webSocketClient = self.webSocketClient;
        messagingVC.managedObjectContext = ((AppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext;
    }
}

@end
