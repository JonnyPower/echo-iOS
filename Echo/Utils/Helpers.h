//
//  Helpers.h
//  Echo
//
//  Created by Jonny Power on 24/11/2016.
//  Copyright © 2016 JonnyPower. All rights reserved.
//

#define RGB(r, g, b) [UIColor colorWithRed:r/225.0f green:g/225.0f blue:b/225.0f alpha:1]

#define MACRO_NAME(f) #f
#define MACRO_VALUE(f)  MACRO_NAME(f)
#define ENVIRONMENT_PLIST [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%s", MACRO_VALUE(ENVIRONMENT)] ofType:@"plist"]]
#define ENVIRONMENT_PLIST_KEY_PATH(keyPath) ([ENVIRONMENT_PLIST valueForKeyPath:keyPath])
#define IS_EMPTY(thing) (thing == nil || [thing isKindOfClass:[NSNull class]] || ([thing respondsToSelector:@selector(length)] && [(NSData *)thing length] == 0) || ([thing respondsToSelector:@selector(count)] && [(NSArray *)thing count] == 0))