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
#import "Helpers.h"
#import "EchoTextFieldForm.h"
#import "EchoTextFieldValidationError.h"

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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintYLoginToBaseView;
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

#pragma mark -
#pragma mark AuthenticationViewController

- (void)styleFormView:(UIView*)formView {
    [formView.layer setBorderColor: [UIColor darkGrayColor].CGColor];
    [formView.layer setBorderWidth: 1.5f];
    
    [formView.layer setShadowColor: [UIColor blackColor].CGColor];
    [formView.layer setShadowOpacity: 0.3];
    [formView.layer setShadowRadius: 32.0];
    [formView.layer setShadowOffset: CGSizeZero];
}

- (void)setViewState:(AuthenticationViewControllerViewState)viewState {
    _viewState = viewState;
    [self animateViewState: self.view.frame.size.width];
}

- (AuthenticationViewControllerViewState)viewState {
    return _viewState;
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
                     } completion:^(BOOL finished) {
                     }];
}

- (UIActivityIndicatorView*)currentSpinner {
    return self.viewState == AuthenticationViewControllerViewStateLogin ? spinnerLogin : spinnerRegister;
}

- (UILabel*)currentAlertText {
    return self.viewState == AuthenticationViewControllerViewStateLogin ? textLoginAlert : textRegisterAlert;
}

- (UIView*)currentDarkenView {
    return self.viewState == AuthenticationViewControllerViewStateLogin ? viewLoginDarken : viewRegisterDarken;
}

- (void)startCurrentSpinner {
    [self startSpinner:[self currentSpinner] darkenView:[self currentDarkenView]];
}

