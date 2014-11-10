//
//  DDIHelpView.m
//  老师助手
//
//  Created by yons on 13-12-19.
//  Copyright (c) 2013年 dandian. All rights reserved.
//

#import "DDIHelpView.h"

@interface DDIHelpView ()

@end

@implementation DDIHelpView



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSURL *url =[NSURL URLWithString:[self.urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURLRequest *request =[NSURLRequest requestWithURL:url];
    self.webView.delegate=self;
    [self.webView loadRequest:request];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    if(view)
        [view removeFromSuperview];
    view=[[UIView alloc]initWithFrame:self.view.frame];
    [view setTag:108];
    [view setBackgroundColor:[UIColor blackColor]];
    [view setAlpha:0.5];
    [self.view addSubview:view];
    [self.indicator startAnimating];
    [self.view bringSubviewToFront:self.indicator];
    NSLog(@"start load");
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.indicator stopAnimating];
    if(view)
        [view removeFromSuperview];
    
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.indicator stopAnimating];
    if(view)
        [view removeFromSuperview];
    NSString *msg=[NSString stringWithFormat:@"无法打开此页面，%@",error];
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"错误" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}
@end
