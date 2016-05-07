//
//  Message.m
//  Echo
//
//  Created by Jonny Power on 07/05/2016.
//  Copyright © 2016 JonnyPower. All rights reserved.
//

#import "Message.h"
#import "Participant.h"

@implementation Message

// Insert code here to add functionality to your managed object subclass

- (NSString *)dayString {
    
    [self willAccessValueForKey:@"sent"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    
    NSString *dayString = [[[dateFormatter stringFromDate: self.sent] componentsSeparatedByString:@"T"] firstObject];
    
    [self didAccessValueForKey:@"sent"];
    
    return dayString;
}

@end
