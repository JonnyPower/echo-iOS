//
//  Message+CoreDataProperties.h
//  Echo
//
//  Created by Jonny Power on 07/05/2016.
//  Copyright © 2016 JonnyPower. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Message.h"

NS_ASSUME_NONNULL_BEGIN

@interface Message (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *content;
@property (nullable, nonatomic, retain) NSNumber *id;
@property (nullable, nonatomic, retain) NSDate *sent;
@property (nullable, nonatomic, retain) Participant *from;

@end

NS_ASSUME_NONNULL_END
