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
    
    NSString *dayString = [NSDateFormatter localizedStringFromDate:self.sent
                                                          dateStyle:NSDateFormatterShortStyle
                                                          timeStyle:NSDateFormatterNoStyle];
    
    [self didAccessValueForKey:@"sent"];
    
    return dayString;
}

@end
