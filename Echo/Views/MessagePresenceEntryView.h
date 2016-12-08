//
//  MessagePresenceEntryView.h
//  Echo
//
//  Created by Jonny Power on 07/12/2016.
//  Copyright © 2016 JonnyPower. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Participant.h"

@interface MessagePresenceEntryView : UIView;

@property MessagePresenceEntryView *previous;
@property MessagePresenceEntryView *next;
@property BOOL online;
@property Participant *participant;
@property UILabel *deviceLabel;
@property UIImageView *onlineIndicator;

- (instancetype)initWithPrevious:(MessagePresenceEntryView*)previous participant:(Participant*)participant;

@end