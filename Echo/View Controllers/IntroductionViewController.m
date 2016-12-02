//
//  IntroductionViewController.m
//  Echo
//
//  Created by Jonny Power on 05/05/2016.
//  Copyright © 2016 JonnyPower. All rights reserved.
//

#import "IntroductionViewController.h"

@interface IntroductionViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imgPushExample;

@end

@implementation IntroductionViewController

@synthesize imgPushExample = _imgPushExample;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_imgPushExample.layer setCornerRadius: 12.0f];
    [_imgPushExample.layer setMasksToBounds: YES];
    
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)actionReady:(id)sender {
    UIUserNotificationType allNotificationTypes =
    (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    [self dismissViewControllerAnimated: YES completion:^{
    }];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
