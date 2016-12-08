//
//  EchoWebSocketClient.m
//  Echo
//
//  Created by Jonny Power on 06/05/2016.
//  Copyright © 2016 JonnyPower. All rights reserved.
//

#import "EchoWebSocketClient.h"
#import "Participant.h"
#import "AppDelegate.h"
#import "Helpers.h"

#import <Crashlytics/Crashlytics.h>

#define SOCKET_URL_STRING ENVIRONMENT_PLIST_KEY_PATH(@"WebSocketURL")

@interface EchoWebSocketClient ()

@property Session *session;
@property PhxSocket *socket;
@property PhxChannel *channel;
@property NSMutableSet<id<EchoWebSocketClientDelegate>>* delegates;
@property NSMutableSet<id<EchoWebSocketPresenceDelegate>>* presenceDelegates;
@property NSMapTable<NSNumber*, OnlinePresence*>* idToPresenceMap;

@end

@implementation EchoWebSocketClient

@synthesize session;
@synthesize socket;
@synthesize channel;
@synthesize delegates;
@synthesize presenceDelegates;
@synthesize managedObjectContext;
@synthesize idToPresenceMap;

- (id)init {
    self = [super init];
    
    if (self) {
        socket = [[PhxSocket alloc] initWithURL:[NSURL URLWithString:SOCKET_URL_STRING] heartbeatInterval:20];
        socket.delegate = self;
        
        delegates = [NSMutableSet set];
        presenceDelegates = [NSMutableSet set];
    }
    
    return self;
}

- (void)addDelegate:(id<EchoWebSocketClientDelegate>)delegate {
    [delegates addObject: delegate];
}

- (void)removeDelegate:(id<EchoWebSocketClientDelegate>)delegate {
    [delegates removeObject: delegate];
}

- (void)connectWithSession:(Session *)connectSession {
    
    self.session = connectSession;
    
    [socket connectWithParams:@{@"token": session.sessionToken}];
    channel = [[PhxChannel alloc] initWithSocket:socket topic:[NSString stringWithFormat:@"echoes:%@", session.username] params:nil];
    channel.delegate = self;
    
    [channel onEvent:@"message" callback:^(id message, id ref) {
        [self saveMessage: message];
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
    }];
    
    [channel onEvent:@"presence_state" callback:^(id message, id ref) {
        [self presenceState: message];
    }];
    
    [channel onEvent:@"presence_diff" callback:^(id message, id ref) {
        [self presenceDiff: message];
    }];
    
    PhxPush *join = [channel join];
    [join onReceive:@"ok" callback:^(id response) {
        [Answers logCustomEventWithName:@"Connected with session" customAttributes:@{@"username":session.username,
                                                                                     @"deviceName":session.deviceName}];
        for (NSDictionary *messageDictionary in [response objectForKey:@"messages"]) {
            [self saveMessage: messageDictionary];
        }
        for (id<EchoWebSocketClientDelegate> delegate in delegates) {
            if([delegate respondsToSelector:@selector(connectFinished)]) {
                [delegate connectFinished];
            }
        }
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
    }];
    [join onReceive:@"error" callback:^(id response) {
        for (id<EchoWebSocketClientDelegate> delegate in delegates) {
            if([delegate respondsToSelector:@selector(connectFailed:)]) {
                [delegate connectFailed:[response objectForKey:@"reason"]];
            }
        }
    }];
    [join after:60 callback:^(void) {
        for (id<EchoWebSocketClientDelegate> delegate in delegates) {
            if([delegate respondsToSelector:@selector(connectFailed:)]) {
                [delegate connectFailed:@"Took too long to connect"];
            }
        }
    }];
}

- (void)pushMessage:(NSString *)content {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:@"yyyyMMdd'T'HHmmssZ"];
    
    NSDate *sent = [NSDate date];
    NSString *iso8601String = [dateFormatter stringFromDate:sent];
    
    PhxPush *push = [channel pushEvent:@"message" payload:@{@"content": content, @"sent": iso8601String}];
    [push onReceive:@"ok" callback:^(id response) {
        
        NSNumber *messageId = [response objectForKey:@"message_id"];
        
        NSNumber *participantId = [NSNumber numberWithInt: 0]; // This device represented by id 0
        NSString *participantName = session.deviceName;
        
        [self saveMessageParticipantId: participantId
                       participantName: participantName
                       participantType: @"iOS"
                             messageId: messageId
                        messageContent: content
                                  sent: sent];
    }];
    [push onReceive:@"error" callback:^(id reason) {
        // TODO
    }];
    [push after:60 callback:^(void) {
        // TODO
    }];
}


