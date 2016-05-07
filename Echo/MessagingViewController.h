//
//  MessagingViewController.h
//  Echo
//
//  Created by Jonny Power on 05/05/2016.
//  Copyright © 2016 JonnyPower. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EchoWebSocketClient.h"
#import "MessageInputView.h"

@interface MessagingViewController : UITableViewController <UITableViewDataSource, MessageInputViewDelegate, NSFetchedResultsControllerDelegate, EchoWebSocketClientDelegate>

@property (weak, nonatomic) EchoWebSocketClient *webSocketClient;
@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;

@end
