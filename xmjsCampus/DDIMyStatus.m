//
//  DDIMyInforView.m
//  老师助手
//
//  Created by yons on 13-12-20.
//  Copyright (c) 2013年 dandian. All rights reserved.
//

#import "DDIMyStatus.h"
extern NSMutableDictionary *teacherInfoDic;//老师数据
extern NSDictionary *LinkMandic;
extern NSString *kUserIndentify;
extern Boolean kIOS7;
extern int kUserType;
extern NSString *kInitURL;
extern NSString *kStuState;
extern NSString *kYingXinURL;
@interface DDIMyInforView ()

@end

@implementation DDIMyStatus

- (void)viewDidLoad
{
    [super viewDidLoad];
    savepath=[CommonFunc createPath:@"/utils/"];
    rightBtn= [[UIBarButtonItem alloc] initWithTitle:@"刷新" style:UIBarButtonItemStylePlain target:self action:@selector(getPersonalInfo)];
    requestArray=[[NSMutableArray alloc] init];
    /*
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0, 29.0, 29.0)];
    [backBtn setTitle:@"" forState:UIControlStateNormal];
    [backBtn setBackgroundImage:[UIImage imageNamed:@"relogin"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(mainMenuAction) forControlEvents:UIControlEventTouchUpInside];
    backBtn.contentHorizontalAlignment =UIControlContentHorizontalAlignmentLeft;
    UIBarButtonItem *backBarBtn = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.parentViewController.navigationItem.leftBarButtonItem=backBarBtn;
     */
    
    
    userDefaultes = [NSUserDefaults standardUserDefaults];
    [self getPersonalInfo];
    if(theTeacherDic==nil)
    {
        tipView = [[OLGhostAlertView alloc] initWithIndicator:@"加载中..." timeout:0 dismissible:NO];
        [tipView showInView:self.view];
    }
    imgYes=[UIImage imageNamed:@"complete"];
    imgNo=[UIImage imageNamed:@"uncomplete"];
    self.tableView.contentInset=UIEdgeInsetsMake(0, 0, 30, 0);
    
    userWeiYi=[teacherInfoDic objectForKey:@"用户唯一码"];
    [self reloadHeadImage];
}
-(void)viewDidAppear:(BOOL)animated
{
    self.parentViewController.navigationItem.title=@"新生";
    self.parentViewController.navigationItem.rightBarButtonItem=rightBtn;
    [super viewDidAppear:animated];
}
-(void)mainMenuAction
{
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    [defaults setObject:@"" forKey:@"密码"];
    [defaults setObject:@"" forKey:@"用户较验码"];
    [self.navigationController popToRootViewControllerAnimated:YES];
}
-(void)getPersonalInfo
{
    NSURL *url = [NSURL URLWithString:[kYingXinURL stringByAppendingString:@"processcheck.php"]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    NSError *error;
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init ];
    [dic setObject:kUserIndentify forKey:@"用户较验码"];
    [dic setObject:[teacherInfoDic objectForKey:@"编号"] forKey:@"编号"];
    [dic setObject:[teacherInfoDic objectForKey:@"用户类型"] forKey:@"用户类型"];
    [dic setObject:@"status" forKey:@"action"];
    NSNumber *timeStamp=[[NSNumber alloc] initWithLong:[[NSDate new] timeIntervalSince1970]];
    [dic setObject:timeStamp forKey:@"DATETIME"];
    request.username=@"录取状态";
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
    if([request.username isEqualToString:@"录取状态"])
    {
        if(tipView)
            [tipView removeFromSuperview];
        NSData *data = [request responseData];
        //NSString* dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        data   = [[NSData alloc] initWithBase64EncodedData:data options:0];
        id res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (res && [res isKindOfClass:[NSDictionary class]])
        {
            if([[res objectForKey:@"结果"] isEqualToString:@"成功"])
            {
                
                theTeacherDic=[NSMutableDictionary dictionaryWithDictionary:[res objectForKey:@"用户信息"]];
                //teacherInfoDic=[theTeacherDic copy];
                
                NSString *tmpStr=[res objectForKey:@"表格分组"];
                NSMutableArray *mArray=[NSMutableArray arrayWithArray:[tmpStr componentsSeparatedByString:@","]];
                if(kUserType==1 && ![[teacherInfoDic objectForKey:@"学生状态"] isEqualToString:@"接站员"])
                {
                    [mArray insertObject:@"新生报到" atIndex:0];
                }
                groupArray=mArray;
                fieldsDic=[NSMutableDictionary dictionary];
                for(NSString *item in groupArray)
                {
                    if([res objectForKey:item])
                        [fieldsDic setObject:[res objectForKey:item] forKey:item];
                }
                completeDic=[res objectForKey:@"完成情况"];
                
                [self.tableView reloadData];
                if(kUserType==2)
                {
                    NSString *pwd=[userDefaultes objectForKey:@"密码"];
                    NSString *defpwd=[theTeacherDic objectForKey:@"默认口令"];
                    NSString *tipdate=[userDefaultes objectForKey:@"更改密码提示"];
                    if([pwd isEqualToString:defpwd] && ![tipdate isEqualToString:[CommonFunc stringFromDateShort:[NSDate date]]])
                    {
                        UIAlertView *customAlertView = [[UIAlertView alloc] initWithTitle:@"您的密码是初始密码，是否更改密码？" message:nil delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil,nil];
                        customAlertView.tag=5;
                        [customAlertView show];
                        [userDefaultes setObject:[CommonFunc stringFromDateShort:[NSDate date]] forKey:@"更改密码提示"];
                    }
                }
                
            }
        }
    }
    else if([request.username isEqualToString:@"更改密码"])
    {
        NSData *datas = [request responseData];
        NSString *dataStr=[[NSString alloc] initWithData:datas encoding:NSUTF8StringEncoding];
        dataStr=[GTMBase64 stringByBase64String:dataStr];
        datas = [dataStr dataUsingEncoding: NSUTF8StringEncoding];
        NSMutableDictionary* dict = [NSJSONSerialization JSONObjectWithData:datas options:NSJSONReadingAllowFragments error:nil];
        NSString * status=[dict objectForKey:@"结果"];
        if([status isEqualToString:@"成功"])
        {
            NSDictionary *params=request.userInfo;
            [userDefaultes setObject:[params objectForKey:@"密码"] forKey:@"密码"];
            kUserIndentify=[[dict objectForKey:@"用户资料"] objectForKey:@"用户较验码"];
            tipView = [[OLGhostAlertView alloc] initWithTitle:@"密码修改成功！"];
            [tipView show];
        }
        else
        {
            tipView = [[OLGhostAlertView alloc] initWithTitle:[@"失败：" stringByAppendingString:status]];
            [tipView show];
        }
    }
    else if([request.username isEqualToString:@"查询学生"])
    {
        if(tipView)
            [tipView removeFromSuperview];
        if(btnSearch)
            btnSearch.enabled=true;
        NSData *data = [request responseData];
        //NSString* dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        data   = [[NSData alloc] initWithBase64EncodedData:data options:0];
        id res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (res && [res isKindOfClass:[NSDictionary class]])
        {
            if([[res objectForKey:@"结果"] isEqualToString:@"成功"])
            {
                resultArray=[res objectForKey:@"用户数组"];
                if(resultArray)
                {
                    if(resultArray.count>1)
                    {
                        
                        UIAlertView*alert = [[UIAlertView alloc]initWithTitle:@"请选择一个学生"
                                                                      message:nil
                                                                     delegate:self
                                                            cancelButtonTitle:@"取消"
                                                            otherButtonTitles:nil,nil];
                        for(NSDictionary *item in resultArray)
                        {
                            NSString *btnTitle=[NSString stringWithFormat:@"%@ %@",[item objectForKey:@"身份证号"],[item objectForKey:@"姓名"]];
                            [alert addButtonWithTitle:btnTitle];
                        }
                        alert.tag=3;
                        [alert show];
                    }
                    else
                    {
                        NSDictionary *item=[resultArray objectAtIndex:0];
                        [self gotoBaodaoHandle:[item objectForKey:@"编号"]];
                        
                    }
                }
            }
            else
            {
                tipView = [[OLGhostAlertView alloc] initWithTitle:[res objectForKey:@"结果"]];
                [tipView show];
            }
        }
    }
    else if([request.username isEqualToString:@"入读确认"])
    {
        NSData *datas = [request responseData];
        NSString *dataStr=[[NSString alloc] initWithData:datas encoding:NSUTF8StringEncoding];
        dataStr=[GTMBase64 stringByBase64String:dataStr];
        datas = [dataStr dataUsingEncoding: NSUTF8StringEncoding];
        NSMutableDictionary* dict = [NSJSONSerialization JSONObjectWithData:datas options:NSJSONReadingAllowFragments error:nil];
        NSString * status=[dict objectForKey:@"结果"];
        if([status isEqualToString:@"成功"])
        {
            
            [theTeacherDic setValue:[dict objectForKey:@"预报到"] forKey:@"预报到"];
            [theTeacherDic setValue:[dict objectForKey:@"确认入读"] forKey:@"确认入读"];
            
            [self.tableView reloadData];
            if ([[dict objectForKey:@"预报到"] isEqualToString:@"是"]) {
                NSString *urlStr=[kYingXinURL stringByAppendingString:[dict objectForKey:@"接口地址"]];
                DDIWenJuanDetail *detail=[self.storyboard instantiateViewControllerWithIdentifier:@"wenjuanDetail"];
                
                detail.title=[dict objectForKey:@"标题"];
                detail.interfaceUrl=urlStr;
                detail.examStatus=@"进行中";
                detail.key=-1;
                detail.parentTitleArray=nil;
                [self.navigationController pushViewController:detail animated:YES];
            }
        }
        else
        {
            tipView = [[OLGhostAlertView alloc] initWithTitle:[@"失败：" stringByAppendingString:status]];
            [tipView show];
        }
    }
    else
    {
        NSData *datas = [request responseData];
        headImage=[[UIImage alloc]initWithData:datas];
        if(headImage!=nil)
        {
            NSString *path=[CommonFunc getImageSavePath:request.username ifexist:NO];
            [datas writeToFile:path atomically:YES];
          
            NSIndexPath *indexPath=[NSIndexPath indexPathForRow:0 inSection:0];
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];

        }
    }
}

