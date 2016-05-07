//
//  Message.h
//  Echo
//
//  Created by Jonny Power on 07/05/2016.
//  Copyright © 2016 JonnyPower. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Participant;

NS_ASSUME_NONNULL_BEGIN

@interface Message : NSManagedObject

// Insert code here to declare functionality of your managed object subclass
- (NSString *)dayString;

@end

NS_ASSUME_NONNULL_END

#import "Message+CoreDataProperties.h"
