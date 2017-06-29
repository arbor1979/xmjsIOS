//
//  DDIHelpView.m
//  老师助手
//
//  Created by yons on 13-12-19.
//  Copyright (c) 2013年 dandian. All rights reserved.
//

#import "DDIHelpView.h"

static NSDate *loginDate;

@interface DDIHelpView ()

@end

@implementation DDIHelpView


+(NSDate *)getLoginDate
{
    return loginDate;
}
+(void)setLoginDate:(NSDate *)newDate
{
    loginDate=newDate;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    requestArray=[NSMutableArray array];
    savePath=[CommonFunc createPath:@"/webbrowers/"];
    self.webView.delegate=self;
    if(loginDate==nil)
        loginDate=[NSDate dateWithTimeIntervalSince1970:0];
    if(self.loginUrl!=nil)
    {
        NSArray *tempArray=[self.loginUrl componentsSeparatedByString:@"/"];
        baseUrl=[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/",[tempArray objectAtIndex:2]]];
        NSDate *expiredDate=[loginDate dateByAddingTimeInterval:20*60];
        if([expiredDate timeIntervalSinceNow]<0)
        {
            NSURL *url = [NSURL URLWithString: self.loginUrl];
            userDefaultes = [NSUserDefaults standardUserDefaults];
            NSString *userName = [userDefaultes stringForKey:@"用户名"];
            NSArray *tempArray=[userName componentsSeparatedByString:@"@"];
            userName=[tempArray objectAtIndex:0];
            NSString *password = [userDefaultes stringForKey:@"密码"];
            NSString *body = [NSString stringWithFormat: @"username=%@&password=%@", userName,password];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL: url];
            [request setHTTPMethod: @"POST"];
            
            [request setHTTPBody: [body dataUsingEncoding: NSUTF8StringEncoding]];
            
            [self.webView loadRequest: request];
            islogin=true;
            self.webView.hidden=YES;
        }
        else
        {
            self.webView.hidden=YES;
            //[self.webView loadHTMLString:self.htmlStr baseURL:nil];
            //[self performSelector:@selector(showWebView) withObject:nil afterDelay:1.0f];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL: baseUrl];
            [self.webView loadRequest: request];
        }
        

    }
    else
    {
        
        NSURL *url =[NSURL URLWithString:[self.urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSURLRequest *request =[NSURLRequest requestWithURL:url];
        [self.webView loadRequest:request];
        [self performSelector:@selector(modifyConstant) withObject:nil afterDelay:0.1];//延迟加载,执行
        
        
    }
    self.btnBack.enabled=NO;
    self.btnForward.enabled=NO;
    [self.btnBack setAction:@selector(backClick)];
    [self.btnForward setAction:@selector(forwardClick)];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    mediaFormat=[[NSArray alloc] initWithObjects:@"avi",@"mov",@"asf",@"mpg",@"mpeg",@"flv",@"mp4",@"wmv",@"3gp",@"rm",@"rmvb",@"mkv", nil];
}

-(void)backClick
{
    self.webView.hidden=YES;
    [self.webView goBack];
}
-(void)forwardClick
{
    self.webView.hidden=YES;
    [self.webView goForward];
}
-(void)modifyConstant
{
    self.bottomBarHeight.constant=0.0f;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*) reuqest navigationType:(UIWebViewNavigationType)navigationType;
/*当网页视图被指示载入内容而得到通知。应当返回YES，这样会进行加载。通过导航类型参数可以得到请求发起的原因，可以是以下任意值：
UIWebViewNavigationTypeLinkClicked
UIWebViewNavigationTypeFormSubmitted
UIWebViewNavigationTypeBackForward
UIWebViewNavigationTypeReload
UIWebViewNavigationTypeFormResubmitted
UIWebViewNavigationTypeOther
*/
{
    return true;
}
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    if(view)
        [view removeFromSuperview];
    view=[[UIView alloc]initWithFrame:self.webView.frame];
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
    NSLog(@"finish load:%@",[webView request].URL);
    if(self.htmlStr!=nil)
    {
        if(webView.canGoForward)
            self.btnForward.enabled=YES;
        else
            self.btnForward.enabled=NO;
        if(webView.canGoBack)
            self.btnBack.enabled=YES;
        else
            self.btnBack.enabled=NO;
        [webView stringByEvaluatingJavaScriptFromString:@"if(document.getElementById('region-main')) {document.body.innerHTML=document.getElementById('region-main').innerHTML;var tags=document.getElementsByTagName('a');for(var i=0;i<tags.length;i++){tags[i].innerHTML=decodeURIComponent(tags[i].innerHTML);tags[i].href=tags[i].href.replace('pluginfile.php', 'pluginfile_dandian.php?');}}"];
    }
    
    NSURL *curURL=webView.request.URL;
    NSURL *myURL=[NSURL URLWithString:[[NSString stringWithFormat:@"%@",baseUrl] stringByAppendingString:@"my/"]];
    if([curURL isEqual:baseUrl] || [curURL isEqual:myURL])
    {
        
        [self.webView loadHTMLString:self.htmlStr baseURL:nil];
        //[self performSelector:@selector(showWebView) withObject:nil afterDelay:1.0f];
    }
    else
    {
        [self.indicator stopAnimating];
        if(view)
            [view removeFromSuperview];
        self.webView.hidden=NO;
    }
    
    if(islogin)
    {
        islogin=false;
        loginDate=[NSDate date];
        
    }

    
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if([error code] == NSURLErrorCancelled)
    {
        return;
    }
    [self.indicator stopAnimating];
    if(view)
        [view removeFromSuperview];
    
    if (error.code == 102 && [error.domain isEqual:@"WebKitErrorDomain"])
    {
        NSURL *newUrl=[error.userInfo objectForKey:@"NSErrorFailingURLKey"];
        
        NSString *urlstr=newUrl.absoluteString;
        NSString *lastComponent = [urlstr pathExtension].lowercaseString;
        BOOL onlineVideo=false;
        for(NSString *item in mediaFormat)
        {
            if([item isEqualToString:lastComponent])
            {
                onlineVideo=true;
                break;
            }
        }
        if(onlineVideo)
        {
            NSString *urlscheme=[NSString stringWithFormat:@"aceplayer://%@",newUrl.absoluteString];
            newUrl=[NSURL URLWithString:urlscheme];
            BOOL hasApp=[[UIApplication sharedApplication] canOpenURL:newUrl];
            if(hasApp)
                [[UIApplication sharedApplication] openURL:newUrl];
            else
            {
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"播放此视频需安装aceplayer,是否安装？" delegate:self cancelButtonTitle:@"否"  otherButtonTitles:@"是", nil];
                [alert show];
                
                //[self createMPPlayerController:urlstr];
                    
            }
        }
        else
        {
            NSString *filename=[[CommonFunc getFileRealName:urlstr] URLDecodedString];
            NSString *path=[savePath stringByAppendingString:filename];
            NSURL *fileUrl=[NSURL fileURLWithPath:path];
            if([CommonFunc fileIfExist:path])
                [self openFile:fileUrl];
            else
                [self download:newUrl];
        }
        return;
    }
    NSString *msg=[NSString stringWithFormat:@"无法打开此页面，%@",error];
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"错误" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}
-(void)createMPPlayerController:(NSString *)sFileNamePath{
    MPMoviePlayerViewController *moviePlayer=[[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:sFileNamePath]];
    [moviePlayer.moviePlayer prepareToPlay];
    [self presentMoviePlayerViewControllerAnimated:moviePlayer];
    [moviePlayer.moviePlayer setControlStyle:MPMovieControlStyleFullscreen];
    [moviePlayer.view setBackgroundColor:[UIColor clearColor]];
    [moviePlayer.view setFrame:self.view.bounds];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieFinishedCallback:) name:MPMoviePlayerPlaybackDidFinishNotification object:moviePlayer.moviePlayer];
    
}
-(void)movieFinishedCallback:(NSNotification *)notify{
    MPMoviePlayerController *theMovie=[notify object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:theMovie];
    [self dismissMoviePlayerViewControllerAnimated];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==1)
    {
        NSURL *url=[NSURL URLWithString:@"https://itunes.apple.com/cn/app/aceplayer/id480881925?mt=8"];
        [[UIApplication sharedApplication] openURL:url];
    }

}
- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)interactionController
{
    return self;
}
-(UIView *)documentInteractionControllerViewForPreview:(UIDocumentInteractionController *)controller{
    
    return self.view;
}
- (CGRect)documentInteractionControllerRectForPreview:(UIDocumentInteractionController*)controller
{
    return self.view.frame;
}

