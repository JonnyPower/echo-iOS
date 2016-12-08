//
//  MessageInputView.h
//  Echo
//
//  Created by Jonny Power on 06/05/2016.
//  Copyright © 2016 JonnyPower. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OnlinePresence.h"

@protocol MessageTextFieldViewDelegate <NSObject>

@required
- (void)sendMessage:(NSString*)content;

@end

@interface MessageTextFieldView : UIView <UITextViewDelegate>

@property id<MessageTextFieldViewDelegate> delegate;

- (void)displayOnlinePresences:(NSSet<OnlinePresence*>*)presences;

@end
