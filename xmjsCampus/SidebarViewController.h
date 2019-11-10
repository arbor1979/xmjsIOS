//
//  ViewController.h
//  SideBarNavDemo
//
//  Created by JianYe on 12-12-11.
//  Copyright (c) 2012年 JianYe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SideBarSelectedDelegate.h"
#import "DDIMainMenu.h"
#import "DDIClassSchedule.h"
@interface SidebarViewController : UIViewController<SideBarSelectDelegate>
{
    UINavigationController *mainTabBar;
}


@property (strong,nonatomic)IBOutlet UIView *contentView;
@property (strong,nonatomic)IBOutlet UIView *navBackView;
+ (id)share;

@end
