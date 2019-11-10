//
//  homeViewController.h
//  CollectionView
//
//  Created by d2space on 14-2-12.
//  Copyright (c) 2014年 D2space. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WaterF.h"
#import "LFCGzipUtillity.h"
#import "ASIFormDataRequest.h"
#import "GTMBase64.h"
#import "OLGhostAlertView.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "UIImage+Scale.h"
#import "DDIAlbumSend.h"
#import "DDIAlbumScrollPage.h"
@interface DDIWaterFallAlbum : UIViewController<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,WaterFPullDownDelegate,ReloadNewImageDelegate>
{
    UIActivityIndicatorView *aiv;
    UIBarButtonItem *cameraBtn;
    UISegmentedControl *segmentedControl;
    NSMutableArray *requestArray;
    UIButton *lbUnread;
    NSArray *msgList;
}

@property (nonatomic,strong) WaterF* waterfall;

@end
