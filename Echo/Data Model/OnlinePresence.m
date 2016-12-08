//
//  OnlinePresence.m
//  Echo
//
//  Created by Jonny Power on 02/12/2016.
//  Copyright © 2016 JonnyPower. All rights reserved.
//

#import "OnlinePresence.h"

@implementation OnlinePresence

@synthesize participant = _participant;
@synthesize onlineAt = _onlineAt;

- (instancetype)initWithParticipant:(Participant*)participant onlineAt:(NSDate*)onlineAt {
    self = [super init];
    
    if(self) {
        _participant = participant;
        _onlineAt = onlineAt;
    }
    
    return self;
}

@end
