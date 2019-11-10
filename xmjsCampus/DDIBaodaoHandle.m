//
//  DDIMyInforView.m
//  老师助手
//
//  Created by yons on 13-12-20.
//  Copyright (c) 2013年 dandian. All rights reserved.
//

#import "DDIBaodaoHandle.h"
extern NSMutableDictionary *teacherInfoDic;//老师数据
extern NSDictionary *LinkMandic;
extern NSString *kUserIndentify;
extern Boolean kIOS7;
extern int kUserType;
extern NSString *kInitURL;
extern NSString *kYingXinURL ;

static const char kRepresentedObject;

@interface DDIBaodaoHandle ()

@end

@implementation DDIBaodaoHandle

- (void)viewDidLoad
{
    [super viewDidLoad];
    savepath=[CommonFunc createPath:@"/utils/"];
  
    requestArray=[[NSMutableArray alloc] init];
    userDefaultes = [NSUserDefaults standardUserDefaults];
    [self getPersonalInfo];
    if(theStudentDic==nil)
    {
        tipView = [[OLGhostAlertView alloc] initWithIndicator:@"加载中..." timeout:0 dismissible:NO];
        [tipView showInView:self.view];
    }
    imgYes=[UIImage imageNamed:@"complete"];
    imgNo=[UIImage imageNamed:@"uncomplete"];
    userRole=[teacherInfoDic objectForKey:@"学生状态"];
    self.navigationItem.title=@"新生报到";
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshBaodaoHandle:)
                                                 name:@"refreshBaodaoHandle"
                                               object:nil];
}

