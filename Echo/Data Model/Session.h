//
//  Session.h
//  Echo
//
//  Created by Jonny Power on 07/05/2016.
//  Copyright © 2016 JonnyPower. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Session : NSObject

@property NSString *sessionToken;
@property NSString *deviceToken;
@property NSString *deviceName;
@property NSString *username;

+ (Session*)sessionWithUsername:(NSString*)username sessionToken:(NSString*)sessionToken deviceName:(NSString*)deviceName deviceToken:(NSString*)deviceToken;

@end
