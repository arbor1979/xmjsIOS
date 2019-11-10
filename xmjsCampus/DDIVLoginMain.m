//
//  DDIViewController.m
//  TeacherAssistant
//
//  Created by yons on 13-11-7.
//  Copyright (c) 2013年 dandian. All rights reserved.
//

#import "DDIVLoginMain.h"
#import "GTMBase64.h"
#import "LFCGzipUtillity.h"

@interface DDIVLoginMain ()

@end

extern NSString *kInitURL;
extern NSString *kServiceURL ;
extern NSString *kYingXinURL;
extern NSString *kUserIndentify;
extern NSString *kStuState;
extern NSMutableDictionary *userInfoDic;
extern NSMutableDictionary *teacherInfoDic;
extern NSString *RecDevToken;
extern Boolean kIOS7;
extern int kUserType;
extern int kSchoolId;
extern DDIDataModel *datam;
@implementation DDIVLoginMain

- (void)viewDidLoad
{
    [super viewDidLoad];
    requestArray=[[NSMutableArray alloc] init];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    self.showVersion.text=[NSString stringWithFormat:@"%@ v%@",@"CopyRight©厦门技师",[infoDictionary objectForKey:@"CFBundleShortVersionString"]];
    
    remPass=[[QCheckBox alloc] initWithDelegate:self];
    //[remPass setFrame:CGRectMake(self.passWord.frame.origin.x-50,self.passWord.frame.origin.y+40,100,20)];
    remPass.frame=self.remPassLab.frame;
    
    [remPass setTitle:@"记住密码" forState:UIControlStateNormal];
    [remPass.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [self.view addSubview:remPass];
    
  
    userDefaultes = [NSUserDefaults standardUserDefaults];
    NSNumber *ifRemPass = [userDefaultes objectForKey:@"记住密码"];
    if(ifRemPass==nil || ifRemPass.intValue==0)
        remPass.checked=NO;
    else
        remPass.checked=YES;
    NSString *userName = [userDefaultes stringForKey:@"用户名"];
    NSString *password = [userDefaultes stringForKey:@"密码"];
    userListArray=[NSMutableArray arrayWithArray:[userDefaultes arrayForKey:@"保存用户列表"]];
    if(userName!=nil && userName.length>0 && remPass.checked)
    {
        self.userName.text=userName;
        self.passWord.text=password;
        [self loginClick:nil];
    }
   
    UIButton *downArrow=[[UIButton alloc]initWithFrame:CGRectMake(0 , 0, 28, 28)];
    [downArrow setTitle:@"▼" forState:UIControlStateNormal];
    downArrow.titleLabel.font=[UIFont systemFontOfSize:12];
    [downArrow addTarget:self action:@selector(showDropList) forControlEvents:UIControlEventTouchUpInside];
    //[self.userName addSubview:downArrow];
    self.userName.rightView=downArrow;
    self.userName.rightViewMode=UITextFieldViewModeAlways;
    
    if(!userListArray)
        userListArray=[NSMutableArray array];
    else
    {
        while (userListArray.count>5)
            [userListArray removeLastObject];
    }
}
-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    remPass.frame=self.remPassLab.frame;
}

-(void)showDropList
{
    if(userListArray.count==0) return;
    
    CGRect frame=self.loginImage.frame;
    
    popView=[[UIPopoverListView alloc]initWithFrame:CGRectMake(frame.origin.x, frame.origin.y+52, frame.size.width, 100)];
    popView.delegate=self;
    popView.datasource=self;
    popView.backgroundColor=[UIColor colorWithRed:140/255.0 green:211/255.0 blue:255/255.0 alpha:1.0];
    popView.listView.backgroundColor=[UIColor clearColor];
    
    [popView show:self.view];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES];
    if(!remPass.checked)
        self.passWord.text=@"";
    [super viewWillAppear:animated];
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
     
     CGRect rect=CGRectMake(0.0f,-150,width,height);
     
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
    [self.indicator startAnimating];
    self.loginButton.enabled=NO;
    [self postLogin];
    
}

