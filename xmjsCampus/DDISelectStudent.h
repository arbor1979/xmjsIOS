//
//  DDILinkManGroup.h
//  老师助手
//
//  Created by yons on 14-1-13.
//  Copyright (c) 2014年 dandian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIFormDataRequest.h"
#import "GTMBase64.h"
#import "OLGhostAlertView.h"
#import "TQMultistageTableView.h"
#import "CommonFunc.h"
#import "UIImage+Scale.h"
#import "DDIChatView.h"
#import "pinyin.h"
#import "ASIFormDataRequest.h"
#import "LFCGzipUtillity.h"
#import "DDIDataModel.h"
#import "LinkMan.h"
#import "CommonFunc.h"
#import "UIPopoverListView.h"
#import "DDIBaodaoHandle.h"

@interface DDISelectStudent : UIViewController<TQTableViewDataSource, TQTableViewDelegate,UIPopoverListViewDataSource,UIPopoverListViewDelegate>
{
    UIImage *arrayRight;
    UIImage *arrayDown;
    
    NSString *savePath;
    
    NSMutableArray *requestArray;
    NSArray *groupList;
    OLGhostAlertView *alertTip;
    NSArray *groupArray;
    NSMutableDictionary *friendDic;
    NSMutableDictionary *headViewArray;
    NSDictionary *baodaoNumObj;
    NSArray *bedList;
    UIPopoverListView *poplistview;
}

@property (nonatomic, strong) TQMultistageTableView *mTableView;
@property (nonatomic, strong) NSString *ID;
@property (nonatomic, strong) NSString *sex;

@end
