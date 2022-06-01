//
//  AppDelegate.m
//  RCSceneVideoRoomDemo
//
//  Created by 彭蕾 on 2022/6/1.
//

#import "AppDelegate.h"
#import "RCRoomListViewController.h"
#import "RCSceneVideoRoomDemo-Swift.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    RCRoomListViewController *roomListVC = [RCRoomListViewController new];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:roomListVC];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    [AppConfigs config];
    return YES;
}


@end
