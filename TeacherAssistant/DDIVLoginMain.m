//
//  DDIViewController.m
//  TeacherAssistant
//
//  Created by yons on 13-11-7.
//  Copyright (c) 2013年 dandian. All rights reserved.
//

#import "DDIVLoginMain.h"
#import "GTMBase64.h"

@interface DDIVLoginMain ()

@end

extern NSString *kInitURL;
extern NSString *kServiceURL ;
extern NSString *kUserIndentify;
extern NSMutableDictionary *userInfoDic;

@implementation DDIVLoginMain

- (void)viewDidLoad
{
    [super viewDidLoad];
    //设置背景图片
    self.bgImage.image=[UIImage imageNamed:@"LaunchImage"];
    [self.navigationController setNavigationBarHidden:YES];
  
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}
//文本框输入时VIEW上移，避免遮挡
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField

{
    
    NSTimeInterval animationDuration=0.30f;
    
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    
    [UIView setAnimationDuration:animationDuration];
    
    float width = self.view.frame.size.width;
    
    float height = self.view.frame.size.height;
    
    CGRect rect=CGRectMake(0.0f,-110,width,height);
    
    self.view.frame=rect;
    
    [UIView commitAnimations];
    
    return YES;
    
}
//文本框输入完毕，点return键盘隐藏，VIEW下移恢复原状
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
   
    if(textField.tag==1)
    {
        [self.passWord becomeFirstResponder];
    }
    else
    {
        [textField resignFirstResponder];
        [self resumeView];
        [self loginClick:textField];
    }
    return YES;
}
//恢复VIEW的原状
-(void)resumeView
{
    
    NSTimeInterval animationDuration=0.30f;
    
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    
    [UIView setAnimationDuration:animationDuration];
    
    float width = self.view.frame.size.width;
    
    float height = self.view.frame.size.height;
    
    CGRect rect=CGRectMake(0.0f,0.0f,width,height);
    
    self.view.frame=rect;
    
    [UIView commitAnimations];
    
}
//背景点击，隐藏键盘
- (IBAction)bgTouchDown:(id)sender {
    [self.userName resignFirstResponder];
    [self.passWord resignFirstResponder];
    [self resumeView];
}
//登陆按钮
- (IBAction)loginClick:(id)sender {

    self.userName.text =[self.userName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.passWord.text =[self.passWord.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(self.passWord.text==nil)
        self.passWord.text=@"";
    //断如果用户名没有输入则抖动提示
    if([self.userName.text length]==0)
    {
       
        [self inputFrameShake];
        return;
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self.indicator startAnimating];
    self.loginButton.enabled=NO;
    
    [self postLogin];
    
}

//登陆函数
-(void) postLogin
{
    NSURL *url = [NSURL URLWithString:[[kServiceURL stringByAppendingString:@"?action=logincheck"] URLEncodedString]];
	NSString *post = [NSString stringWithFormat:@"{\"用户名\":\"%@\",\"密码\":\"%@\"}", self.userName.text,self.passWord.text];
    post =[GTMBase64 base64StringBystring:post];
    post=[NSString stringWithFormat:@"DATA=%@",post];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:postData];
    
    NSURLConnection *connection = [[NSURLConnection alloc]
                                   initWithRequest:request delegate:self];
	
    if (connection) {
        _datas = [NSMutableData new];
    }
    
}

#pragma mark- NSURLConnection 回调方法
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_datas appendData:data];
}


-(void) connection:(NSURLConnection *)connection didFailWithError: (NSError *)error {
    
    NSLog(@"%@",[error localizedDescription]);
}

- (void) connectionDidFinishLoading: (NSURLConnection*) connection {
    NSLog(@"请求完成...");
    NSString* dataStr = [[NSString alloc] initWithData:_datas encoding:NSUTF8StringEncoding];
    dataStr=[GTMBase64 stringByBase64String:dataStr];
    NSData *data = [dataStr dataUsingEncoding: NSUTF8StringEncoding];
    NSMutableDictionary* dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    
   
    NSString *loginState=[dict objectForKey:@"登录状态"];
    if([loginState length]!=0)
    {
        if(![loginState isEqualToString:@"登录成功"])
        {
            self.labelTip.text=loginState;
            [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(hideTip) userInfo:nil repeats:NO];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            [self.indicator stopAnimating];
            self.loginButton.enabled=YES;
            
        }
        else
        {
            kUserIndentify=[dict objectForKey:@"用户较验码"];
            [self postUserInfo];
            
        }
    }
    else
    {
        userInfoDic=[dict mutableCopy];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [self.indicator stopAnimating];
        self.loginButton.enabled=YES;
        [self performSegueWithIdentifier:@"classSchedule" sender:nil];
        /*
        for (id key in dict)
        {
            NSLog(@"key: %@ ,value: %@",key,[dict objectForKey:key]);
        }
        */
    }
   
}

//获取所有信息
-(void) postUserInfo
{
    NSURL *url = [NSURL URLWithString:[[kServiceURL stringByAppendingString:@"?action=initinfo"] URLEncodedString]];
	NSString *post = [NSString stringWithFormat:@"{\"用户较验码\":\"%@\"}",kUserIndentify];
    post =[GTMBase64 base64StringBystring:post];
    post=[NSString stringWithFormat:@"DATA=%@",post];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:postData];
    
    NSURLConnection *connection = [[NSURLConnection alloc]
                                   initWithRequest:request delegate:self];
	
    if (connection) {
        _datas = [NSMutableData new];
    }
    
}

-(void)hideTip
{
    self.labelTip.text=@"";
    [self.userName becomeFirstResponder];
}
//登录框抖动
-(void) inputFrameShake
{
    

    CGAffineTransform moveRight = CGAffineTransformTranslate(CGAffineTransformIdentity, 10, 0);
    CGAffineTransform moveLeft = CGAffineTransformTranslate(CGAffineTransformIdentity, -10, 0);
    CGAffineTransform resetTransform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, 0);
    [UIImageView animateWithDuration:0.1 animations:^{
        self.loginImage.transform = moveLeft;
    } completion:^(BOOL finished) {
        [UIImageView animateWithDuration:0.1 animations:^{
            self.loginImage.transform = moveRight;
        } completion:^(BOOL finished) {
            [UIImageView animateWithDuration:0.1 animations:^{
                self.loginImage.transform = moveLeft;
            } completion:^(BOOL finished) {
                [UIImageView animateWithDuration:0.1 animations:^{
                    self.loginImage.transform = resetTransform;
                }];
            }];
            
        }];
    }];
 
}
- (IBAction)TestLogin:(id)sender {
    self.userName.text=@"admin";
    [self loginClick:sender];
}
@end