-(void)getPersonalInfo
{
    NSURL *url = [NSURL URLWithString:[kYingXinURL stringByAppendingString:@"baodaoHandle.php"]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    NSError *error;
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init ];
    [dic setObject:self.ID forKey:@"编号"];
    [dic setObject:@"getinfo" forKey:@"action"];
    [dic setObject:[teacherInfoDic objectForKey:@"学生状态"] forKey:@"userRole"];
    
    request.username=@"报到情况";
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
    if([request.username isEqualToString:@"报到情况"])
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
                
                theStudentDic=[NSMutableDictionary dictionaryWithDictionary:[res objectForKey:@"用户信息"]];
                NSString *tmpStr=[res objectForKey:@"表格分组"];
                groupArray=[NSMutableArray arrayWithArray:[tmpStr componentsSeparatedByString:@","]];
                
                fieldsDic=[NSMutableDictionary dictionary];
                for(NSString *item in groupArray)
                {
                    if([res objectForKey:item])
                        [fieldsDic setObject:[res objectForKey:item] forKey:item];
                }
                
                completeDic=[NSMutableDictionary dictionaryWithDictionary:[res objectForKey:@"完成情况"]];
                [self.tableView reloadData];
                [self reloadHeadImage];
                
            }
        }
    }
    else if([request.username isEqualToString:@"更新数据"])
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
                
                NSString *action=[res objectForKey:@"action"];
                NSNumber *completeNum=[res objectForKey:@"完成情况"];
                if(completeNum)
                {
                    [completeDic setObject:completeNum forKey:action];
                }
                [theStudentDic setObject:[res objectForKey:@"显示值"] forKey:action];
                if([action isEqualToString:@"分配宿舍"] && completeNum.intValue==0)
                {
                    [theStudentDic setObject:@"" forKey:@"学生宿舍"];
                    [theStudentDic setObject:[NSNumber numberWithInt:0] forKey:@"床位号"];
                }
                [self.tableView reloadData];
            }
            else
            {
                tipView=[[OLGhostAlertView alloc] initWithTitle:[res objectForKey:@"结果"]];
                [tipView show];
            }
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
- (void)requestFailed:(ASIHTTPRequest *)request
{
    if(tipView)
        [tipView removeFromSuperview];
    NSError *error = [request error];
    NSLog(@"请求失败:%@",[error localizedDescription]);
    OLGhostAlertView *tipV = [[OLGhostAlertView alloc] initWithTitle:[error localizedDescription]];
    [tipV showInView:self.view];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshStudentList" object:nil];
    [super viewWillDisappear:animated];
}
-(void)dealloc
{
    for(ASIHTTPRequest *req in requestArray)
    {
        [req clearDelegatesAndCancel];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshBaodaoHandle" object:nil];
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
        
        NSString *tmpStr=[groupArray objectAtIndex:section-1];
        NSString *itemStr=[fieldsDic objectForKey:tmpStr];
        NSArray *itemArray=[itemStr componentsSeparatedByString:@","];
        return  itemArray.count;
        
    }
    
        
}
-(void)reloadHeadImage
{
    NSString *urlStr=[theStudentDic objectForKey:@"照片"];
    NSURL *url = [NSURL URLWithString:urlStr];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    request.username=[theStudentDic objectForKey:@"用户唯一码"];
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
 
        if(theStudentDic)
        {
            NSString *path=[CommonFunc getImageSavePath:[theStudentDic objectForKey:@"用户唯一码"] ifexist:YES];
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
                    [headBtn addSubview:innerImageView];
                }
                innerImageView.image=headImage;

            }
          
            UILabel *realName=(UILabel *)[cell viewWithTag:12];
            realName.text=[theStudentDic objectForKey:@"姓名"];
            UILabel *usertype=(UILabel *)[cell viewWithTag:13];
            usertype.text=[theStudentDic objectForKey:@"学生状态"];
        }
       
    }
    else
    {
        NSString *tmpStr=[groupArray objectAtIndex:indexPath.section-1];
        NSString *itemStr=[fieldsDic objectForKey:tmpStr];
        NSArray *itemArray=[itemStr componentsSeparatedByString:@","];
        itemStr=[itemArray objectAtIndex:indexPath.row];
        if([itemStr isEqualToString:@"就读方式"] && [userRole isEqualToString:@"班主任"])
        {
            static NSString *CellIdentifier3 = @"cell3";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier3];
            UILabel *left=[cell viewWithTag:11];
            left.text=itemStr;
            UISegmentedControl *seg=[cell viewWithTag:12];
            NSString *value=[theStudentDic objectForKey:itemStr];
            if([value isEqualToString:@"住校"])
                seg.selectedSegmentIndex=0;
            else if([value isEqualToString:@"走读"])
                seg.selectedSegmentIndex=1;
            else
                seg.selectedSegmentIndex=-1;
            seg.accessibilityValue=itemStr;
        }
        else if([completeDic objectForKey:itemStr])
        {
            static NSString *CellIdentifier4 = @"cell4";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier4];
            UILabel *left=[cell viewWithTag:11];
            left.text=itemStr;
            UISwitch *swh=[cell viewWithTag:12];
            UILabel *right=[cell viewWithTag:13];
            UIImageView *completeView=[cell viewWithTag:14];
            swh.enabled=false;
            swh.hidden=NO;
            right.hidden=NO;
            for(int i=15;i<35;i++)
            {
                UIView *view=[cell viewWithTag:i];
                if(view)
                    [view removeFromSuperview];
            }
            NSString *value=[theStudentDic objectForKey:itemStr];
            right.text=value;
            swh.accessibilityValue=itemStr;
            if([itemStr isEqualToString:@"确认入读"])
            {
                swh.hidden=YES;
                
            }
            else if([itemStr isEqualToString:@"身份验证"])
            {
                if([value isEqualToString:@"已验证"])
                    swh.on=true;
                else
                    swh.on=false;
                if([userRole isEqualToString:@"班主任"])
                    swh.enabled=true;
                
            }
            else if([itemStr isEqualToString:@"缴费"])
            {
                if([value isEqualToString:@"已缴费"])
                    swh.on=true;
                else
                    swh.on=false;
                if([userRole isEqualToString:@"班主任"])
                    swh.enabled=true;
                
            }
            else if([itemStr isEqualToString:@"收取材料"])
            {
                NSArray *resArray=[value componentsSeparatedByString:@"\n"];
                for(int i=0;i<resArray.count;i++)
                {
                    NSString *item=[resArray objectAtIndex:i];
                    NSArray *valueArray=[item componentsSeparatedByString:@":"];
                    right.hidden=YES;
                    swh.hidden=YES;
                    
                    CGRect frame=CGRectMake(99, 8, 49, 31);
                    frame.origin.y+=(frame.size.height+6)*i;
                    UISwitch *newSwi=[[UISwitch alloc]initWithFrame:frame];
                    newSwi.tag=15+i;
                    [cell addSubview:newSwi];
                    frame=CGRectMake(156,13, 154, 21);
                    frame.origin.y+=(swh.frame.size.height+6)*i;
                    UILabel *newLab=[[UILabel alloc]initWithFrame:frame];
                    newLab.tag=25+i;
                    [cell addSubview:newLab];
                    if([itemStr isEqualToString:@"收取材料"])
                    {
                        if([[valueArray objectAtIndex:1] isEqualToString:@"已提交"])
                            newSwi.on=true;
                        else
                            newSwi.on=false;
                    }
                    
                    newSwi.accessibilityValue=[valueArray objectAtIndex:0];
                    [newSwi addTarget:self action:@selector(stateChanged:) forControlEvents:UIControlEventValueChanged];
                    newLab.text=[valueArray objectAtIndex:0];
                    if([userRole isEqualToString:@"班主任"])
                        newSwi.enabled=true;
                    else
                        newSwi.enabled=false;
                    
                }
                
            }
            else if([itemStr isEqualToString:@"领取校园卡"])
            {
                if([value isEqualToString:@"未领取"])
                    swh.on=false;
                else
                    swh.on=true;
                if([userRole isEqualToString:@"班主任"])
                    swh.enabled=true;
            }
            else if([itemStr isEqualToString:@"分配宿舍"])
            {
                if([value isEqualToString:@"未分配"])
                    swh.on=false;
                else
                    swh.on=true;
                if([userRole isEqualToString:@"班主任"])
                    swh.enabled=true;
            }
            else if([itemStr isEqualToString:@"领宿舍钥匙"])
            {
                if([value isEqualToString:@"未领取"])
                    swh.on=false;
                else
                    swh.on=true;
                if([userRole isEqualToString:@"班主任"])
                    swh.enabled=true;
            }
            NSNumber *number=[completeDic objectForKey:itemStr];
            if(number)
            {
                completeView.hidden=NO;
                if(number.intValue==1)
                    completeView.image=imgYes;
                else
                    completeView.image=imgNo;
            }
            else
                completeView.hidden=YES;
            
        }
        else
        {
            static NSString *CellIdentifier2 = @"cell2";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
            UILabel *title=[cell viewWithTag:11];
            UILabel *detail=[cell viewWithTag:12];
            title.text=itemStr;
            detail.text=[theStudentDic objectForKey:itemStr];
            
        }
        /*
        CGSize size = [detail.text sizeWithFont:detail.font constrainedToSize:CGSizeMake(220, 1000) lineBreakMode:NSLineBreakByWordWrapping];
        
        [detail setFrame:CGRectMake(detail.frame.origin.x, detail.frame.origin.y, size.width, size.height)];
        [detail sizeToFit];
         */
    }
    
    return cell;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag==1)
    {
        if(buttonIndex==1)
        {
            NSDictionary *dic=objc_getAssociatedObject(alertView,&kRepresentedObject);
            NSString *actionKey=[dic objectForKey:@"actionKey"];
            UISwitch *swh=[dic objectForKey:@"swh"];
            [self updateBaodao:actionKey flag:swh.isOn];
        }
    }
    else if(alertView.tag==3)
    {

        NSString *tel;
        if(buttonIndex==1)
            tel=[theStudentDic objectForKey:@"学生电话"];
        else if (buttonIndex==2)
            tel=[theStudentDic objectForKey:@"监护人手机号码"];
        if(tel && tel.length>6)
        {
            NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"tel://%@",tel];
            NSLog(@"%@", str);
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
        }
    }

    
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
        
            NSString *tmpStr=[groupArray objectAtIndex:indexPath.section-1];
            NSString *itemStr=[fieldsDic objectForKey:tmpStr];
            NSArray *itemArray=[itemStr componentsSeparatedByString:@","];
            itemStr=[itemArray objectAtIndex:indexPath.row];
            /*
            NSString *detailtext=[theStudentDic objectForKey:itemStr];
            
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
             */
            if([itemStr isEqualToString:@"收取材料"])
            {
                NSString *value=[theStudentDic objectForKey:itemStr];
                NSArray *resArray=[value componentsSeparatedByString:@"\n"];
                return 40*resArray.count;
            }
            else if([itemStr isEqualToString:@"缴费"])
                return 40*2;
            else
                return 48;
        
    }

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

