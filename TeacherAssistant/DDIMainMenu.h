//
//  DDIMainMenu.h
//  老师助手
//
//  Created by yons on 13-11-28.
//  Copyright (c) 2013年 dandian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDIHelpView.h"
#import "CommonFunc.h"
#import "OLGhostAlertView.h"
#import "UIImage+Scale.h"
#import "ASIHTTPRequest.h"
#import "DDIMyInforView.h"
#import "DDIShangkeTime.h"
#import "DDINotifySetup.h"
#import "DDIHelpView.h"
#import "DDIHelpQuest.h"
@interface DDIMainMenu : UITableViewController <UIActionSheetDelegate>
{
    NSString *savePath;
    UIImage *oldImage;
    UIImage *headImage;
    NSMutableArray *requestArray;
}
@property (strong,nonatomic) IBOutlet UILabel *lblBanben;
@property (strong,nonatomic) IBOutlet UILabel *lblName;
@property (strong,nonatomic) IBOutlet UILabel *lblBumen;
@property (strong,nonatomic) IBOutlet UIButton *btnHead;
- (IBAction)showBigPic:(id)sender;
- (IBAction)reLogin:(id)sender;
-(void)back:(id)sender;
@end
