//
//  MessageCell.h
//  Echo
//
//  Created by Jonny Power on 06/05/2016.
//  Copyright © 2016 JonnyPower. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"

@interface MessageCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *deviceImage;
@property (weak, nonatomic) IBOutlet UILabel *textDeviceName;
@property (weak, nonatomic) IBOutlet UILabel *textMessageContent;
@property (weak, nonatomic) IBOutlet UILabel *textSent;

@end
