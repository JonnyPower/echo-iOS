//
//  EchoButtonPrimary.m
//  Echo
//
//  Created by Jonny Power on 08/05/2016.
//  Copyright © 2016 JonnyPower. All rights reserved.
//

#import "EchoButtonPrimary.h"

@implementation EchoButtonPrimary

- (id)commonInit:(EchoButtonPrimary*)button {
    if(button) {
        [button setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
        [button.titleLabel setFont: [UIFont boldSystemFontOfSize: 15.0f]];
        [button setTitleShadowColor: [UIColor darkGrayColor] forState: UIControlStateNormal];
        [button setBackgroundImage: [[UIImage imageNamed:@"button_bg"] resizableImageWithCapInsets: UIEdgeInsetsMake(5, 5, 5, 5)] forState: UIControlStateNormal];
    }
    return button;
}

- (id)init {
    self = [super init];
    [self commonInit:self];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    [self commonInit:self];
    return self;
}

@end
