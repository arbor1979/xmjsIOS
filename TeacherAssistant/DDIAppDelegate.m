//
//  DDIAppDelegate.m
//  TeacherAssistant
//
//  Created by yons on 13-11-7.
//  Copyright (c) 2013年 dandian. All rights reserved.
//

#import "DDIAppDelegate.h"

NSString *kInitURL;//默认单点webServic
NSString *kServiceURL;//学校的webServic
NSString *kUserIndentify;//用户登录后的唯一识别码
NSMutableDictionary *userInfoDic;//用户所有数据
NSMutableArray *colorArray;
Boolean kIOS7;
@implementation DDIAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    kInitURL = @"http://42.51.130.102/appserver/appserver.php";
    kServiceURL = @"http://42.51.130.102/appserver/appserver.php";

    kIOS7=[[[UIDevice currentDevice]systemVersion] floatValue] >= 7.0;
    //初始化颜色数组
    colorArray=[[NSMutableArray alloc] init];
    
    
    [colorArray addObject:[UIColor colorWithRed:131/255.0f green:115/255.0f blue:81/255.0f alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:85/255.0f green:180/255.0f blue:186/255.0f alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:222/255.0f green:225/255.0f blue:136/255.0f alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:167/255.0f green:175/255.0f blue:56/255.0f alpha:1.0]];
    

    [colorArray addObject:[UIColor colorWithRed:237/255.0f green:164/2550.f blue:158/255.0f alpha:1]];
    [colorArray addObject:[UIColor colorWithRed:237/255.0f green:165/2550.f blue:115/255.0f alpha:1]];
    [colorArray addObject:[UIColor colorWithRed:241/255.0f green:195/2550.f blue:143/255.0f alpha:1]];
    [colorArray addObject:[UIColor colorWithRed:255/255.0f green:223/2550.f blue:190/255.0f alpha:1]];
 
    [colorArray addObject:[UIColor colorWithRed:247/255.0f green:240/2550.f blue:198/255.0f alpha:1]];
    [colorArray addObject:[UIColor colorWithRed:212/255.0f green:133/2550.f blue:187/255.0f alpha:1]];
    /*
    [colorArray addObject:[UIColor colorWithRed:1 green:0.505882 blue:0.780392 alpha:1]];
    [colorArray addObject:[UIColor colorWithRed:1 green:0.580392 blue:0.65098 alpha:1]];
    [colorArray addObject:[UIColor colorWithRed:0.996078 green:1 blue:0.607843 alpha:1]];
    [colorArray addObject:[UIColor colorWithRed:1 green:0.905882 blue:0.760784 alpha:1]];
    [colorArray addObject:[UIColor colorWithRed:1 green:0.882353 blue:0.411765 alpha:1]];
    [colorArray addObject:[UIColor colorWithRed:1 green:0.843137 blue:0.611765 alpha:1]];
    [colorArray addObject:[UIColor colorWithRed:0.921569 green:1 blue:0.803922 alpha:1]];
    [colorArray addObject:[UIColor colorWithRed:0.921569 green:0.317647 blue:1 alpha:1]];
    [colorArray addObject:[UIColor colorWithRed:1 green:0.301961 blue:0.8 alpha:1]];
    [colorArray addObject:[UIColor colorWithRed:0.392 green:0.588 blue:0 alpha:1]];
     */
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
