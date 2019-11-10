//
//  DDILinkManGroup.m
//  老师助手
//
//  Created by yons on 14-1-13.
//  Copyright (c) 2014年 dandian. All rights reserved.
//

#import "DDISelectStudent.h"
extern NSString *kYingXinURL;
extern NSString *kUserIndentify;
extern Boolean kIOS7;
extern NSMutableDictionary *userInfoDic;//课表数据
extern NSMutableDictionary *teacherInfoDic;//老师数据
extern NSDictionary *LinkMandic;//联系人数据
extern int kUserType;
extern NSMutableDictionary *lastMsgDic;
extern DDIDataModel *datam;
@interface DDISelectStudent ()

@end

@implementation DDISelectStudent

- (void)viewDidLoad
{
    [super viewDidLoad];
    arrayRight=[UIImage imageNamed:@"arrowRight"];
    arrayDown=[UIImage imageNamed:@"arrowDown"];
    
    savePath=[CommonFunc createPath:@"/News/"];
    groupArray=[[NSArray alloc]init];
    friendDic=[[NSMutableDictionary alloc]init];
    requestArray=[[NSMutableArray alloc]init];
    headViewArray=[[NSMutableDictionary alloc]init];
    self.navigationItem.title=self.title;
    
    float height=self.view.frame.size.height-self.navigationController.navigationBar.frame.size.height-20;
    
    self.mTableView = [[TQMultistageTableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,height)];
    if(kIOS7)
        self.mTableView.tableView.separatorInset=UIEdgeInsetsMake(0,0,0,0);
    self.mTableView.delegate = self;
    self.mTableView.dataSource = self;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
    [self.view addSubview:self.mTableView];
    [self getStudentList];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshStudentList)
                                                 name:@"refreshStudentList"
                                               object:nil];
}
-(void)refreshStudentList
{
    [self getStudentList];
}
-(void)getStudentList
{
    alertTip = [[OLGhostAlertView alloc] initWithIndicator:@"载入中..." timeout:0 dismissible:NO];
    [alertTip show];
    NSURL *url = [NSURL URLWithString:[kYingXinURL stringByAppendingString:@"baodaoHandle.php"]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    NSError *error;
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init ];
    [dic setObject:@"getStudentList" forKey:@"action"];
    [dic setObject:[teacherInfoDic objectForKey:@"用户名"] forKey:@"userid"];
    request.username=@"获取学生列表";
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
    if([request.username isEqualToString:@"获取学生列表"])
    {
        if(alertTip)
            [alertTip removeFromSuperview];
        NSData *data = [request responseData];
        //NSString* dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        data   = [[NSData alloc] initWithBase64EncodedData:data options:0];
        id res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (res && [res isKindOfClass:[NSDictionary class]])
        {
            if([[res objectForKey:@"结果"] isEqualToString:@"成功"])
            {
                baodaoNumObj=[res objectForKey:@"报到完成人数"];
                friendDic=[NSMutableDictionary dictionaryWithDictionary:[res objectForKey:@"班级人员列表"]];
                NSString *dormStr=[res objectForKey:@"班级字符串"];
                groupArray=[dormStr componentsSeparatedByString:@","];
                [self.mTableView reloadData];
                if(groupArray.count==1)
                    [self.mTableView openOrCloseHeaderWithSection:0];
                
            }
        }
    }
    
    else if([request.username isEqualToString:@"下载图片"])
    {
        NSData *datas = [request responseData];
        UIImage *headImage=[[UIImage alloc]initWithData:datas];
        if(headImage!=nil)
        {
            
            NSDictionary *indexDic=request.userInfo;
            NSString *filename=[indexDic objectForKey:@"filename"];
            [datas writeToFile:filename atomically:YES];
            NSIndexPath *indexPath=[indexDic objectForKey:@"indexPath"];
            if([[indexDic objectForKey:@"poptable"] isEqualToString:@"true"])
            {
                [poplistview.listView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            else
            {
                UITableViewCell *cell=[self.mTableView cellForRowAtIndexPath:indexPath];
                if(cell)
                    [self.mTableView reloadDataWithTableViewCell:cell];
            }
        }
    }
    if([requestArray containsObject:request])
        [requestArray removeObject:request];
    request=nil;
}
- (void)requestFailed:(ASIHTTPRequest *)request
{
    if(alertTip)
        [alertTip removeFromSuperview];
    NSError *error = [request error];
    NSLog(@"请求失败:%@",[error localizedDescription]);
    OLGhostAlertView *tipV = [[OLGhostAlertView alloc] initWithTitle:[error localizedDescription]];
    [tipV showInView:self.view];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return groupArray.count;

}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{

    NSArray *linkManOfGroup=[friendDic objectForKey:groupArray[section]];
    return linkManOfGroup.count;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"TQMultistageTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        if(kIOS7)
            cell.separatorInset=UIEdgeInsetsMake(0, 0, 0, 0);

        //cell.imageView.layer.cornerRadius = 5;
        //cell.imageView.layer.masksToBounds = YES;
        
        

        UIButton *btn=[[UIButton alloc]initWithFrame:CGRectMake(10, 10, 40, 40)];
        //btn.backgroundColor=[UIColor grayColor];
        btn.tag=11;
        [cell addSubview:btn];
        [btn.layer setMasksToBounds:YES];
        [btn.layer setCornerRadius:5.0];
        int x=60;
        UILabel *lbName=[[UILabel alloc]initWithFrame:CGRectMake(x, 5, 240, 30)];
        lbName.tag=12;
        lbName.font=[UIFont boldSystemFontOfSize:18];
        lbName.backgroundColor=[UIColor clearColor];
        [cell addSubview:lbName];
        
        UILabel *lbIdCard=[[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width-160, 5, 150, 30)];
        lbIdCard.tag=13;
        lbIdCard.font=[UIFont boldSystemFontOfSize:13];
        lbIdCard.backgroundColor=[UIColor clearColor];
        lbIdCard.textColor=[UIColor grayColor];
        [cell addSubview:lbIdCard];
        
        UILabel *lbStep1=[[UILabel alloc]initWithFrame:CGRectMake(x, 40, 240, 20)];
        lbStep1.font=[UIFont boldSystemFontOfSize:12];
        lbStep1.backgroundColor=[UIColor clearColor];
        lbStep1.text=@"身份验证";
        [lbStep1 sizeToFit];
        [cell addSubview:lbStep1];
        x=x+lbStep1.frame.size.width+2;
        UIImageView *ivStep1=[[UIImageView alloc]initWithFrame:CGRectMake(x, 40, 15, 15)];
        ivStep1.tag=14;
        ivStep1.contentMode=UIViewContentModeScaleAspectFit;
        ivStep1.backgroundColor=[UIColor clearColor];
        [cell addSubview:ivStep1];
        
        x=x+ivStep1.frame.size.width+5;
        UILabel *lbStep2=[[UILabel alloc]initWithFrame:CGRectMake(x, 40, 240, 20)];
        lbStep2.font=[UIFont boldSystemFontOfSize:12];
        lbStep2.backgroundColor=[UIColor clearColor];
        lbStep2.text=@"缴费";
        [lbStep2 sizeToFit];
        [cell addSubview:lbStep2];
        
        x=x+lbStep2.frame.size.width+2;
        UIImageView *ivStep2=[[UIImageView alloc]initWithFrame:CGRectMake(x, 40, 15, 15)];
        ivStep2.tag=15;
        ivStep2.contentMode=UIViewContentModeScaleAspectFit;
        ivStep2.backgroundColor=[UIColor clearColor];
        [cell addSubview:ivStep2];
        
        x=x+ivStep2.frame.size.width+5;
        UILabel *lbStep3=[[UILabel alloc]initWithFrame:CGRectMake(x, 40, 240, 20)];
        lbStep3.font=[UIFont boldSystemFontOfSize:12];
        lbStep3.backgroundColor=[UIColor clearColor];
        lbStep3.text=@"收取材料";
        [lbStep3 sizeToFit];
        [cell addSubview:lbStep3];
        
        x=x+lbStep3.frame.size.width+2;
        UIImageView *ivStep3=[[UIImageView alloc]initWithFrame:CGRectMake(x, 40, 15, 15)];
        ivStep3.tag=16;
        ivStep3.contentMode=UIViewContentModeScaleAspectFit;
        ivStep3.backgroundColor=[UIColor clearColor];
        [cell addSubview:ivStep3];
        
        x=x+ivStep3.frame.size.width+5;
        UILabel *lbStep4=[[UILabel alloc]initWithFrame:CGRectMake(x, 40, 240, 20)];
        lbStep4.font=[UIFont boldSystemFontOfSize:12];
        lbStep4.backgroundColor=[UIColor clearColor];
        lbStep4.text=@"一卡通";
        [lbStep4 sizeToFit];
        [cell addSubview:lbStep4];
        
        x=x+lbStep4.frame.size.width+2;
        UIImageView *ivStep4=[[UIImageView alloc]initWithFrame:CGRectMake(x, 40, 15, 15)];
        ivStep4.tag=17;
        ivStep4.contentMode=UIViewContentModeScaleAspectFit;
        ivStep4.backgroundColor=[UIColor clearColor];
        [cell addSubview:ivStep4];
        
    }
    NSDictionary *linkman=nil;
    
    NSArray *linkManOfGroup=[friendDic objectForKey:groupArray[indexPath.section]];
    linkman=[linkManOfGroup objectAtIndex:indexPath.row];
    
    NSString *dormName=[linkman objectForKey:@"姓名"];
    NSString *idcard=[linkman objectForKey:@"身份证号"];
    NSString *imageUrl=[linkman objectForKey:@"照片"];
    UILabel *lbName=(UILabel *)[cell viewWithTag:12];
    UILabel *lbIdcard=(UILabel *)[cell viewWithTag:13];
    UIImageView *ivStep1=(UIImageView *)[cell viewWithTag:14];
    UIImageView *ivStep2=(UIImageView *)[cell viewWithTag:15];
    UIImageView *ivStep3=(UIImageView *)[cell viewWithTag:16];
    UIImageView *ivStep4=(UIImageView *)[cell viewWithTag:17];
    lbName.text=dormName;
    lbIdcard.text=idcard;
    NSNumber *step1=[linkman objectForKey:@"是否报到"];
    NSNumber *step2=[linkman objectForKey:@"预交费"];
    NSNumber *step3=[linkman objectForKey:@"收取材料"];
    NSNumber *step4=[linkman objectForKey:@"一卡通卡号"];
    UIImage *im_right=[UIImage imageNamed:@"rightmark"];
    UIImage *im_wrong=[UIImage imageNamed:@"login_delete_bg_sel"];
    if(step1.intValue==1)
        [ivStep1 setImage:im_right];
    else
        [ivStep1 setImage:im_wrong];
    if(step2.intValue==1)
        [ivStep2 setImage:im_right];
    else
        [ivStep2 setImage:im_wrong];
    if(step3.intValue==1)
        [ivStep3 setImage:im_right];
    else
        [ivStep3 setImage:im_wrong];
    if(step4.intValue==1)
        [ivStep4 setImage:im_right];
    else
        [ivStep4 setImage:im_wrong];
    UIButton *headBtn=(UIButton *)[cell viewWithTag:11];
    NSArray *sepArray=[imageUrl componentsSeparatedByString:@"/"];
    NSString *filename=[sepArray objectAtIndex:sepArray.count-1];
    filename=[savePath stringByAppendingString:filename];
    UIImage *headImage;
    if([CommonFunc fileIfExist:filename])
    {
        headImage=[UIImage imageWithContentsOfFile:filename];
        CGSize newSize=CGSizeMake(80, 80);
        headImage=[headImage scaleToSize1:newSize];
        headImage=[headImage cutFromImage:CGRectMake(0, 0, 80, 80)];
        [headBtn setImage:headImage forState:UIControlStateNormal];
    }
    else
    {
        if(imageUrl && imageUrl.length>0)
        {
            NSURL *url = [NSURL URLWithString:imageUrl];
            ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
            request.username=@"下载图片";
            NSMutableDictionary *indexDic=[[NSMutableDictionary alloc]init];
            [indexDic setObject:indexPath forKey:@"indexPath"];
            [indexDic setObject:filename forKey:@"filename"];
            request.userInfo=indexDic;
            [request setDelegate:self];
            [request startAsynchronous];
            [requestArray addObject:request];
        }
        
    }

    return cell;
}


- (CGFloat)mTableView:(TQMultistageTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (CGFloat)mTableView:(TQMultistageTableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 48;
}
- (UIView *)mTableView:(TQMultistageTableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *control=[headViewArray objectForKey:[NSNumber numberWithInteger:section]];
    if(control==Nil)
    {
        control = [[UIView alloc] init];
        control.backgroundColor = [[UIColor alloc]initWithRed:0.937255 green:0.937255 blue:0.956863 alpha:1];

        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 43.5, tableView.frame.size.width, 0.5)];
        view.backgroundColor = [UIColor grayColor];
        UIImageView *imgView=[[UIImageView alloc]initWithFrame:CGRectMake(10, 17, 10, 10)];
        imgView.contentMode =  UIViewContentModeCenter;
        imgView.image=arrayRight;
        imgView.tag=1001;
        
        
        UILabel *label = [[UILabel alloc] init];
        label.text = [NSString stringWithFormat:@"%@",[groupArray objectAtIndex:section]];
        label.textColor = [UIColor blackColor];
        label.backgroundColor=[UIColor clearColor];
        label.frame = CGRectMake(25, 0, 200, 44);
        
        NSArray *linkManOfGroup=[friendDic objectForKey:groupArray[section]];
        UILabel *lbcount = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width-100, 0, 80, 44)];
        lbcount.textAlignment=NSTextAlignmentRight;
        lbcount.textColor=[UIColor grayColor];
        lbcount.font=[UIFont systemFontOfSize:12];
        lbcount.backgroundColor=[UIColor clearColor];
        lbcount.tag=1002;
        NSNumber *yiwancheng=[baodaoNumObj objectForKey:groupArray[section]];
        lbcount.text=[NSString stringWithFormat:@"(%d/%lu)",yiwancheng.intValue,(unsigned long)linkManOfGroup.count];
        [control addSubview:imgView];
        [control addSubview:label];
        [control addSubview:lbcount];
        [control addSubview:view];
        [headViewArray setObject:control forKey:[NSNumber numberWithInteger:section]];
    }
    return control;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *linkManOfGroup=[friendDic objectForKey:groupArray[indexPath.section]];
    NSDictionary *linkman=[linkManOfGroup objectAtIndex:indexPath.row];
    DDIBaodaoHandle *detail=[self.storyboard instantiateViewControllerWithIdentifier:@"baodaoHandle"];
    detail.ID=[linkman objectForKey:@"编号"];
    [self.navigationController pushViewController:detail animated:YES];}