-(void)gotoBaodaoHandle:(NSString *)ID
{
    
    DDIBaodaoHandle *detail=[self.storyboard instantiateViewControllerWithIdentifier:@"baodaoHandle"];
    detail.ID=ID;
    [self.navigationController pushViewController:detail animated:YES];
}
- (void)requestFailed:(ASIHTTPRequest *)request
{
    if(tipView)
        [tipView removeFromSuperview];
    NSError *error = [request error];
    NSLog(@"请求失败:%@",[error localizedDescription]);
    OLGhostAlertView *tipV = [[OLGhostAlertView alloc] initWithTitle:[error localizedDescription]];
    [tipV showInView:self.view];
    if([request.username isEqualToString:@"查询学生"])
        btnSearch.enabled=true;
}
-(void)dealloc
{
    for(ASIHTTPRequest *req in requestArray)
    {
        [req clearDelegatesAndCancel];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    
    return groupArray.count+1;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section==0)
        return @"";
    else
    {
        NSString *tmpStr=[groupArray objectAtIndex:section-1];
        return tmpStr;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    if(section==0)
        return 1;
    else
    {
        if(kUserType==1 && section==1 && ![[teacherInfoDic objectForKey:@"学生状态"] isEqualToString:@"接站员"])
        {
            return 1;
        }
        else
        {
            NSString *tmpStr=[groupArray objectAtIndex:section-1];
            NSString *itemStr=[fieldsDic objectForKey:tmpStr];
            NSArray *itemArray=[itemStr componentsSeparatedByString:@","];
            return  itemArray.count;
        }
        
    }
    
        
}
-(void)reloadHeadImage
{
    NSString *urlStr=[teacherInfoDic objectForKey:@"用户头像"];
    NSURL *url = [NSURL URLWithString:urlStr];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    request.username=userWeiYi;
    [request setDelegate:self];
    [request startAsynchronous];
    [requestArray addObject:request];
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=nil;
    if(indexPath.section==0)
    {
        static NSString *CellIdentifier1 = @"Cell1";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1 forIndexPath:indexPath];
        UIButton *headBtn=(UIButton *)[cell viewWithTag:11];
        [headBtn.layer setMasksToBounds:YES];
        [headBtn.layer setCornerRadius:5.0]; //设置矩形四个圆角半径
 
        NSString *path=[CommonFunc getImageSavePath:userWeiYi ifexist:YES];
        if(path)
        {
            headImage=[UIImage imageWithContentsOfFile:path];
            UIImageView *innerImageView=(UIImageView *)[headBtn viewWithTag:1001];
            if(innerImageView==nil)
            {
                CGRect rect=headBtn.frame;
                rect.origin.x=0;
                rect.origin.y=0;
                float rate=headImage.size.width/headImage.size.height;
                rect.size.width=rect.size.height*rate;
                innerImageView=[[UIImageView alloc] initWithFrame:rect];
                if (headBtn.subviews.count>0) {
                    for (UIView *subView in headBtn.subviews) {
                        if([subView isKindOfClass:[UIImageView class]])
                            [subView removeFromSuperview];
                    }
                }
                [headBtn addSubview:innerImageView];
            }
            innerImageView.image=headImage;
            
            //[headBtn setImage:headImage forState:UIControlStateNormal];

        }
            
        

        
        UILabel *realName=(UILabel *)[cell viewWithTag:12];
        realName.text=[teacherInfoDic objectForKey:@"姓名"];
        UILabel *usertype=(UILabel *)[cell viewWithTag:13];
        usertype.text=[teacherInfoDic objectForKey:@"学生状态"];
        UIButton *changePwdBtn=(UIButton *) [cell viewWithTag:14];
        UIButton *noticeConfirmBtn=(UIButton *) [cell viewWithTag:15];
        if(kUserType==2)
        {
            changePwdBtn.hidden=NO;
            noticeConfirmBtn.hidden=NO;
            
            [changePwdBtn setTitle:@"修改密码" forState:UIControlStateNormal];
            [changePwdBtn addTarget:self action:@selector(changePwd) forControlEvents:UIControlEventTouchUpInside];
            [noticeConfirmBtn setTitle:@"入读确认" forState:UIControlStateNormal];
            [noticeConfirmBtn addTarget:self action:@selector(noticeConfirm) forControlEvents:UIControlEventTouchUpInside];
            NSString *yubaodao=[theTeacherDic objectForKey:@"预报到"];
            if([yubaodao isEqualToString:@"是"])
            {
                [noticeConfirmBtn setTitle:@"已确认入读" forState:UIControlStateNormal];
                [noticeConfirmBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
            }
            else if([yubaodao isEqualToString:@"否"])
            {
                [noticeConfirmBtn setTitle:@"已放弃入读" forState:UIControlStateNormal];
                [noticeConfirmBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            }
                
        }
        else
        {
            changePwdBtn.hidden=YES;
            noticeConfirmBtn.hidden=YES;
        }
    }
    else
    {
        if(kUserType==1 && indexPath.section==1 && ![[teacherInfoDic objectForKey:@"学生状态"] isEqualToString:@"接站员"])
        {
            static NSString *CellIdentifier3 = @"cell3";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier3];
            ed_NameOrNO=[cell viewWithTag:11];
        }
        else
        {
            static NSString *CellIdentifier2 = @"cell2";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
            UILabel *title=nil;
            UILabel *detail=nil;
           
            [cell.detailTextLabel setNumberOfLines:0];
            cell.detailTextLabel.font=[UIFont systemFontOfSize:15];
            
            title=cell.textLabel;
            detail=cell.detailTextLabel;
            NSString *tmpStr=[groupArray objectAtIndex:indexPath.section-1];
            NSString *itemStr=[fieldsDic objectForKey:tmpStr];
            NSArray *itemArray=[itemStr componentsSeparatedByString:@","];
            itemStr=[itemArray objectAtIndex:indexPath.row];
            title.text=itemStr;
            detail.text=[NSString stringWithFormat:@"%@",[theTeacherDic objectForKey:itemStr]];
            NSNumber *completeFlag=[completeDic objectForKey:itemStr];
            UIImageView *imv=[cell viewWithTag:11];
            if(imv)
                [imv removeFromSuperview];
            
            if(completeFlag)
            {
                
                    CGRect frame=CGRectMake([UIScreen mainScreen].bounds.size.width-70, 10, 60, 22);
                    imv=[[UIImageView alloc]initWithFrame:frame];
                    imv.tag=11;
                
                if(completeFlag.intValue==1)
                    imv.image=imgYes;
                else
                    imv.image=imgNo;
                [cell addSubview:imv];
            }
            UIButton *btn=[cell viewWithTag:12];
            if(!btn)
            {
                CGRect frame=CGRectMake([UIScreen mainScreen].bounds.size.width-70, 10, 60, 22);
                btn=[[UIButton alloc]initWithFrame:frame];
                btn.titleLabel.font=[UIFont systemFontOfSize:15];
                btn.tag=12;
                [btn setTitleColor:[btn tintColor] forState:UIControlStateNormal];
            }
            else
                [btn removeFromSuperview];
            if([itemStr isEqualToString:@"通知书EMS"] && ![detail.text isEqual:@"未发出"])
            {
                [btn setTitle:@"追踪" forState:UIControlStateNormal];
                [btn addTarget:self action:@selector(traceEMS) forControlEvents:UIControlEventTouchUpInside];
                [cell addSubview:btn];
            }
            if([itemStr isEqualToString:@"需接站人数"] && [theTeacherDic objectForKey:@"需接站人数"])
            {
                [btn setTitle:@"查看" forState:UIControlStateNormal];
                [btn addTarget:self action:@selector(viewJieZhan) forControlEvents:UIControlEventTouchUpInside];
                [cell addSubview:btn];
            }
        }
        /*
        CGSize size = [detail.text sizeWithFont:detail.font constrainedToSize:CGSizeMake(220, 1000) lineBreakMode:NSLineBreakByWordWrapping];
        
        [detail setFrame:CGRectMake(detail.frame.origin.x, detail.frame.origin.y, size.width, size.height)];
        [detail sizeToFit];
         */
    }
    
    return cell;
}
-(void)traceEMS
{
    DDIChengjiDetail *controller=[self.storyboard instantiateViewControllerWithIdentifier:@"chengjiDetail"];
    controller.interfaceUrl=[NSString stringWithFormat:@"%@InterfaceStudent/XUESHENG-CHENGJI-Student-EMS.php?emsno=%@",kInitURL,[theTeacherDic objectForKey:@"通知书EMS"]];
    //controller.htmlStr=[NSString stringWithFormat:@"<script>location.href='%@';</script>",[item objectForKey:@"接口地址"]];
    [self.navigationController pushViewController:controller animated:YES];
}
-(void)viewJieZhan
{
    DDIChengjiTitle *controller=[self.storyboard instantiateViewControllerWithIdentifier:@"chengjiMain"];
    controller.interfaceUrl=@"XUESHENG-CHENGJI-JieZhan.php";
    [self.navigationController pushViewController:controller animated:YES];
}
-(void)noticeConfirm
{
    if([[theTeacherDic objectForKey:@"组长审核通过"] isEqualToString:@"已审核"] && ![[theTeacherDic objectForKey:@"预报到"] isEqualToString:@""])
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                       message:@"您的资料已审核，无法再修改此项"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action){}];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"入读确认"
                                                                   message:@"是否确认入读本校？如选入读，需在随后的页面完成个人资料，如选放弃，需要到招生办申请退档"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"确认入读" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action){
                                                              if(![[self->theTeacherDic objectForKey:@"预报到"] isEqualToString:@"是"])
            [self letterConfirm:@"是"];
    }];
    UIAlertAction* giveupAction = [UIAlertAction actionWithTitle:@"放弃入读" style:UIAlertActionStyleDestructive
                                                          handler:^(UIAlertAction * action) {
                                                              if(![[self->theTeacherDic objectForKey:@"预报到"] isEqualToString:@"否"])
              [self letterConfirm:@"否"];
    }];
    
    [alert addAction:defaultAction];
    [alert addAction:giveupAction];
    [self presentViewController:alert animated:YES completion:nil];
}
-(void)changePwd
{
    UIAlertView *customAlertView = [[UIAlertView alloc] initWithTitle:@"请输入旧密码" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil,nil];
    [customAlertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    
    UITextField *oldPwdField = [customAlertView textFieldAtIndex:0];
    [oldPwdField setSecureTextEntry:YES];
    oldPwdField.placeholder = @"请输入旧密码";
    
    customAlertView.tag=1;
    [customAlertView show];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(alertView.tag==1)
    {
        if (buttonIndex == alertView.firstOtherButtonIndex)
        {
            UITextField *nameField = [alertView textFieldAtIndex:0];
            oldPassword=nameField.text;
            if(oldPassword==nil)
            {
                tipView = [[OLGhostAlertView alloc] initWithTitle:@"请输入旧密码"];
                [tipView show];
                return;
            }
            UIAlertView *customAlertView = [[UIAlertView alloc] initWithTitle:@"请输入新密码" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil,nil];
            [customAlertView setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
            nameField = [customAlertView textFieldAtIndex:0];
            [nameField setSecureTextEntry:YES];
            nameField.placeholder = @"请输入新密码";
            
            UITextField *urlField = [customAlertView textFieldAtIndex:1];
            [urlField setSecureTextEntry:YES];
            urlField.placeholder = @"请再次输入新密码";
            customAlertView.tag=2;
            [customAlertView show];
        }
    }
    else if(alertView.tag==2)
    {
        if (buttonIndex == alertView.firstOtherButtonIndex)
        {
            
            UITextField *nameField = [alertView textFieldAtIndex:0];
            NSString *newPassword=nameField.text;
            UITextField *urlField = [alertView textFieldAtIndex:1];
            NSString *comfirmPassword=urlField.text;
            
            if(![newPassword isEqualToString:comfirmPassword])
            {
                tipView = [[OLGhostAlertView alloc] initWithTitle:@"两次输入密码不一致"];
                [tipView show];
            }
            else
            {
                if([newPassword trimWhitespace].length==0)
                {
                    tipView = [[OLGhostAlertView alloc] initWithTitle:@"密码不能为空"];
                    [tipView show];
                }
                else
                {
                    
                    
                    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init];
                    [dic setObject:kUserIndentify forKey:@"用户较验码"];
                    NSNumber *timeStamp=[[NSNumber alloc] initWithLong:[[NSDate new] timeIntervalSince1970]];
                    [dic setObject:timeStamp forKey:@"DATETIME"];
                    [dic setObject:@"changepwd"  forKey:@"action"];
                    [dic setObject:oldPassword forKey:@"旧密码"];
                    [dic setObject:newPassword forKey:@"密码"];
                    
                    NSURL *url = [NSURL URLWithString:[kYingXinURL stringByAppendingString:@"processcheck.php"]];
                    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
                    NSError *error;
                    NSData *postData=[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
                    NSString *postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
                    postStr=[GTMBase64 base64StringBystring:postStr];
                    [request setPostValue:postStr forKey:@"DATA"];
                    [request setDelegate:self];
                    request.userInfo=dic;
                    request.username=@"更改密码";
                    [requestArray addObject:request];
                    [request startAsynchronous];
                }
            }
        }
    }
    else if(alertView.tag==3)
    {
        if(resultArray && resultArray.count>=buttonIndex)
        {
            NSDictionary *item=[resultArray objectAtIndex:buttonIndex-1];
            [self gotoBaodaoHandle:[item objectForKey:@"编号"]];
        }
    }
    else if(alertView.tag==5)
    {
        if (buttonIndex == alertView.firstOtherButtonIndex)
        {
            [self changePwd];
        }
    }
    
}
-(void)letterConfirm:(NSString *)letterNo
{
    
    NSURL *url = [NSURL URLWithString:[kYingXinURL stringByAppendingString:@"processcheck.php"]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    NSError *error;
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init ];
    [dic setObject:kUserIndentify forKey:@"用户较验码"];
    [dic setObject:[teacherInfoDic objectForKey:@"编号"] forKey:@"编号"];
    [dic setObject:@"Android" forKey:@"client"];
    [dic setObject:@"enterConfirm" forKey:@"action"];
    [dic setObject:letterNo forKey:@"入读确认"];
    request.username=@"入读确认";
    NSData *postData=[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
    postStr=[GTMBase64 base64StringBystring:postStr];
    [request setPostValue:postStr forKey:@"DATA"];
    [request setDelegate:self];
    [request setTimeOutSeconds:60];
    [request startAsynchronous];
    [requestArray addObject:request];
    
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section==0)
        return 1;
    else
        return 18;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==0)
    {
        return 95;
    }
    else
    {
        if(kUserType==1 && indexPath.section==1 && ![[teacherInfoDic objectForKey:@"学生状态"] isEqualToString:@"接站员"])
            return 91;
        else
        {
            NSString *tmpStr=[groupArray objectAtIndex:indexPath.section-1];
            NSString *itemStr=[fieldsDic objectForKey:tmpStr];
            NSArray *itemArray=[itemStr componentsSeparatedByString:@","];
            itemStr=[itemArray objectAtIndex:indexPath.row];
            NSString *detailtext=[NSString stringWithFormat:@"%@",[theTeacherDic objectForKey:itemStr]];
            
            //CGSize size = [detailtext sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(200, 1000) lineBreakMode:NSLineBreakByCharWrapping];
            
            NSStringDrawingOptions opts = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
            NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
            [style setLineBreakMode:NSLineBreakByCharWrapping];
            NSDictionary *attributes = @{ NSFontAttributeName : [UIFont systemFontOfSize:15], NSParagraphStyleAttributeName : style };
            CGRect rect=[detailtext boundingRectWithSize:CGSizeMake(200, 1000) options:opts attributes:attributes context:nil];
            CGSize size = rect.size;
            if(size.height+20>44)
                return size.height+20;
            else
                return 44;
        }
    
    }

}

- (IBAction)searchStudent:(id)sender {
    if(ed_NameOrNO.text.trimWhitespace.length<2)
    {
        tipView = [[OLGhostAlertView alloc] initWithTitle:@"请至少输入两个字符"];
        [tipView show];
        return;
    }
    btnSearch=(UIButton *)sender;
    if(btnSearch)
        btnSearch.enabled=false;
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init];
    [dic setObject:kUserIndentify forKey:@"用户较验码"];
    NSNumber *timeStamp=[[NSNumber alloc] initWithLong:[[NSDate new] timeIntervalSince1970]];
    [dic setObject:timeStamp forKey:@"DATETIME"];
    [dic setObject:@"search"  forKey:@"action"];
    [dic setObject:[teacherInfoDic objectForKey:@"用户名"] forKey:@"userid"];
    [dic setObject:ed_NameOrNO.text.trimWhitespace forKey:@"查询参数"];

    NSURL *url = [NSURL URLWithString:[kYingXinURL stringByAppendingString:@"baodaoHandle.php"]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    NSError *error;
    NSData *postData=[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
    postStr=[GTMBase64 base64StringBystring:postStr];
    [request setPostValue:postStr forKey:@"DATA"];
    [request setDelegate:self];
    request.userInfo=dic;
    request.username=@"查询学生";
    [requestArray addObject:request];
    [request startAsynchronous];
    tipView=[[OLGhostAlertView alloc] initWithIndicator:@"正在查询..." timeout:0 dismissible:NO];
    [tipView show];
}

- (IBAction)scanCode:(id)sender {
    DDISelectStudent *detail=[self.storyboard instantiateViewControllerWithIdentifier:@"selectStudentStoryBoardID"];
    [self.navigationController pushViewController:detail animated:YES];
}

- (IBAction)showBigPic:(id)sender {
    
    UIImageView *imageView = [UIImageView new];
    imageView.bounds = CGRectMake(0,0,0,0);
    imageView.backgroundColor=[UIColor blackColor];
    
    imageView.center = CGPointMake(60, 80);
    //imageView.transform = CGAffineTransformMakeRotation(M_PI_2);
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.image = headImage;
    imageView.userInteractionEnabled = YES;

    UITapGestureRecognizer *gesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture1:)];
    UIPanGestureRecognizer *gesture2 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:nil];
    [imageView addGestureRecognizer:gesture1];
    [imageView addGestureRecognizer:gesture2];
    [self.view addSubview:imageView];
    [UIView animateWithDuration:0.5 animations:^{
        imageView.frame = CGRectMake(0,self.tableView.contentOffset.y,self.view.frame.size.width,self.view.frame.size.height);
    }];
    
}
- (void)handleGesture1:(UIGestureRecognizer *)gesture
{
    UIView *view = gesture.view;
    
    [UIView animateWithDuration:0.5 animations:^{
        view.bounds = CGRectMake(0,0,0,0);
        view.center = CGPointMake(60, 80);
    } completion:^(BOOL finished) {
        [view removeFromSuperview];
    }];
}

@end