- (void)messageHistory:(int)days {
    PhxPush *push = [channel pushEvent:@"history" payload:@{@"days": [NSNumber numberWithInt:days]}];
    [push onReceive:@"ok" callback:^(id response) {
        for (NSDictionary *messageDictionary in [response objectForKey:@"messages"]) {
            [self saveMessage: messageDictionary];
        }
        for (id<EchoWebSocketClientDelegate> delegate in delegates) {
            if([delegate respondsToSelector:@selector(messageHistoryFinished)]) {
                [delegate messageHistoryFinished];
            }
        }
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
    }];
    [push onReceive:@"error" callback:^(id reason) {
        // TODO
    }];
    [push after:60 callback:^(void) {
        // TODO
    }];
}

- (void)disconnect {
    [socket disconnect];
    socket = [[PhxSocket alloc] initWithURL:[NSURL URLWithString:SOCKET_URL_STRING] heartbeatInterval:20];
    socket.delegate = self;
}

#pragma mark -
#pragma mark PhxSocketDelegate

- (void)phxSocketDidOpen {
    NSLog(@"socket open");
}

- (void)phxSocketDidReceiveError:(id)error {
    NSLog(@"socket error: %@", [error description]);
    if(![socket isConnected]) {
        for (id<EchoWebSocketClientDelegate> delegate in delegates) {
            if([delegate respondsToSelector:@selector(connectFailed:)]) {
                [delegate connectFailed:[error localizedDescription]];
            }
        }
    }
}

- (void)phxSocketDidClose:(NSError*)error {
    if([error isKindOfClass:[NSString class]]) {
        [((AppDelegate*)[UIApplication sharedApplication].delegate) logout];
        NSLog(@"socket close: %@", error);
    } else if([[error.userInfo objectForKey:@"HTTPResponseStatusCode"] intValue] == 403) {
        [((AppDelegate*)[UIApplication sharedApplication].delegate) logout];
        NSLog(@"socket close: %@", [error description]);
    }
}

#pragma mark -
#pragma mark PhxChannelDelegate

- (void)phxChannelClosed {
    
}

- (void)phxChannelDidReceiveError:(id)error {
    
}

- (void)saveMessage:(NSDictionary*)messageDictionary {
    
    NSDictionary *from = [messageDictionary objectForKey:@"from"];
    
    NSNumber *participantId = [from objectForKey:@"id"];
    NSString *participantName = [from objectForKey:@"name"];
    NSString *participantType = [from objectForKey:@"type"];
    
    NSString *messageContent = [messageDictionary objectForKey:@"content"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setLenient: YES];
    [dateFormatter setDateFormat:@"yyyyMMdd'T'HHmmssZ"];
    
    NSDate *sent = [dateFormatter dateFromString:[messageDictionary objectForKey:@"sent"]];
    
    NSNumber *messageId = [messageDictionary objectForKey:@"id"];
    
    [self saveMessageParticipantId: participantId
                   participantName: participantName
                   participantType: participantType
                         messageId: messageId
                    messageContent: messageContent
                              sent: sent];
}

- (void)saveMessageParticipantId:(NSNumber*)participantId
                 participantName:(NSString*)participantName
                 participantType:(NSString*)participantType
                       messageId:(NSNumber*)messageId
                  messageContent:(NSString*)messageContent
                            sent:(NSDate*)sent {
    
    if([self messageExists:messageId]) {
        return;
    }
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Participant"];
    
    NSError *error = nil;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
    if(error) {
        NSAssert(NO, @"Error fetching Participant objects: %@\n%@", [error localizedDescription], [error userInfo]);
    }
    
    Participant *participant;
    for(Participant *result in results) {
        if(result.id == participantId) {
            participant = result;
        }
    }
    if(participant == nil) {
        participant = [NSEntityDescription insertNewObjectForEntityForName: @"Participant"
                                                    inManagedObjectContext: managedObjectContext];
        participant.id = participantId;
    }
    
    participant.name = participantName;
    participant.type = participantType;
    
    Message *message = [NSEntityDescription insertNewObjectForEntityForName: @"Message"
                                                     inManagedObjectContext: managedObjectContext];
    message.id = messageId;
    message.from = participant;
    message.content = messageContent;
    message.sent = sent;
    
    NSError *saveError = nil;
    if ([managedObjectContext save:&saveError] == NO) {
        NSAssert(NO, @"Error saving context: %@\n%@", [saveError localizedDescription], [saveError userInfo]);
    }
}