-(void)mTableView:(TQMultistageTableView *)tableView willOpenHeaderAtSection:(NSInteger)section
{
    UIView *view=[self mTableView:tableView viewForHeaderInSection:section];
    UIImageView *imgView=(UIImageView *)[view viewWithTag:1001];
    imgView.image=arrayDown;
}
-(void)mTableView:(TQMultistageTableView *)tableView willCloseHeaderAtSection:(NSInteger)section
{
    UIView *view=[self mTableView:tableView viewForHeaderInSection:section];
    UIImageView *imgView=(UIImageView *)[view viewWithTag:1001];
    imgView.image=arrayRight;
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    for(ASIHTTPRequest *req in requestArray)
    {
        [req clearDelegatesAndCancel];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshStudentList" object:nil];
}

#pragma mark - UIPopoverListViewDataSource
- (UITableViewCell *)popoverListView:(UIPopoverListView *)popoverListView
                    cellForIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                    reuseIdentifier:identifier];
    
    NSDictionary *item=[bedList objectAtIndex:indexPath.row];
    NSString *bedName=[item objectForKey:@"房间名称"];
    NSString *url=[item objectForKey:@"url"];
    NSString *state=[item objectForKey:@"所属班级"];
    [self getImageByUrl:url imagev:cell.imageView indexPath:indexPath];
    cell.textLabel.text=[NSString stringWithFormat:@"%@ %@",bedName,state];

    return cell;
}
- (NSInteger)popoverListView:(UIPopoverListView *)popoverListView
       numberOfRowsInSection:(NSInteger)section
{
    return bedList.count;
}
#pragma mark - UIPopoverListViewDelegate
- (void)popoverListView:(UIPopoverListView *)popoverListView
     didSelectIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *item=[bedList objectAtIndex:indexPath.row];
    NSString *state=[item objectForKey:@"所属班级"];
    NSNumber *bedId=[item objectForKey:@"编号"];
    NSString *dormName=[item objectForKey:@"宿舍楼"];
    if([state isEqualToString:@"[空闲]"])
    {
        [self updateDormAndBed:dormName bedId:bedId];
    }
    else
    {
        OLGhostAlertView *tipV = [[OLGhostAlertView alloc] initWithTitle:@"此床位已被占用"];
        [tipV show];
    }
}
-(void)updateDormAndBed:(NSString *)dormName bedId:(NSNumber *)bedId
{

    alertTip = [[OLGhostAlertView alloc] initWithIndicator:@"提交中..." timeout:0 dismissible:NO];
    [alertTip show];
    NSURL *url = [NSURL URLWithString:[kYingXinURL stringByAppendingString:@"baodaoHandle.php"]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    NSError *error;
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init ];
    [dic setObject:@"updateDormAndBed" forKey:@"action"];
    [dic setObject:self.ID forKey:@"编号"];
    [dic setObject:dormName forKey:@"dormName"];
    [dic setObject:bedId forKey:@"bedNo"];
    [dic setObject:[teacherInfoDic objectForKey:@"学号"] forKey:@"userid"];
    [dic setObject:@"IOS" forKey:@"client"];
    request.username=@"更新床位";
    NSData *postData=[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
    postStr=[GTMBase64 base64StringBystring:postStr];
    [request setPostValue:postStr forKey:@"DATA"];
    [request setDelegate:self];
    [request setTimeOutSeconds:60];
    [request startAsynchronous];
    [requestArray addObject:request];
}
- (CGFloat)popoverListView:(UIPopoverListView *)popoverListView
   heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45.0f;
}
-(void) getImageByUrl:(NSString *)headUrl imagev:(UIImageView *)imagev indexPath:(NSIndexPath *)indexPath
{
    if(!headUrl && [NSURL URLWithString:headUrl]==nil)
        return;
    NSArray *sepArray=[headUrl componentsSeparatedByString:@"/"];
    NSString *filename=[sepArray objectAtIndex:sepArray.count-1];
    filename=[savePath stringByAppendingString:filename];
    if([CommonFunc fileIfExist:filename])
    {
        UIImage *img=[UIImage imageWithContentsOfFile:filename];
        CGSize newSize=CGSizeMake(35, 35);
        img=[img scaleToSize1:newSize];
        img=[img cutFromImage:CGRectMake(0, 0, 35, 35)];
        imagev.image=img;
        [imagev.layer setMasksToBounds:YES];
        [imagev.layer setCornerRadius:17]; //设置矩形四个圆角半径
        //imagev.transform=CGAffineTransformMakeScale(0.8, 0.8);
    }
    else
    {
        NSURL *url = [NSURL URLWithString:headUrl];
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        request.username=@"下载图片";
        NSMutableDictionary *indexDic=[[NSMutableDictionary alloc]init];
        [indexDic setObject:filename forKey:@"filename"];
        [indexDic setObject:indexPath forKey:@"indexPath"];
        [indexDic setObject:@"true" forKey:@"poptable"];
        request.userInfo=indexDic;
        [request setDelegate:self];
        [request startAsynchronous];
        [requestArray addObject:request];
        
    }
}
@end
