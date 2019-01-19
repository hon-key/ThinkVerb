//
//  AppDelegate.m
//  ThinkVerbDemo
//
//  Created by Ruite Chen on 2019/1/16.
//  Copyright © 2019 CAI. All rights reserved.
//

#import "AppDelegate.h"
#import "TableViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self.window makeKeyAndVisible];
    return YES;
}

- (UIWindow *)window {
    if (!_window) {
        _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        _window.rootViewController = self.navigationController;
    }
    return _window;
}

-  (UINavigationController *)navigationController {
    if (!_navigationController) {
        _navigationController = [[UINavigationController alloc] initWithRootViewController:[[TableViewController alloc] initWithStyle:UITableViewStyleGrouped]];
    }
    return _navigationController;
}

@end
