//
//  EchoWebServiceClient.m
//  Echo
//
//  Created by Jonny Power on 06/05/2016.
//  Copyright © 2016 JonnyPower. All rights reserved.
//

#import "EchoWebServiceClient.h"
#import "AppDelegate.h"

#import <Crashlytics/Crashlytics.h>

#define API_URL_STRING @"http://192.168.0.11:4000/api/"

@interface EchoWebServiceClient ()

@end

@implementation EchoWebServiceClient

@synthesize delegate;

- (void)logoutSessionToken:(NSString *)sessionToken deviceToken:(NSString *)deviceToken {
    
    NSURL *logoutUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@logout", API_URL_STRING]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:logoutUrl];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject: @{
                                                                  @"session_token": sessionToken,
                                                                  @"device_token": deviceToken
                                                                }
                                                       options:0
                                                         error:nil];
    request.HTTPBody = jsonData;
    
    
    [self executeRequest:request successHandler:^(NSDictionary *response) {
        BOOL success = [[response objectForKey:@"success"] boolValue];
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if([delegate respondsToSelector:@selector(logoutSuccessful)]) {
                    [delegate logoutSuccessful];
                }
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if([delegate respondsToSelector:@selector(logoutFailed:)]) {
                    [delegate logoutFailed:@"Couldn't logout - probably already logged out"];
                }
            });
        }
    }];
}

- (void)loginUsername:(NSString*)username
             password:(NSString*)password
           deviceName:(NSString*)deviceName
          deviceToken:(NSString *)deviceToken {
    
    username = [username stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    deviceName = [deviceName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSURL *loginUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@login", API_URL_STRING]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:loginUrl];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject: @{
                                                                  @"name": username,
                                                                  @"password": password,
                                                                  @"device": @{
                                                                    @"token": deviceToken,
                                                                    @"name": deviceName,
                                                                    @"type": @"iOS"
                                                                  },
                                                                  @"timezone": [[NSTimeZone localTimeZone] name]
                                                                }
                                                       options:0
                                                         error:nil];
    request.HTTPBody = jsonData;
    
    [self executeRequest:request successHandler:^(NSDictionary *response) {
        BOOL success = [[response objectForKey:@"success"] boolValue];
        if (success) {
            if([delegate respondsToSelector:@selector(loginSuccessful:)]) {
                
                [Answers logCustomEventWithName:@"Login Sucessful" customAttributes:@{@"username":username,
                                                                                      @"deviceName":deviceName,
                                                                                      @"deviceToken":deviceToken}];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
                    
                    Session *session = [Session sessionWithUsername: username
                                                       sessionToken: [response objectForKey:@"session_token"]
                                                         deviceName: deviceName
                                                        deviceToken: deviceToken];
                    [appDelegate saveSession: session];
                    
                    [delegate loginSuccessful: session];
                });
            }
        } else {
            if ([delegate respondsToSelector:@selector(loginFailed:)]) {
                NSString *failureReason = [response objectForKey:@"message"];
                failureReason = failureReason == nil ? @"Unknown reason for failure" : failureReason;
                [Answers logCustomEventWithName:@"Login Failed" customAttributes:@{@"username":username,
                                                                                   @"deviceName":deviceName,
                                                                                   @"deviceToken":deviceToken,
                                                                                   @"reason": failureReason}];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [delegate loginFailed:failureReason];
                });
            }
        }
    }];
}

- (void)executeRequest:(NSURLRequest*)request successHandler:(void (^)(NSDictionary* response))successHandler {
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(error) {
            [self.delegate requestFailed: error];
        } else {
            NSError *jsonError;
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            if(error) {
                NSLog(@"Failed to parse JSON response: %@", [error description]);
            } else {
                successHandler(response);
            }
        }
    }] resume];
}

@end