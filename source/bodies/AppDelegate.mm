//
//  AppDelegate.m
//  SimpleFrame
//
//  Created by Jonas Lindemann on 5/24/12.
//  Copyright (c) 2012 Lund University. All rights reserved.
//

#import "AppDelegate.h"
#import "Models.h"
#import "WriteCoreData.h"
#import "CoreDataTableViewController.h"

@implementation AppDelegate
@synthesize window = _window;



- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
    
{
#define TESTING 1
#ifdef TESTING
    [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
#endif
    
    [TestFlight takeOff:@"ca7da82d4b247ffdfff9d1c1501e04ae_MTY4NDQzMjAxMi0xMi0yMCAwNToxNTo0My4zMzc3OTA"];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    

}


@end
