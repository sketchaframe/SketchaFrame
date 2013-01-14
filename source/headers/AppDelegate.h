//
//  AppDelegate.h
//  SimpleFrame
//
//  Created by Jonas Lindemann on 5/24/12.
//  Copyright (c) 2012 Lund University. All rights reserved.
//

#import <UIKit/UIKit.h>
#define UIAppDelegate \
((AppDelegate *)[UIApplication sharedApplication].delegate)
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