- (void) download:(NSURL *)downUrl
{
    if(progress!=nil)
    {
        OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"上个下载还未完成"];
        [tipView show];
        return;
    }
    OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"此链接需要下载才能打开，已开始下载.."];
    [tipView show];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:downUrl];
    request.timeOutSeconds=300;
    progress=[[UIProgressView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 3)];
    [self.bottomBar addSubview:progress];
    NSMutableArray *buttons =[NSMutableArray arrayWithArray:self.bottomBar.items];
    btnStopDownload=[[UIBarButtonItem alloc] initWithTitle:@"停止下载" style:UIBarButtonItemStyleDone target:self action:@selector(stopDown)];
    [buttons addObject:btnStopDownload];
    [self.bottomBar setItems:buttons];
    request.username=@"下载文件";
    [request setDownloadProgressDelegate:progress];
    [request setDelegate:self];
    request.showAccurateProgress=YES;
    [requestArray addObject:request];
    request.timeOutSeconds=0;
    [request startAsynchronous];
}
-(void)stopDown
{
    for(ASIHTTPRequest *req in requestArray)
    {
        if([req.username isEqualToString:@"下载文件"])
        {
            [req clearDelegatesAndCancel];
            [self clearDownTag];
        }
    }
}
-(void)clearDownTag
{
    [progress removeFromSuperview];
    progress=nil;
    NSMutableArray *buttons =[NSMutableArray arrayWithArray:self.bottomBar.items];
    for(NSObject *item in buttons)
    {
        if([item isKindOfClass:[UIBarButtonItem class]])
        {
            UIBarButtonItem *btn=(UIBarButtonItem *)item;
            if([btn.title isEqualToString:@"停止下载"])
            {
                [buttons removeObject:item];
                [self.bottomBar setItems:buttons];
            }
        }
    }
}
- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSData *data = [request responseData];
    if([request.username isEqualToString:@"下载文件"])
    {

        if(data)
        {
            NSString *filename=[[CommonFunc getFileRealName:[NSString stringWithFormat:@"%@",request.url]] URLDecodedString];
            NSString *path=[savePath stringByAppendingString:filename];
            BOOL flag=[data writeToFile:path atomically:YES];
            [self clearDownTag];
            if(flag)
            {
                NSLog(@"下载成功:%@",filename);
                NSURL *fileUrl=[NSURL fileURLWithPath:path];
                [self openFile:fileUrl];
            }
            
        }
        
        
    }
}
-(void)openFile:(NSURL *)fileUrl
{
    //UISaveVideoAtPathToSavedPhotosAlbum(fileUrl.absoluteString, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
    
    NSString *exeName=[CommonFunc getFileExeName:fileUrl.absoluteString];
    NSURL *newUrl=fileUrl;
    NSString *filename=[[CommonFunc getFileRealName:fileUrl.absoluteString] URLDecodedString];
    NSString *srcPath=[savePath stringByAppendingString:filename];
    if([exeName.lowercaseString isEqualToString:@"flv"])
    {
        
        NSRange rang=[filename rangeOfString:exeName];
        NSString *newName=[NSString stringWithFormat:@"%@.mp4",[filename substringToIndex:rang.location-1 ]];
        NSString *toPath=[savePath stringByAppendingString:newName];
        if(![CommonFunc fileIfExist:toPath])
        {
            [CommonFunc copyFile:srcPath toFile:toPath];
   
        }
        newUrl=[NSURL URLWithString:toPath];
    }
    if([CommonFunc fileIfExist:srcPath])
    {
        documentInteractionController = [UIDocumentInteractionController                                                      interactionControllerWithURL:newUrl];
        [documentInteractionController setDelegate:self];
        bool b=[documentInteractionController presentPreviewAnimated:YES];
        if(!b)
        {
            OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"没有找到可用来打开此文件的程序"];
            [tipView show];
        }
    }
    else
    {
        OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"文件不存在"];
        [tipView show];
    }

}
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo: (void *)contextInfo {
    
    NSLog(@"%@",videoPath);
    
    NSLog(@"%@",error);
    
}
- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"请求失败:%@",[error localizedDescription]);
    if([request.username isEqualToString:@"下载课件"])
    {
        
        [self clearDownTag];
        if([requestArray containsObject:request])
            [requestArray removeObjectIdenticalTo:request];
        
    }
    NSString *errorStr;
    if([error.localizedDescription isEqualToString:@"The request was cancelled"])
        errorStr=@"操作被取消";
    else if([error.localizedDescription isEqualToString:@"The request timed out"])
        errorStr=@"请求超时";
    else
        errorStr=[error localizedDescription];
    OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"操作失败" message:errorStr];
    [tipView show];
    request=nil;
}
- (void)dealloc
{
    for(ASIHTTPRequest *req in requestArray)
    {
        [req setDownloadProgressDelegate:nil];
        [req clearDelegatesAndCancel];
    }
}

@end