//登陆函数
-(void) postLogin
{
    kUserIndentify=nil;
    NSURL *url = [NSURL URLWithString:[kInitURL stringByAppendingString:@"GetUserPwdIsRight.php?action=logincheck"]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    NSError *error;
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init ];
    [dic setObject:[NSString stringWithFormat:@"%@@xmjsxy.cn",self.userName.text] forKey:@"用户名"];
    [dic setObject:self.passWord.text forKey:@"密码"];
    NSNumber *timeStamp=[[NSNumber alloc] initWithLong:[[NSDate new] timeIntervalSince1970]];
    [dic setObject:timeStamp forKey:@"DATETIME"];
    request.username=@"登录验证";
    NSData *postData=[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
    postStr=[GTMBase64 base64StringBystring:postStr];
    [request setPostValue:postStr forKey:@"DATA"];
    [request setDelegate:self];
    [request setTimeOutSeconds:60];
    [request startAsynchronous];
    [requestArray addObject:request];
    
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    if([request.username isEqualToString:@"登录验证"])
    {
        NSLog(@"登录验证...");
        NSData *datas = [request responseData];
        NSString *dataStr=[[NSString alloc] initWithData:datas encoding:NSUTF8StringEncoding];
        dataStr=[GTMBase64 stringByBase64String:dataStr];
        datas = [dataStr dataUsingEncoding: NSUTF8StringEncoding];
        NSMutableDictionary* dict = [NSJSONSerialization JSONObjectWithData:datas options:NSJSONReadingAllowFragments error:nil];
        NSString * loginState=[dict objectForKey:@"登录状态"];
        if([loginState isEqualToString:@"登录成功"])
        {
            kUserIndentify=[dict objectForKey:@"用户较验码"];
            NSString *weiyima=[dict objectForKey:@"用户唯一码"];
            NSArray *tmpArray=[weiyima componentsSeparatedByString:@"_"];
            if([[tmpArray objectAtIndex:1] isEqualToString:@"老师"])
                kUserType=1;
            else if([[tmpArray objectAtIndex:1] isEqualToString:@"学生"])
                kUserType=2;
            else if ([[tmpArray objectAtIndex:1] isEqualToString:@"家长"])
                kUserType=3;
            kStuState=[dict objectForKey:@"学生状态"];
            kSchoolId=[[tmpArray objectAtIndex:6] intValue];
            kServiceURL=[NSString stringWithFormat:@"http://%@",[dict objectForKey:@"域名"]];
            kYingXinURL=[NSString stringWithFormat:@"http://%@",[[dict objectForKey:@"域名"] stringByReplacingOccurrencesOfString:@"/appserver/" withString:@"/NewStudent/mobiles/"]];
            teacherInfoDic=[dict mutableCopy];
            [teacherInfoDic setObject:[tmpArray objectAtIndex:1] forKey:@"用户类型"];
            
            [userDefaultes setObject:self.userName.text forKey:@"用户名"];
            [userDefaultes setObject:self.passWord.text forKey:@"密码"];
            if(remPass.checked)
                [userDefaultes setObject:[NSNumber numberWithInt:1] forKey:@"记住密码"];
            else
                [userDefaultes setObject:[NSNumber numberWithInt:0] forKey:@"记住密码"];
            BOOL flag=true;
            for(int i=0;i<userListArray.count;i++)
            {
                NSDictionary *item=[userListArray objectAtIndex:i];
                if([[item objectForKey:@"用户名"] isEqualToString:self.userName.text])
                {
                    flag=false;
                    break;
                }
            }
            if(flag && remPass.checked)
            {
                NSMutableDictionary *item=[[NSMutableDictionary alloc]init];
                [item setObject:self.userName.text forKey:@"用户名"];
                [item setObject:self.passWord.text forKey:@"密码"];
                [userListArray insertObject:item atIndex:0];
                [userDefaultes setObject:userListArray forKey:@"保存用户列表"];
            }
            
            
            NSString *userName=[teacherInfoDic objectForKey:@"姓名"];
            [datam initHostUser:weiyima hostName:userName];
            
            [self postUserInfo];
            DDIAppDelegate *app=(DDIAppDelegate *)[UIApplication sharedApplication].delegate;
            [app postUpdateTokenRequest];
            [app getMsgList];
            [app getAlbumMsg];
            if(kUserType==2)
                [app getGPS];
            /*
             for (id key in teacherInfoDic)
             {
             NSLog(@"key: %@ ,value: %@",key,[teacherInfoDic objectForKey:key]);
             }
             */
        }
        else if([loginState isEqualToString:@"新生"])
        {
            [userDefaultes setObject:[dict objectForKey:@"域名"] forKey:@"域名"];
            kYingXinURL=[NSString stringWithFormat:@"http://%@",[[dict objectForKey:@"域名"] stringByReplacingOccurrencesOfString:@"/appserver/" withString:@"/NewStudent/mobiles/"]];
            [self loginAsNewStudent];
        }
        else
        {
            
            if(loginState==nil)
            {
                loginState=[dict objectForKey:@"STATUS"];
                if(loginState==nil)
                    loginState=@"登录失败，未知错误";
            }
            //self.labelTip.text=loginState;
            //[NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(hideTip) userInfo:nil repeats:NO];
            OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:loginState message:nil];
            [tipView show];
            
            [self.indicator stopAnimating];
            self.loginButton.enabled=YES;
            
        }
    }
    else if([request.username isEqualToString:@"初始化课表"])
    {
        NSLog(@"初始化完成...");
        NSData *upzipData;
        bool suc=true;
        @try
        {
            
            NSData *datas = [request responseData];
            NSString *dataStr=[[NSString alloc] initWithData:datas encoding:NSUTF8StringEncoding];
            upzipData   = [[NSData alloc] initWithBase64EncodedString:dataStr options:0];
            //upzipData = [LFCGzipUtillity uncompressZippedData:_decodedData];
            
        }
        @catch (NSException *e) {
            NSLog(@"Exception: %@", e);
        }
        if(upzipData==nil)
        {
            //self.labelTip.text=@"获取课表数据失败";
            //[NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(hideTip) userInfo:nil repeats:NO];
            OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"获取课表数据失败" message:nil];
            [tipView show];
            suc=false;
        }
        else
        {
            NSMutableDictionary* dict = [NSJSONSerialization JSONObjectWithData:upzipData options:NSJSONReadingAllowFragments error:nil];
            userInfoDic=[dict mutableCopy];
            [userDefaultes setObject:[NSDate date] forKey:@"初始化时间"];
            
        }
        [self.indicator stopAnimating];
        self.loginButton.enabled=YES;
        if(suc)
            [self openMainTabbar];
        //[self performSegueWithIdentifier:@"mainMenu" sender:nil];
        /*
         for (id key in dict)
         {
         NSLog(@"key: %@ ,value: %@",key,[dict objectForKey:key]);
         }
         */
    }
    else  if([request.username isEqualToString:@"新生登录"])
    {
        NSLog(@"新生登录...");
        NSData *datas = [request responseData];
        NSString *dataStr=[[NSString alloc] initWithData:datas encoding:NSUTF8StringEncoding];
        dataStr=[GTMBase64 stringByBase64String:dataStr];
        NSData *data = [dataStr dataUsingEncoding: NSUTF8StringEncoding];
        NSMutableDictionary* dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSString *loginState=[dict objectForKey:@"结果"];
        
        if([loginState isEqualToString:@"成功"])
        {
            dict=[dict objectForKey:@"用户信息"];
            kUserIndentify=[dict objectForKey:@"用户较验码"];
            NSString *weiyima=[dict objectForKey:@"用户唯一码"];
            NSArray *tmpArray=[weiyima componentsSeparatedByString:@"_"];
            kUserType=2;
            kSchoolId=[[tmpArray objectAtIndex:6] intValue];
            teacherInfoDic=[dict mutableCopy];
            [teacherInfoDic setObject:[tmpArray objectAtIndex:1] forKey:@"用户类型"];
            kStuState=[teacherInfoDic objectForKey:@"学生状态"];
            [userDefaultes setObject:self.userName.text forKey:@"用户名"];
            [userDefaultes setObject:self.passWord.text forKey:@"密码"];
            if(remPass.checked)
                [userDefaultes setObject:[NSNumber numberWithInt:1] forKey:@"记住密码"];
            else
                [userDefaultes setObject:[NSNumber numberWithInt:0] forKey:@"记住密码"];
            BOOL flag=true;
            for(int i=0;i<userListArray.count;i++)
            {
                NSDictionary *item=[userListArray objectAtIndex:i];
                if([[item objectForKey:@"用户名"] isEqualToString:self.userName.text])
                {
                    flag=false;
                    break;
                }
            }
            if(flag && remPass.checked)
            {
                NSMutableDictionary *item=[[NSMutableDictionary alloc]init];
                [item setObject:self.userName.text forKey:@"用户名"];
                [item setObject:self.passWord.text forKey:@"密码"];
                [userListArray insertObject:item atIndex:0];
                [userDefaultes setObject:userListArray forKey:@"保存用户列表"];
            }
            
            NSString *userName=[teacherInfoDic objectForKey:@"姓名"];
            [datam initHostUser:weiyima hostName:userName];
            
            DDIAppDelegate *app=(DDIAppDelegate *)[UIApplication sharedApplication].delegate;
            [app postUpdateTokenRequest];
            [app getMsgList];
            [self openMainTabbar];
        }
        else
        {
            //self.labelTip.text=loginState;
            //[NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(hideTip) userInfo:nil repeats:NO];
            OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:loginState message:nil];
            [tipView show];
        }
        [self.indicator stopAnimating];
        self.loginButton.enabled=YES;
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{

    NSError *error = [request error];
    NSLog(@"%@",[error localizedDescription]);
    //self.labelTip.text=[NSString stringWithFormat:@"%@:%@",@"登录失败",[error localizedDescription]];
    //[NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(hideTip) userInfo:nil repeats:NO];
    OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@:%@",@"登录失败",[error localizedDescription]] message:nil];
    [tipView show];
    [self.indicator stopAnimating];
    self.loginButton.enabled=YES;
}

