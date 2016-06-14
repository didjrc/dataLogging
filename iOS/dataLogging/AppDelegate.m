//
//  AppDelegate.m
//  dataLogging
//
//  Created by Jonathan Chinen on 14/6/16.
//  Copyright © 2016 Jonathan Chinen. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    // Set the delegate to receive PebbleKit events
    self.central = [PBPebbleCentral defaultCentral];
    self.central.delegate = self;
    
    // Register UUID
    NSUUID *myAppUUID =
    [[NSUUID alloc] initWithUUIDString:@"5fbb51fe-299d-48ca-bcaf-9c90d8ff9a9d"];
    [PBPebbleCentral defaultCentral].appUUID = myAppUUID;
    
    // Begin connection
    [self.central run];
    NSLog(@"self.central run");
    return YES;
}

- (void)pebbleCentral:(PBPebbleCentral*)central watchDidConnect:(PBWatch*)watch isNew:(BOOL)isNew {
    // Keep a reference to this watch
    self.connectedWatch = watch;
    self.connectedWatch.delegate = self;
    
    if (self.connectedWatch) {
        [self launchPebbleApp];
        NSLog(@"Pebble connected: %@", [watch name]);
        return;
    } else {
        NSLog(@"Failed...");
    }
}

- (void)pebbleCentral:(PBPebbleCentral*)central watchDidDisconnect:(PBWatch*)watch {
    NSLog(@"Pebble disconnected: %@", [watch name]);
    
    // If this was the recently connected watch, forget it
    if ([watch isEqual:self.connectedWatch]) {
        self.connectedWatch = nil;
    }
}

- (void)launchPebbleApp {
    [self.connectedWatch appMessagesLaunch:^(PBWatch *watch, NSError *error) {
        if (error) {
            NSLog(@"Error launching app on Pebble: %@", error);
        }
    }];
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
