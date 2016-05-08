//
//  AppDelegate.m
//  Echo
//
//  Created by Jonny Power on 05/05/2016.
//  Copyright © 2016 JonnyPower. All rights reserved.
//

#import "AppDelegate.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "AuthenticationViewController.h"
#import "MessagingViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize webSocketClient = _webSocketClient;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [Fabric with:@[[Crashlytics class]]];
    
    _webSocketClient = [[EchoWebSocketClient alloc] init];
    _webSocketClient.managedObjectContext = self.managedObjectContext;
    
    UINavigationController *navController = ((UINavigationController*)self.window.rootViewController);
    AuthenticationViewController *authController = [navController.viewControllers objectAtIndex:0];
    authController.webSocketClient = _webSocketClient;
    
    navController.navigationBar.barStyle = UIBarStyleBlack;
    
    return YES;
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
    // Saves changes in the application's managed object context before the application terminates.
}

- (Session*)savedSession {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedObject = [defaults objectForKey:@"session"];
    Session *session = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    return session;
}

- (void)saveSession:(Session*)session {
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:session];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:encodedObject forKey:@"session"];
    [defaults synchronize];
}

- (void)logout {
    Session *session = [self savedSession];
    EchoWebServiceClient *client = [[EchoWebServiceClient alloc] init];
    client.delegate = self;
    [client logoutSessionToken:session.sessionToken deviceToken:session.deviceToken];
}

- (void)logoutSuccessful {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"session"];
    [self.webSocketClient disconnect];
    
    [self deleteAll];
    
    UINavigationController *navController = ((UINavigationController*)self.window.rootViewController);
    if([[[navController viewControllers] lastObject] isKindOfClass:[MessagingViewController class]]) {
        [navController popToRootViewControllerAnimated:YES];
    }
}

- (void)logoutFailed:(NSString *)reason {
    // TODO
}

- (void)requestFailed:(NSError *)error {
    // TODO
}

- (void)deleteAll {
    _persistentStoreCoordinator = nil;
    _managedObjectContext = nil;
    _managedObjectModel = nil;
    
    _webSocketClient.managedObjectContext = self.managedObjectContext;
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Echo" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSError *error = nil;
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType
                                                   configuration:nil
                                                             URL:nil
                                                         options:nil
                                                           error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

@end
