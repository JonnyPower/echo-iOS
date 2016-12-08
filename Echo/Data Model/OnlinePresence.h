//
//  OnlinePresence.h
//  Echo
//
//  Created by Jonny Power on 02/12/2016.
//  Copyright © 2016 JonnyPower. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Participant.h"

@interface OnlinePresence : NSObject

@property (readonly) Participant *participant;
@property (readonly) NSDate *onlineAt;

- (instancetype)initWithParticipant:(Participant*)participant onlineAt:(NSDate*)onlineAt;

@end
