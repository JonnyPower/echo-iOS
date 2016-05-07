//
//  MessageCell.m
//  Echo
//
//  Created by Jonny Power on 06/05/2016.
//  Copyright © 2016 JonnyPower. All rights reserved.
//

#import "MessageCell.h"

@implementation MessageCell

@synthesize deviceImage;
@synthesize textMessageContent;
@synthesize textDeviceName;
@synthesize textSent;

- (id)init {
    self = [super init];
    
    if(self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return self;
}

@end
