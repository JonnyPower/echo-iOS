//
//  Session.m
//  Echo
//
//  Created by Jonny Power on 07/05/2016.
//  Copyright © 2016 JonnyPower. All rights reserved.
//

#import "Session.h"

@implementation Session

@synthesize sessionToken;
@synthesize deviceToken;
@synthesize deviceName;
@synthesize username;


+ (Session*)sessionWithUsername:(NSString*)username
                   sessionToken:(NSString*)sessionToken
                     deviceName:(NSString*)deviceName
                    deviceToken:(NSString*)deviceToken {
    Session *session = [[Session alloc] init];
    
    if(self) {
        session.username = username;
        session.sessionToken = sessionToken;
        session.deviceName = deviceName;
        session.deviceToken = deviceToken;
    }
    
    return session;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.username forKey:@"username"];
    [encoder encodeObject:self.sessionToken forKey:@"sessionToken"];
    [encoder encodeObject:self.deviceName forKey:@"deviceName"];
    [encoder encodeObject:self.deviceToken forKey:@"deviceToken"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        self.username = [decoder decodeObjectForKey:@"username"];
        self.sessionToken = [decoder decodeObjectForKey:@"sessionToken"];
        self.deviceName = [decoder decodeObjectForKey:@"deviceName"];
        self.deviceToken = [decoder decodeObjectForKey:@"deviceToken"];
    }
    return self;
}

@end
