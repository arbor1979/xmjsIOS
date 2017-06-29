//
//  DDIChengjiTitle.h
//  掌上校园
//
//  Created by yons on 14-3-14.
//  Copyright (c) 2014年 dandian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIFormDataRequest.h"
#import "GTMBase64.h"
#import "OLGhostAlertView.h"
#import "CommonFunc.h"
#import "UIImage+Scale.h"
#import "DDIChengjiDetail.h"
#import "DDIWenJuanDetail.h"
#import "DDIWenJuanTitle.h"
#import "NSString+URLEncoding.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface DDIChengjiTitle : UITableViewController
{
    NSArray *titleArray;
    NSString *savePath;
    NSMutableArray *requestArray;
    OLGhostAlertView *alertTip;
    UIColor *mygreen;
    NSString *btnUrl;
    NSString *btnSubmit;
    UIImage *emptyPhoto;
}

@property (nonatomic,strong) NSString *interfaceUrl;
@end
