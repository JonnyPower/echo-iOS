//
//  MessagePresenceView.h
//  Echo
//
//  Created by Jonny Power on 02/12/2016.
//  Copyright © 2016 JonnyPower. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EchoWebSocketClient.h"

@interface MessagePresenceView : UIView <EchoWebSocketPresenceDelegate>

@end