- (IBAction)callStudent:(id)sender {
    
    UIAlertView*alert = [[UIAlertView alloc]initWithTitle:@"拨打给"
                                                  message:nil
                                                 delegate:self
                                        cancelButtonTitle:@"取消"
                                        otherButtonTitles:nil,nil];

    NSString *btnTitle=[NSString stringWithFormat:@"学生电话:%@",[theStudentDic objectForKey:@"学生电话"]];
    [alert addButtonWithTitle:btnTitle];
    btnTitle=[NSString stringWithFormat:@"监护人电话:%@",[theStudentDic objectForKey:@"监护人手机号码"]];
    [alert addButtonWithTitle:btnTitle];
    alert.tag=3;
    [alert show];
}

- (IBAction)messageStudent:(id)sender {
    DDIChatView *chatView=[self.storyboard instantiateViewControllerWithIdentifier:@"chatStoryboardID"];
    chatView.respondName=[theStudentDic objectForKey:@"姓名"];
    chatView.respondUser=[theStudentDic objectForKey:@"用户唯一码"];
    [self.navigationController pushViewController:chatView animated:YES];
}

- (IBAction)segValueChanged:(id)sender {
    
    UISegmentedControl *seg=(UISegmentedControl *)sender;
    NSString *value=@"住校";
    if(seg.selectedSegmentIndex==1)
    {
        value=@"走读";
        NSNumber *number1=[completeDic objectForKey:@"分配宿舍"];
        if(number1.intValue==1)
        {
            tipView = [[OLGhostAlertView alloc] initWithTitle:@"已分配宿舍，请先撤销"];
            [tipView show];
            [self.tableView reloadData];
            return;
        }
        NSNumber *number2=[completeDic objectForKey:@"领宿舍钥匙"];
        if(number2.intValue==1)
        {
            tipView = [[OLGhostAlertView alloc] initWithTitle:@"已领宿舍钥匙，请先撤销"];
            [tipView show];
            [self.tableView reloadData];
            return;
        }
    }
    [self updateBaodao:value flag:true];
}
-(void)updateBaodao:(NSString *)action flag:(BOOL)checked
{
    tipView = [[OLGhostAlertView alloc] initWithIndicator:@"处理中..." timeout:0 dismissible:NO];
    [tipView show];
    NSNumber *num=[NSNumber numberWithBool:checked];
    NSURL *url = [NSURL URLWithString:[kYingXinURL stringByAppendingString:@"baodaoHandle.php"]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    NSError *error;
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init ];
    [dic setObject:self.ID forKey:@"编号"];
    [dic setObject:action forKey:@"action"];
    [dic setObject:num forKey:@"checked"];
    [dic setObject:[teacherInfoDic objectForKey:@"用户名"] forKey:@"userid"];
    [dic setObject:@"IOS" forKey:@"client"];
    request.username=@"更新数据";
    NSData *postData=[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
    postStr=[GTMBase64 base64StringBystring:postStr];
    [request setPostValue:postStr forKey:@"DATA"];
    [request setDelegate:self];
    [request setTimeOutSeconds:60];
    [request startAsynchronous];
    [requestArray addObject:request];
}
-(void)setSwhValueOn:(UISwitch *)swf
{
    [swf setOn:YES animated:YES];
    swf.enabled=true;
}
-(void)setSwhValueOff:(UISwitch *)swf
{
    [swf setOn:NO animated:YES];
    swf.enabled=true;
}
- (IBAction)stateChanged:(id)sender
{
    UISwitch *swh=(UISwitch *)sender;
    NSString *action=swh.accessibilityValue;
    if(action==nil) return;
    NSNumber *num1;
    NSNumber *num2;
    NSNumber *num3;
    if([action isEqualToString:@"身份验证"])
    {
        if(!swh.isOn)
        {
            num1=[completeDic objectForKey:@"领取校园卡"];
            num2=[completeDic objectForKey:@"缴费"];
            num3=[completeDic objectForKey:@"收取材料"];
            if(num1.intValue==1 || num3.intValue==1)
            {
                tipView = [[OLGhostAlertView alloc] initWithTitle:@"后续步骤已完成，本步骤无法取消"];
                [tipView show];
                swh.enabled=false;
                [self performSelector:@selector(setSwhValueOn:) withObject:swh afterDelay:1.0];
                return;
            }
            [self showOkayCancelAlert:swh action:action];
        }
        else
            [self updateBaodao:action flag:swh.isOn];
        
    }
    else
    {
        if(swh.isOn)
        {
            num1=[completeDic objectForKey:@"身份验证"];
            num2=[completeDic objectForKey:@"缴费"];
            if(num1.intValue==0)
            {
                tipView = [[OLGhostAlertView alloc] initWithTitle:@"请先进行身份验证"];
                [tipView show];
                swh.enabled=false;
                [self performSelector:@selector(setSwhValueOff:) withObject:swh afterDelay:1.0];
                return;
            }
        }
        if([action isEqualToString:@"分配宿舍"])
        {
            num1=[completeDic objectForKey:@"领宿舍钥匙"];
            num2=[completeDic objectForKey:@"分配宿舍"];
            if(!swh.isOn && num1.intValue==1)
            {
                tipView = [[OLGhostAlertView alloc] initWithTitle:@"后续步骤已完成，本步骤无法取消"];
                [tipView show];
                swh.enabled=false;
                [self performSelector:@selector(setSwhValueOn:) withObject:swh afterDelay:1.0];
                return;
            }
            if(swh.isOn && [[theStudentDic objectForKey:@"就读方式"] isEqualToString:@"走读"])
            {
                tipView = [[OLGhostAlertView alloc] initWithTitle:@"走读生无需分配宿舍"];
                [tipView show];
                swh.enabled=false;
                [self performSelector:@selector(setSwhValueOff:) withObject:swh afterDelay:1.0];
                return;
            }
            if(swh.isOn && num2.intValue==0)
            {
                DDISelectDorm *detail=[self.storyboard instantiateViewControllerWithIdentifier:@"selectDormStoryBoardID"];
                detail.ID=self.ID;
                detail.sex=[theStudentDic objectForKey:@"性别"];
                [self.navigationController pushViewController:detail animated:YES];
                return;
            }
        }
        if([action isEqualToString:@"领宿舍钥匙"])
        {
            num1=[completeDic objectForKey:@"分配宿舍"];
            if(swh.isOn && num1.intValue==0)
            {
                tipView = [[OLGhostAlertView alloc] initWithTitle:@"请先分配宿舍"];
                [tipView show];
                swh.enabled=false;
                [self performSelector:@selector(setSwhValueOff:) withObject:swh afterDelay:1.0];
                return;
            }
        }
        if([action isEqualToString:@"领取校园卡"])
        {
            num1=[completeDic objectForKey:@"身份验证"];
            if(swh.isOn && num1.intValue==0)
            {
                tipView = [[OLGhostAlertView alloc] initWithTitle:@"请先进行身份验证"];
                [tipView show];
                swh.enabled=false;
                [self performSelector:@selector(setSwhValueOff:) withObject:swh afterDelay:1.0];
                return;
            }
        }
        if(!swh.isOn)
        {
            [self showOkayCancelAlert:swh action:action];
        }
        else
            [self updateBaodao:action flag:swh.isOn];
    }
    
}
- (void)showOkayCancelAlert:(UISwitch *)swh action:(NSString *)actionKey
{
    NSString *title = @"确认撤销吗？";

    NSString *cancelButtonTitle = @"否";
    NSString *otherButtonTitle = @"是";
    if([[[UIDevice currentDevice]systemVersion] floatValue]>=8.0)
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        // Create the actions.
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [swh setOn:YES];
        }];
        
        UIAlertAction *otherAction = [UIAlertAction actionWithTitle:otherButtonTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
            [self updateBaodao:actionKey flag:swh.isOn];
        }];
        
        // Add the actions.
        [alertController addAction:cancelAction];
        [alertController addAction:otherAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:title message:nil delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
        
        NSMutableDictionary *dic=[NSMutableDictionary dictionary];
        [dic setObject:actionKey forKey:@"actionKey"];
        [dic setObject:swh forKey:@"swh"];
        objc_setAssociatedObject(alert, &kRepresentedObject, dic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        alert.tag=1;
        [alert show];
    }
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
-(void)refreshBaodaoHandle:(NSNotification *)result
{
    NSDictionary *dic=result.userInfo;
    if(dic)
    {
        NSString *action=[dic objectForKey:@"action"];
        NSString *showValue=[dic objectForKey:@"显示值"];
        NSNumber *num=[dic objectForKey:@"完成情况"];
        if(action)
        {
            [completeDic setObject:num forKey:action];
            [theStudentDic setObject:showValue forKey:action];
        }
    }
    [self.tableView reloadData];
}
@end