-(void)loginAsNewStudent
{
    NSURL *url = [NSURL URLWithString:[kYingXinURL stringByAppendingString:@"processcheck.php"]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    NSError *error;
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init ];
    [dic setObject:@"login" forKey:@"action"];
    [dic setObject:self.userName.text forKey:@"身份证"];
    [dic setObject:self.passWord.text forKey:@"密码"];
    [dic setObject:@"学生" forKey:@"用户类型"];
    request.username=@"新生登录";
    NSData *postData=[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
    postStr=[GTMBase64 base64StringBystring:postStr];
    [request setPostValue:postStr forKey:@"DATA"];
    [request setDelegate:self];
    [request setTimeOutSeconds:60];
    [request startAsynchronous];
    [requestArray addObject:request];
}
-(void)openMainTabbar
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    XHDrawerController *drawerController = [[XHDrawerController alloc] init];
    drawerController.springAnimationOn = YES;
    
    DDIMainMenu *leftSideDrawerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"leftMenu"];
    
    UINavigationController *centerSideDrawerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"mainView"];
    
    drawerController.leftViewController = leftSideDrawerViewController;
    drawerController.centerViewController = centerSideDrawerViewController;
    
    //[self presentViewController:drawerController animated:YES completion:nil];
    //[self.navigationController pushViewController:drawerController animated:YES];
    [UIApplication sharedApplication].keyWindow.rootViewController=drawerController;
}
//获取所有信息
-(void) postUserInfo
{
    NSString *weekbegin=[userDefaultes valueForKey:@"weekBegin"];
    if(weekbegin==nil)
    {
        weekbegin=@"0";
        [userDefaultes setValue:weekbegin forKey:@"weekBegin"];
    }
    NSURL *url = [NSURL URLWithString:[kServiceURL stringByAppendingString:@"appserver.php?action=initinfo"]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    NSError *error;
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init ];
    [dic setObject:kUserIndentify forKey:@"用户较验码"];
    [dic setObject:weekbegin forKey:@"周日为第一天"];
    request.username=@"初始化课表";
    NSData *postData=[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
    postStr=[GTMBase64 base64StringBystring:postStr];
    [request setPostValue:postStr forKey:@"DATA"];
    [request setDelegate:self];
    [request setTimeOutSeconds:60];
    [request startAsynchronous];
    [requestArray addObject:request];
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

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"mainMenu"])
    {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
        //[self.navigationController setNavigationBarHidden:NO];
        
        
    }
}

