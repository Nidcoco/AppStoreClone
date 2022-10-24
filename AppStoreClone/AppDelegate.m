//
//  AppDelegate.m
//  AppStoreClone
//

#import "AppDelegate.h"
#import "TodayViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor systemBackgroundColor];
    self.window.rootViewController = [TodayViewController new];
    [self.window makeKeyAndVisible];
    
    return YES;
}


@end
