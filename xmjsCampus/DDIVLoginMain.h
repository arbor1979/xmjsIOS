//
//  DDIViewController.h
//  TeacherAssistant
//
//  Created by yons on 13-11-7.
//  Copyright (c) 2013年 dandian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSString+URLEncoding.h"
#import "DDIMainMenu.h"
#import "ASIFormDataRequest.h"
#import "DDIAppDelegate.h"
#import "UIImage+Scale.h"
#import "UIPopoverListView.h"
#import "DDIDataModel.h"
#import "UIPopoverListView.h"
#import "XHDrawerController.h"
#import "OLGhostAlertView.h"
#import "QCheckBox.h"
#import "ASIHTTPRequest.h"

@interface DDIVLoginMain : UIViewController <UITextFieldDelegate,UIAlertViewDelegate,UIPopoverListViewDelegate,UIPopoverListViewDataSource,QCheckBoxDelegate>
{
    NSMutableArray *userListArray;
    UIPopoverListView *popView;
    NSUserDefaults *userDefaultes;
    NSMutableArray *requestArray;
    QCheckBox *remPass;
}
@property (weak, nonatomic) IBOutlet UIImageView *loginImage;
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UITextField *passWord;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (weak, nonatomic) IBOutlet UILabel *showVersion;
@property (weak, nonatomic) IBOutlet UILabel *remPassLab;

- (IBAction)bgTouchDown:(id)sender;
- (IBAction)loginClick:(id)sender;

-(void) inputFrameShake;
-(void) postLogin;
-(void) postUserInfo;

@end