#pragma mark - UIPopoverListViewDelegate
-(CGFloat)popoverListView:(UIPopoverListView *)popoverListView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 35;
}
-(NSInteger)popoverListView:(UIPopoverListView *)popoverListView numberOfRowsInSection:(NSInteger)section
{
    return userListArray.count;
}
-(UITableViewCell *)popoverListView:(UIPopoverListView *)popoverListView cellForIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                    reuseIdentifier:identifier];
    
    cell.backgroundColor=[UIColor clearColor];
    NSDictionary *item=[userListArray objectAtIndex:indexPath.row];
    cell.textLabel.text=[item objectForKey:@"用户名"];
    UIImage *clearImage=[UIImage imageNamed:@"关闭"];
    UIButton *clearBtn=[[UIButton alloc]initWithFrame:CGRectMake(20, 0, 32, 32)];
    [clearBtn setImage:clearImage forState:UIControlStateNormal];
    //[clearBtn setBackgroundColor:[UIColor redColor]];
    cell.accessoryView=clearBtn;
    clearBtn.tag=indexPath.row;
    [clearBtn addTarget:self action:@selector(clearRow:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}
-(void)clearRow:(UIButton *)sender
{
    [userListArray removeObjectAtIndex:sender.tag];
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    [indexPaths addObject:[NSIndexPath indexPathForRow:sender.tag inSection:0]];
    
    [UIView animateWithDuration:.35 animations:^{
        [self->popView.listView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationLeft];
    } completion:^(BOOL finished) {
        if (finished) {
            [self->popView.listView reloadData];
        }
    }];
    [userDefaultes setObject:userListArray forKey:@"保存用户列表"];
}
-(void)popoverListView:(UIPopoverListView *)popoverListView didSelectIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *item=[userListArray objectAtIndex:indexPath.row];
    self.userName.text=[item objectForKey:@"用户名"];
    self.passWord.text=[item objectForKey:@"密码"];
    [self loginClick:nil];
}
-(void)dealloc
{
    for(ASIHTTPRequest *req in requestArray)
    {
        [req clearDelegatesAndCancel];
    }
}

@end
