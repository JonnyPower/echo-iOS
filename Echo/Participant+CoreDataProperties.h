//
//  Participant+CoreDataProperties.h
//  Echo
//
//  Created by Jonny Power on 06/05/2016.
//  Copyright © 2016 JonnyPower. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Participant.h"

NS_ASSUME_NONNULL_BEGIN

@interface Participant (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *id;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSSet<NSManagedObject *> *messages;

@end

@interface Participant (CoreDataGeneratedAccessors)

- (void)addMessagesObject:(NSManagedObject *)value;
- (void)removeMessagesObject:(NSManagedObject *)value;
- (void)addMessages:(NSSet<NSManagedObject *> *)values;
- (void)removeMessages:(NSSet<NSManagedObject *> *)values;

@end

NS_ASSUME_NONNULL_END
