//
//  DDIHelpView.h
//  老师助手
//
//  Created by yons on 13-12-19.
//  Copyright (c) 2013年 dandian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DDIHelpView : UIViewController<UIWebViewDelegate>
{
    UIView *view;
}
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

@property (strong,nonatomic) NSString *urlStr;
@end
