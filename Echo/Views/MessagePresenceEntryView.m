//
//  MessagePresenceEntryView.m
//  Echo
//
//  Created by Jonny Power on 07/12/2016.
//  Copyright © 2016 JonnyPower. All rights reserved.
//

#import "MessagePresenceEntryView.h"

@implementation MessagePresenceEntryView

@synthesize previous = _previous;
@synthesize next = _next;
@synthesize participant = _participant;
@synthesize online;
@synthesize deviceLabel;
@synthesize onlineIndicator;

CGFloat const ENTRY_HEIGHT = 30.0f;

CGFloat const INDICATOR_SIDE = 12.5f;
CGFloat const INDICATOR_PADDING = 5.0f;

- (instancetype)initWithPrevious:(MessagePresenceEntryView*)previous participant:(Participant*)participant {
    self = [super init];
    
    if(self) {
        [self setTranslatesAutoresizingMaskIntoConstraints: NO];
        
        _previous = previous;
        _participant = participant;
        online = YES;
        
        NSLayoutConstraint *constraintHeight = [NSLayoutConstraint constraintWithItem: self
                                                                            attribute: NSLayoutAttributeHeight
                                                                            relatedBy: NSLayoutRelationEqual
                                                                               toItem: nil
                                                                            attribute: NSLayoutAttributeNotAnAttribute
                                                                           multiplier: 1.0f
                                                                             constant: ENTRY_HEIGHT];
        [self addConstraint: constraintHeight];
        
        onlineIndicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"presence_indicator_online"]];
        [onlineIndicator setTranslatesAutoresizingMaskIntoConstraints: NO];
        [self addSubview: onlineIndicator];
        
        NSLayoutConstraint *constraintOnlineIndicatorHeight = [NSLayoutConstraint constraintWithItem: onlineIndicator
                                                                                           attribute: NSLayoutAttributeHeight
                                                                                           relatedBy: NSLayoutRelationEqual
                                                                                              toItem: nil
                                                                                           attribute: NSLayoutAttributeNotAnAttribute
                                                                                          multiplier: 1.0f
                                                                                            constant: INDICATOR_SIDE];
        NSLayoutConstraint *constraintOnlineIndicatorWidth = [NSLayoutConstraint constraintWithItem: onlineIndicator
                                                                                          attribute: NSLayoutAttributeWidth
                                                                                          relatedBy: NSLayoutRelationEqual
                                                                                             toItem: nil
                                                                                          attribute: NSLayoutAttributeNotAnAttribute
                                                                                         multiplier: 1.0f
                                                                                           constant: INDICATOR_SIDE];
        NSLayoutConstraint *constraintOnlineIndicatorX = [NSLayoutConstraint constraintWithItem: onlineIndicator
                                                                                      attribute: NSLayoutAttributeLeft
                                                                                      relatedBy: NSLayoutRelationEqual
                                                                                         toItem: self
                                                                                      attribute: NSLayoutAttributeLeft
                                                                                     multiplier: 1.0f
                                                                                       constant: INDICATOR_PADDING];
        
        NSLayoutConstraint *constraintOnlineIndicatorY = [NSLayoutConstraint constraintWithItem:onlineIndicator attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f];
        
        
        [onlineIndicator addConstraints:@[constraintOnlineIndicatorWidth, constraintOnlineIndicatorHeight]];
        [self addConstraint:constraintOnlineIndicatorX];
        [self addConstraint:constraintOnlineIndicatorY];
        
        deviceLabel = [[UILabel alloc] init];
        [deviceLabel setTranslatesAutoresizingMaskIntoConstraints: NO];
        [deviceLabel setText: participant.name];
        [deviceLabel setFont: [UIFont systemFontOfSize: 10.0f]];
        [deviceLabel setTextColor: [UIColor darkTextColor]];
        [self addSubview: deviceLabel];
        
        NSLayoutConstraint *constraintDeviceLabelHeight = [NSLayoutConstraint constraintWithItem: deviceLabel
                                                                                       attribute: NSLayoutAttributeHeight
                                                                                       relatedBy: NSLayoutRelationEqual
                                                                                          toItem: self
                                                                                       attribute: NSLayoutAttributeHeight
                                                                                      multiplier: 1.0f
                                                                                        constant: 0.0f];
        NSLayoutConstraint *constraintDeviceLabelX = [NSLayoutConstraint constraintWithItem: deviceLabel
                                                                                  attribute: NSLayoutAttributeLeading
                                                                                  relatedBy: NSLayoutRelationEqual
                                                                                     toItem: onlineIndicator
                                                                                  attribute: NSLayoutAttributeTrailing
                                                                                 multiplier: 1.0f
                                                                                   constant: INDICATOR_PADDING];
        NSLayoutConstraint *constraintDeviceLabelY = [NSLayoutConstraint constraintWithItem:deviceLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f];
        [self addConstraints:@[constraintDeviceLabelHeight, constraintDeviceLabelX, constraintDeviceLabelY]];
        
        NSLayoutConstraint *constraintWidth = [NSLayoutConstraint constraintWithItem: self
                                                                           attribute: NSLayoutAttributeWidth
                                                                           relatedBy: NSLayoutRelationEqual
                                                                              toItem: deviceLabel
                                                                           attribute: NSLayoutAttributeWidth
                                                                          multiplier: 1.0f
                                                                            constant: (INDICATOR_PADDING*2) + INDICATOR_SIDE];
        [self addConstraint: constraintWidth];
        
    }
    
    return self;
}

@end