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
#import "DDIBaodaoHandle.h"
#import <AVFoundation/AVFoundation.h>
#import "QRCodeController.h"
#import "DDIChengjiTitle.h"
#import "DDISelectStudent.h"

@interface DDIMyStatus : UITableViewController<UINavigationControllerDelegate,UIAlertViewDelegate>
{
    NSDictionary *theTeacherDic;
    NSMutableArray *requestArray;
    NSArray *albumArray;
    NSInteger albumCount;
    NSString *savepath;
    OLGhostAlertView *tipView;
    NSArray *groupArray;
    UIImage *headImage;
    NSString *userWeiYi;
    NSMutableDictionary *fieldsDic;
    NSDictionary *completeDic;
    NSUserDefaults *userDefaultes;
    NSString *oldPassword;
    UIImage *imgYes;
    UIImage *imgNo;
    NSArray *resultArray;
    UITextField *ed_NameOrNO;
    UIButton *btnSearch;
    UIBarButtonItem *rightBtn;
}
- (IBAction)searchStudent:(id)sender;
- (IBAction)scanCode:(id)sender;

- (IBAction)showBigPic:(id)sender;
@end
