//
//  MessageTableView.h
//  Echo
//
//  Created by Jonny Power on 06/05/2016.
//  Copyright © 2016 JonnyPower. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageTextFieldView.h"
#import "MessagePresenceView.h"

@interface MessageTableView : UITableView

@property (nonatomic, readwrite, retain) UIView *inputAccessoryView;
@property MessageTextFieldView *messageTextFieldView;
@property MessagePresenceView *messagePresenceView;

@end
