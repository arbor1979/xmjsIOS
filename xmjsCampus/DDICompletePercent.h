//
//  DDIMessageList.h
//  老师助手
//
//  Created by yons on 13-12-31.
//  Copyright (c) 2013年 dandian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDIDataModel.h"

#import "UIImage+Scale.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "GTMBase64.h"
#import "OLGhostAlertView.h"
#import "NSString+URLEncoding.h"
#import "ASProgressPopUpView.h"
#import "DDIWenJuanDetail.h"
@interface DDICompletePercent : UITableViewController
{
    NSArray *titleArray;
    NSMutableArray *requestArray;
    NSString *savePath;
}

@end

