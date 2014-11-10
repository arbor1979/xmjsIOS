//
//  DDIDiaoChaWenJuan.h
//  掌上校园
//
//  Created by yons on 14-3-17.
//  Copyright (c) 2014年 dandian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIFormDataRequest.h"
#import "GTMBase64.h"
#import "OLGhostAlertView.h"
#import "CommonFunc.h"
#import "UIImage+Scale.h"
#import "DDIWenJuanDetail.h"
@interface DDIWenJuanTitle : UITableViewController
{
    
    NSString *savePath;
    NSMutableArray *requestArray;
    OLGhostAlertView *alertTip;
    
}
@property (nonatomic,strong) NSString *interfaceUrl;
@property (nonatomic,strong) NSMutableArray *titleArray;
@end
