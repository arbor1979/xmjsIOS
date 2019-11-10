//
//  DDIKaoQinDetail.h
//  掌上校园
//
//  Created by yons on 14-3-13.
//  Copyright (c) 2014年 dandian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIFormDataRequest.h"
#import "GTMBase64.h"
#import "OLGhostAlertView.h"
#import "CommonFunc.h"
#import "NSString+URLEncoding.h"
#import "UIImage+Scale.h"
@interface DDIKaoQinDetail : UITableViewController
{
    NSArray *detailArray;
    NSString *savePath;
    NSMutableArray *requestArray;
    OLGhostAlertView *alertTip;
}
@property (nonatomic,strong) NSString *interfaceUrl;
@end
