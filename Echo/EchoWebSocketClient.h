//
//  EchoWebSocketClient.h
//  Echo
//
//  Created by Jonny Power on 06/05/2016.
//  Copyright © 2016 JonnyPower. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhoenixClient.h"

#import "Message.h"
#import "Session.h"

@protocol EchoWebSocketClientDelegate <NSObject>

@optional
- (void)socketDidOpen;
- (void)socketFailedSetup;

- (void)pushMessageFinished;
- (void)pushMessageFailed:(NSString*)reason;

- (void)messageHistoryFinished;
- (void)messageHistoryFailed:(NSString*)reason;

@end

@interface EchoWebSocketClient : NSObject <PhxSocketDelegate, PhxChannelDelegate>

@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;

- (void)addDelegate:(id<EchoWebSocketClientDelegate>)delegate;
- (void)removeDelegate:(id<EchoWebSocketClientDelegate>)delegate;

- (void)connectWithSession:(Session*)session;
- (void)pushMessage:(NSString*)content;
- (void)disconnect;

- (void)messageHistory:(int)days;

@end
