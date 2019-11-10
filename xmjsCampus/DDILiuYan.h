//
//  DDINewsTitle.h
//  掌上校园
//
//  Created by yons on 14-3-10.
//  Copyright (c) 2014年 dandian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonFunc.h"
#import "ASIHTTPRequest.h"
#import "OLGhostAlertView.h"
#import "EGORefreshTableHeaderView.h"
#import "DDIHelpView.h"
#import "DDIWenJuanDetail.h"

@interface DDILiuYan : UITableViewController
{
   
    NSString *savePath;
    NSMutableArray *requestArray;
    BOOL isLoading;
    NSString *btnUrl;
    OLGhostAlertView *alertTip;
    NSMutableArray *newsList;
    UISegmentedControl *segmentedControl;
    UIImage *delImg;
    UIImage *replyImg;
    NSURL *theUrl;
}
@property (nonatomic,strong) NSString *newsType;
@property (nonatomic,strong) NSString *interfaceUrl;
@end
