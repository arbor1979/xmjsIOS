//
//  DDINewsTitle.h
//  掌上校园
//
//  Created by yons on 14-3-10.
//  Copyright (c) 2014年 dandian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDIDataModel.h"
#import "News.h"
#import "CommonFunc.h"
#import "ASIHTTPRequest.h"
#import "OLGhostAlertView.h"
#import "DDINewsDetail.h"
#import "EGORefreshTableHeaderView.h"
#import "DDIHelpView.h"
#import "TQRichTextView.h"
@interface DDINewsTitle : UITableViewController<EGORefreshTableHeaderDelegate,UIActionSheetDelegate>
{
    NSArray *newsList;
    NSString *savePath;
    NSMutableArray *requestArray;
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    UIColor *unreadColor;
    BOOL firstLoad;

}
@property (nonatomic,strong) NSString *newsType;
@property (nonatomic,strong) NSString *interfaceUrl;
@end
