//
//  DDIAlbumPersonal.h
//  掌上校园
//
//  Created by Mac on 15/1/19.
//  Copyright (c) 2015年 dandian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIFormDataRequest.h"
#import "GTMBase64.h"
#import "OLGhostAlertView.h"
#import "CommonFunc.h"
#import "UIImage+Scale.h"
#import "DDIAlbumScrollPage.h"
#import "EGORefreshTableHeaderView.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "DDIAlbumSend.h"
@interface DDIAlbumPersonal : UITableViewController<EGORefreshTableHeaderDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    NSMutableArray *imageList;
    NSMutableArray *requestArray;
    NSString *savepath;
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    UIBarButtonItem *cameraBtn;
}

@property(strong,nonatomic) NSString *userid;
@property(strong,nonatomic) NSString *username;
@end
