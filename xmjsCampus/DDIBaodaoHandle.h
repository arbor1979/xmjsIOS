//
//  DDIMyInforView.h
//  老师助手
//
//  Created by yons on 13-12-20.
//  Copyright (c) 2013年 dandian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImage+Scale.h"
#import "ASIHTTPRequest.h"
#import "CommonFunc.h"
#import "ASIFormDataRequest.h"
#import "GTMBase64.h"
#import "DDIAlbumPersonal.h"
#import "OLGhostAlertView.h"
#import "MLImageCrop.h"
#import "DDIChengjiDetail.h"
#import "DDIChatView.h"
#import "DDISelectDorm.h"
#import <objc/runtime.h>
@interface DDIBaodaoHandle : UITableViewController<UINavigationControllerDelegate,UIAlertViewDelegate>
{
   
    NSMutableArray *requestArray;
    NSString *savepath;
    OLGhostAlertView *tipView;
    NSArray *groupArray;
    UIImage *headImage;
    NSString *userWeiYi;
    NSMutableDictionary *fieldsDic;
    NSMutableDictionary *completeDic;
    NSUserDefaults *userDefaultes;
    UIImage *imgYes;
    UIImage *imgNo;
    NSMutableDictionary *theStudentDic;
    NSString *userRole;
}
@property(strong,nonatomic) NSString *ID;
- (IBAction)showBigPic:(id)sender;
- (IBAction)callStudent:(id)sender;
- (IBAction)messageStudent:(id)sender;
- (IBAction)segValueChanged:(id)sender;
- (IBAction)stateChanged:(id)sender;
@end
