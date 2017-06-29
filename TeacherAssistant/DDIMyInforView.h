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
#import "NSString+URLEncoding.h"
@interface DDIMyInforView : UITableViewController<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,MLImageCropDelegate,UIAlertViewDelegate>
{
    NSDictionary *theTeacherDic;
    NSMutableArray *requestArray;
    NSArray *albumArray;
    NSInteger albumCount;
    NSString *savepath;
    OLGhostAlertView *tipView;
}
@property (strong,nonatomic) NSMutableArray *enableChangeArray;
@property (strong,nonatomic) NSMutableArray *disableChangeArray;

@property (strong,nonatomic) UIImage *headImage;

@property(strong,nonatomic) NSString *userWeiYi;

- (IBAction)showBigPic:(id)sender;
- (IBAction)changeHeadImage:(id)sender;
@end
