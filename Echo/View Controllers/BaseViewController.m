//
//  BaseViewController.m
//  Echo
//
//  Created by Jonny Power on 24/11/2016.
//  Copyright © 2016 JonnyPower. All rights reserved.
//

#import "BaseViewController.h"
#import "Helpers.h"

@interface BaseViewController ()
@property UILabel *versionlabel;
@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    BOOL showVersion = [ENVIRONMENT_PLIST_KEY_PATH(@"ShowVersion") boolValue];
    if(showVersion && NO) {
        self.versionlabel = [[UILabel alloc] init];
        [self.view addSubview: self.versionlabel];
        
        NSLayoutConstraint *versionLabelHeightConstraint = [NSLayoutConstraint constraintWithItem: self.versionlabel
                                                                                        attribute: NSLayoutAttributeHeight
                                                                                        relatedBy: NSLayoutRelationEqual
                                                                                           toItem: nil
                                                                                        attribute: NSLayoutAttributeNotAnAttribute
                                                                                       multiplier: 1.0
                                                                                         constant: 12.0f];
        NSLayoutConstraint *versionLabelWidthConstraint = [NSLayoutConstraint constraintWithItem: self.versionlabel
                                                                                       attribute: NSLayoutAttributeWidth
                                                                                       relatedBy: NSLayoutRelationEqual
                                                                                          toItem: self.versionlabel.superview
                                                                                       attribute: NSLayoutAttributeWidth
                                                                                      multiplier: 1.0f
                                                                                        constant: 0.0f];
        NSLayoutConstraint *bottomToVersionBottomConstraint = [NSLayoutConstraint constraintWithItem: self.bottomLayoutGuide
                                                                                           attribute: NSLayoutAttributeTop
                                                                                           relatedBy: NSLayoutRelationEqual
                                                                                              toItem: self.versionlabel
                                                                                           attribute: NSLayoutAttributeBottom
                                                                                          multiplier: 1.0f
                                                                                            constant: 0.0f];
        [self.view addConstraints:@[bottomToVersionBottomConstraint, versionLabelWidthConstraint, versionLabelHeightConstraint]];
        NSString *environment = [[NSString stringWithCString:MACRO_VALUE(ENVIRONMENT) encoding:NSUTF8StringEncoding] capitalizedString];
        NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
        NSString *versionString = [NSString stringWithFormat:@"%@ | Version %@ | Build %@", environment, version, build];
        [self.versionlabel setText: versionString];
        [self.versionlabel setTextColor: [UIColor whiteColor]];
        [self.versionlabel setFont: [UIFont systemFontOfSize: 8.0]];
        [self.versionlabel setBackgroundColor: [UIColor orangeColor]];
        [self.versionlabel setTextAlignment: NSTextAlignmentCenter];
        [self.versionlabel setTranslatesAutoresizingMaskIntoConstraints: NO];
    }
    [self.view layoutIfNeeded];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