- (void)stopCurrentSpinner {
    [self stopSpinner:[self currentSpinner] darkenView:[self currentDarkenView]];
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

- (void)showErrors:(NSArray<EchoTextFieldValidationError*>*)errors {
    NSString *errorString = [NSString string];
    for(EchoTextFieldValidationError *error in errors) {
        [error.target setToErrorState];
        if(!IS_EMPTY(errorString)) {
            errorString = [NSString stringWithFormat:@"%@\n", errorString];
        }
        errorString = [NSString stringWithFormat:@"%@%@", errorString, [error reasonString]];
    }
    [[self currentAlertText] setText: errorString];
    [[self currentAlertText] setHidden: NO];
}

- (void)clearErrors {
    for(EchoTextFieldForm *field in @[fieldLoginDeviceName, fieldLoginUsername, fieldLoginPassword, fieldRegisterUsername, fieldRegisterPassword, fieldRegisterConfirmPassword]) {
        [field setToNormalState];
    }
    [textLoginAlert setText: @""];
    [textLoginAlert setHidden: YES];
    [textRegisterAlert setText: @""];
    [textRegisterAlert setHidden: YES];
}

#pragma mark -
#pragma mark Keyboard Notification Observers

- (void)keyboardWillShow:(NSNotification *)sender {
    NSTimeInterval duration = [[[sender userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    NSUInteger curve = [[[sender userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];
    CGRect keyboardFrame = [[[sender userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [UIView animateWithDuration:duration
                          delay: 0.0
                        options: UIViewAnimationOptionBeginFromCurrentState
                     animations: ^{
        [UIView setAnimationCurve:curve];
        self.constraintYLoginToBaseView.constant = 0.0f - (keyboardFrame.size.height / 2);
    } completion:^(BOOL finished) {
    }];
}

- (void)keyboardWillHide:(NSNotification *)sender {
    NSTimeInterval duration = [[[sender userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    NSUInteger curve = [[[sender userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];
    [UIView animateWithDuration: duration
                          delay: 0.0
                        options: UIViewAnimationOptionBeginFromCurrentState
                     animations: ^{
        [UIView setAnimationCurve:curve];
        self.constraintYLoginToBaseView.constant = 0.0f;
    } completion:^(BOOL finished) {
    }];
}

#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [fieldLoginDeviceName setText:[[UIDevice currentDevice] name]];
    
    [self styleFormView:viewLoginForm];
    [self styleFormView:viewRegisterForm];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    [fieldLoginPassword setText: @""];
    [self.navigationController setNavigationBarHidden:YES];
    
    [self setViewState:AuthenticationViewControllerViewStateLogin];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [self animateViewState: size.width];
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"messaging"]) {
        MessagingViewController *messagingVC = segue.destinationViewController;
        messagingVC.webSocketClient = self.webSocketClient;
        messagingVC.managedObjectContext = ((AppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext;
    }
}

#pragma mark -
#pragma mark IBAction

- (IBAction)actionToggleViewState:(id)sender {
    if(self.viewState == AuthenticationViewControllerViewStateLogin) {
        [self setViewState: AuthenticationViewControllerViewStateRegister];
    } else {
        [self setViewState: AuthenticationViewControllerViewStateLogin];
    }
    [self clearErrors];
}

- (IBAction)actionLogin:(id)sender {
    
    NSArray<EchoTextFieldValidationError *> *errors = [EchoTextFieldValidationError validateFields:@[fieldLoginDeviceName, fieldLoginUsername, fieldLoginPassword]];
    
    if(IS_EMPTY(errors)) {
        EchoWebServiceClient *client = [[EchoWebServiceClient alloc] init];
        client.delegate = self;
        [client loginUsername: fieldLoginUsername.text
                     password: fieldLoginPassword.text
                   deviceName: fieldLoginDeviceName.text
                  deviceToken: @"testing"];
        
        [Answers logCustomEventWithName:@"Login Attempted" customAttributes:@{@"Username":fieldLoginUsername.text,
                                                                              @"deviceName":fieldLoginDeviceName.text,
                                                                              @"deviceToken":@"testing"}];
        [self startCurrentSpinner];
    } else {
        [self showErrors: errors];
    }
}

- (IBAction)actionRegister:(id)sender {
    
    NSArray<EchoTextFieldValidationError *> *errors = [EchoTextFieldValidationError validateFields:@[fieldRegisterUsername, fieldRegisterPassword, fieldRegisterConfirmPassword]];
    
    if(IS_EMPTY(errors)) {
        EchoWebServiceClient *client = [[EchoWebServiceClient alloc] init];
        client.delegate = self;
        [client registerUsername: fieldRegisterUsername.text
                        password: fieldRegisterPassword.text
                 confirmPassword: fieldRegisterConfirmPassword.text];
        
        [Answers logCustomEventWithName:@"Register Attempted" customAttributes:@{@"Username":fieldRegisterUsername.text}];
        
        [self startCurrentSpinner];
    } else {
        [self showErrors: errors];
    }
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    if([textField isEqual:fieldLoginDeviceName]) {
        [fieldLoginUsername becomeFirstResponder];
    }
    if([textField isEqual:fieldLoginUsername]) {
        [fieldLoginPassword becomeFirstResponder];
    }
    if([textField isEqual:fieldLoginPassword] && !IS_EMPTY(fieldLoginDeviceName.text) && !IS_EMPTY(fieldLoginUsername.text)) {
        [self.buttonLogin sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
    
    if([textField isEqual:fieldRegisterUsername]) {
        [fieldRegisterPassword becomeFirstResponder];
    }
    if([textField isEqual:fieldRegisterPassword]) {
        [fieldRegisterConfirmPassword becomeFirstResponder];
    }
    if([textField isEqual:fieldRegisterConfirmPassword] && !IS_EMPTY(fieldRegisterPassword.text) && !IS_EMPTY(fieldRegisterUsername.text)) {
        [self.buttonRegister sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {

}

#pragma mark -
#pragma mark EchoWebServiceClientDelegate

- (void)requestFailed:(NSError *)error {
    [self stopCurrentSpinner];
    [[self currentAlertText] setText:[error localizedDescription]];
    [[self currentAlertText] setHidden: NO];
}

- (void)loginFailed:(NSString *)reason {
    [textLoginAlert setText: reason];
    [textLoginAlert setHidden: NO];
    [self stopCurrentSpinner];
}

- (void)loginSuccessful:(Session *)session {
    [textLoginAlert setHidden: YES];
    [textLoginAlert setText: @""];
    [webSocketClient connectWithSession: session];
}

- (void)registerFailed:(NSString *)reason {
    [textRegisterAlert setText: reason];
    [textRegisterAlert setHidden: NO];
    [self stopCurrentSpinner];
}

- (void)registerSuccessful:(NSString *)username {
    [self setViewState: AuthenticationViewControllerViewStateLogin];
    [fieldLoginUsername setText: username];
    [textRegisterAlert setHidden: YES];
    [textRegisterAlert setText: @""];
    [self stopCurrentSpinner];
}

#pragma mark -
#pragma mark EchoWebSocketClientDelegate

- (void)connectFinished {
    [self performSegueWithIdentifier: @"messaging" sender: self];
    [self stopSpinner:spinnerLogin darkenView:viewLoginDarken];
}

- (void)connectFailed:(NSString*)reason {
    [[self currentAlertText] setText: reason];
    [[self currentAlertText] setHidden: NO];
    [self stopCurrentSpinner];
}

@end
