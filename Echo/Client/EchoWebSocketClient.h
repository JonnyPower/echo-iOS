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
#import "OnlinePresence.h"

@protocol EchoWebSocketPresenceDelegate <NSObject>

- (void)participantsReset;
- (void)participantJoined:(Participant*)joined;
- (void)participantLeft:(Participant*)left;

@end

@protocol EchoWebSocketClientDelegate <NSObject>

@optional
- (void)connectFinished;
- (void)connectFailed:(NSString*)reason;

- (void)pushMessageFinished;
- (void)pushMessageFailed:(NSString*)reason;

- (void)messageHistoryFinished;
- (void)messageHistoryFailed:(NSString*)reason;

- (void)socketDidClose:(NSString*)reason;

@end

@interface EchoWebSocketClient : NSObject <PhxSocketDelegate, PhxChannelDelegate>

@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;

- (void)addDelegate:(id<EchoWebSocketClientDelegate>)delegate;
- (void)removeDelegate:(id<EchoWebSocketClientDelegate>)delegate;

- (void)addPresenceDelegate:(id<EchoWebSocketPresenceDelegate>)delegate;
- (void)removePresenceDelegate:(id<EchoWebSocketPresenceDelegate>)delegate;

- (void)connectWithSession:(Session*)session;
- (void)pushMessage:(NSString*)content;
- (void)disconnect;

- (void)messageHistory:(int)days;

@end
