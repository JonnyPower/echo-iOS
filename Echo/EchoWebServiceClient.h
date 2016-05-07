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
- (void)loginFailed:(NSString*)reason;
- (void)loginSuccessful:(Session*)session;

@end

@interface EchoWebServiceClient : NSObject

@property id<EchoWebServiceClientDelegate> delegate;

- (void)loginUsername:(NSString*)username password:(NSString*)password deviceName:(NSString*)deviceName deviceToken:(NSString*)deviceToken;

@end