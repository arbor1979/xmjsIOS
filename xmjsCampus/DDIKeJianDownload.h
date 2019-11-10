//
//  DDIKeJianDownload.h
//  老师助手
//
//  Created by yons on 13-12-7.
//  Copyright (c) 2013年 dandian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "ASIFormDataRequest.h"
#import "NSString+URLEncoding.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "GTMBase64.h"
#import "UIImage+Scale.h"
#import "OLGhostAlertView.h"
#import "CommonFunc.h"
@interface DDIKeJianDownload : UITableViewController <UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,UIActionSheetDelegate,UIDocumentInteractionControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    UIBarButtonItem *rightBtn;
    OLGhostAlertView *alertTip;
    UIProgressView *uploadProgress;
  
}
@property (strong,nonatomic) NSString *className;
@property (strong,nonatomic) NSString *classNo;
@property (strong,nonatomic) NSString *teacherUserName;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic) UIDocumentInteractionController *documentInteractionController;
@property (strong,nonatomic) NSData *fileData;
@property(strong,nonatomic)NSString *extName;
@property(strong,nonatomic)NSString *uploadFileName;

@property(strong,nonatomic) NSMutableDictionary *kejianData;
@property(strong,nonatomic) NSMutableArray *allKeJianArray;
@property(strong,nonatomic) NSMutableArray *keJianArray; //本节课件数组

@property(strong,nonatomic) NSMutableDictionary *imageHead;
@property(strong,nonatomic) NSString *urlStr;
@property  NSInteger curRow;
@property(strong,nonatomic) NSString *savePath;
@property(strong,nonatomic) NSMutableArray *requestArray;
@property(strong,nonatomic) NSNumberFormatter *formatter;
@property(strong,nonatomic) NSFileManager *fileManager;
@property(strong,nonatomic) NSArray *allowFile;
@property(strong,nonatomic) ASIFormDataRequest *currentRequest;
@property(strong,nonatomic) UIImage *downImage;

-(void) deleteRemoteFile:(NSDictionary *)item;
-(void) updateDownloadCount:(NSDictionary *)item;
- (void) download;
-(void) uploadFile;
- (void)scrollToBottomAnimated:(BOOL)animated;
-(void)reloadKeJian;
-(void)ifFileExist;
@end
