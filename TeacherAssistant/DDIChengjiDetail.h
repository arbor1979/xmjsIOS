//
//  DDIChengjiDetail.h
//  掌上校园
//
//  Created by yons on 14-3-14.
//  Copyright (c) 2014年 dandian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OLGhostAlertView.h"
#import "ASIFormDataRequest.h"
#import "GTMBase64.h"
#import "DDIHelpView.h"
#import "DDIWenJuanDetail.h"
#import "CommonFunc.h"
@interface DDIChengjiDetail : UITableViewController
{
    NSMutableArray *detailArray;
    NSString *savePath,*btnUrl;
    NSMutableArray *requestArray;
    OLGhostAlertView *alertTip;
    NSNumber *leftWidth;
    NSString *savepath;
    
}
@property (nonatomic,strong) NSString *interfaceUrl;
@end
