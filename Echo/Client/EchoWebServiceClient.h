//
//  EchoWebServiceClient.h
//  Echo
//
//  Created by Jonny Power on 06/05/2016.
//  Copyright © 2016 JonnyPower. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Session.h"

@protocol EchoWebServiceClientDelegate <NSObject>

@required
- (void)requestFailed:(NSError*)error;

@optional

- (void)registerSuccessful:(NSString*)username;
- (void)registerFailed:(NSString*)reason;

- (void)loginSuccessful:(Session*)session;
- (void)loginFailed:(NSString*)reason;

- (void)logoutSuccessful;
- (void)logoutFailed:(NSString*)reason;

@end

@interface EchoWebServiceClient : NSObject

@property id<EchoWebServiceClientDelegate> delegate;

- (void)registerUsername:(NSString*)username
                password:(NSString*)password
         confirmPassword:(NSString*)confirmPassword;
- (void)loginUsername:(NSString*)username
             password:(NSString*)password
           deviceName:(NSString*)deviceName
          deviceToken:(NSString*)deviceToken;
- (void)logoutSessionToken:(NSString*)sessionToken
               deviceToken:(NSString*)deviceToken;

@end