- (BOOL)messageExists:(NSNumber*)messageId {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Message"];
    
    NSError *error = nil;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
    if(error) {
        NSAssert(NO, @"Error fetching Participant objects: %@\n%@", [error localizedDescription], [error userInfo]);
    }
    
    for(Message *message in results) {
        if([message.id intValue] == [messageId intValue]) {
            return YES;
        }
    }
    return NO;
}

- (void)presenceState:(NSDictionary*)presenceState {
    
    for(id<EchoWebSocketPresenceDelegate> presenceDelegate in presenceDelegates) {
        if([presenceDelegate respondsToSelector:@selector(participantsReset)]) {
            [presenceDelegate participantsReset];
        }
    }
    
    self.idToPresenceMap = [NSMapTable strongToStrongObjectsMapTable];
    [self handlePresenceJoins: presenceState];
}

- (void)handlePresenceJoins:(NSDictionary*)joins {
    [joins enumerateKeysAndObjectsUsingBlock:^(NSString *deviceId, NSDictionary *presenceDictionary, BOOL *stop) {
        NSFetchRequest *request= [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Participant" inManagedObjectContext:managedObjectContext];
        NSPredicate *predicate =[NSPredicate predicateWithFormat:@"id==%d", [deviceId integerValue]];
        [request setEntity:entity];
        [request setPredicate:predicate];
        
        NSError *error;
        NSArray *entities = [managedObjectContext executeFetchRequest:request error:&error];
        
        if(!error) {
            Participant *participant = [entities firstObject];
            NSDictionary *deviceDictionary = [presenceDictionary objectForKey:@"device"];
            if(participant == nil) {
                participant = [NSEntityDescription insertNewObjectForEntityForName: @"Participant"
                                                            inManagedObjectContext: managedObjectContext];
                participant.id = [deviceDictionary objectForKey:@"id"];
            }
            participant.name = [deviceDictionary objectForKey:@"name"];
            participant.type = [deviceDictionary objectForKey:@"type"];
            
            NSDictionary *presenceMeta = [presenceDictionary objectForKey: @"meta"];
            NSTimeInterval onlineAtEpoch = [[presenceMeta objectForKey:@"online_at"] doubleValue];
            NSDate *onlineAt = [NSDate dateWithTimeIntervalSince1970:onlineAtEpoch];
            
            for(id<EchoWebSocketPresenceDelegate> presenceDelegate in presenceDelegates) {
                if([presenceDelegate respondsToSelector:@selector(participantJoined:)]) {
                    [presenceDelegate participantJoined: participant];
                }
            }
            
            OnlinePresence *devicePresence = [[OnlinePresence alloc] initWithParticipant: participant
                                                                                onlineAt: onlineAt];
            [self.idToPresenceMap setObject: devicePresence forKey: participant.id];
        }
    }];
}

- (void)handlePresenceLeaves:(NSDictionary*)leaves {
    [leaves enumerateKeysAndObjectsUsingBlock:^(NSString *deviceId, NSDictionary *presenceDictionary, BOOL *stop) {
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        f.numberStyle = NSNumberFormatterDecimalStyle;
        NSNumber *deviceIdNumber = [f numberFromString:deviceId];
        
        Participant *leftParticipant = [self.idToPresenceMap objectForKey: deviceIdNumber].participant;
        for(id<EchoWebSocketPresenceDelegate> presenceDelegate in presenceDelegates) {
            if([presenceDelegate respondsToSelector:@selector(participantLeft:)]) {
                [presenceDelegate participantLeft: leftParticipant];
            }
        }
        
        [self.idToPresenceMap removeObjectForKey: deviceIdNumber];
    }];
}

- (void)presenceDiff:(NSDictionary*)presenceDiff {
    NSLog(@"Socket Presence Diff: %@", [presenceDiff description]);
    
    if(self.idToPresenceMap == nil) {
        self.idToPresenceMap = [NSMapTable strongToStrongObjectsMapTable];
    }
    
    NSDictionary *joins = [presenceDiff objectForKey: @"joins"];
    [self handlePresenceJoins: joins];
    
    NSDictionary *leaves = [presenceDiff objectForKey: @"leaves"];
    [self handlePresenceLeaves: leaves];
}

- (void)addPresenceDelegate:(id<EchoWebSocketPresenceDelegate>)delegate {
    [presenceDelegates addObject: delegate];
    for(OnlinePresence *onlinePresence in [self.idToPresenceMap objectEnumerator]) {
        if([delegate respondsToSelector:@selector(participantJoined:)]) {
            [delegate participantJoined: onlinePresence.participant];
        }
    }
}

- (void)removePresenceDelegate:(id<EchoWebSocketPresenceDelegate>)delegate {
    [presenceDelegates removeObject:delegate];
}

@end
