//
//  DDIHelpView.h
//  老师助手
//
//  Created by yons on 13-12-19.
//  Copyright (c) 2013年 dandian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OLGhostAlertView.h"
#import "ASIHTTPRequest.h"
#import "CommonFunc.h"
#import "NSString+URLEncoding.h"
#import <mediaPlayer/MediaPlayer.h>
@interface DDIHelpView : UIViewController<UIWebViewDelegate,UIDocumentInteractionControllerDelegate,UIAlertViewDelegate>
{
    UIView *view;
    NSUserDefaults *userDefaultes;
    BOOL islogin;
    NSURL *baseUrl;
    UIDocumentInteractionController *documentInteractionController;
    NSMutableArray *requestArray;
    NSString *savePath;
    UIProgressView *progress;
    UIBarButtonItem *btnStopDownload;
    NSArray *mediaFormat;
    MPMoviePlayerViewController *playerVc;
}
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (weak, nonatomic) IBOutlet UIToolbar *bottomBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnBack;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnForward;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bottomBarHeight;

@property (strong,nonatomic) NSString *urlStr;
@property (strong,nonatomic) NSString *htmlStr;
@property (strong,nonatomic) NSString *loginUrl;
+(NSDate *)getLoginDate;
+(void)setLoginDate:(NSDate *)newDate;
@end
