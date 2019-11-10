//
//  DDILinkManGroup.m
//  老师助手
//
//  Created by yons on 14-1-13.
//  Copyright (c) 2014年 dandian. All rights reserved.
//

#import "DDISelectDorm.h"
extern NSString *kYingXinURL;//迎新webService
extern NSString *kUserIndentify;
extern Boolean kIOS7;
extern NSMutableDictionary *userInfoDic;//课表数据
extern NSMutableDictionary *teacherInfoDic;//老师数据
extern NSDictionary *LinkMandic;//联系人数据
extern int kUserType;
extern NSMutableDictionary *lastMsgDic;
extern DDIDataModel *datam;
@interface DDISelectDorm ()

@end

@implementation DDISelectDorm

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
    
    
    float height=self.view.frame.size.height-self.tabBarController.tabBar.frame.size.height-self.parentViewController.navigationController.navigationBar.frame.size.height;
    if(kIOS7)
        height-=20;
    self.mTableView = [[TQMultistageTableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,height)];
    if(kIOS7)
        self.mTableView.tableView.separatorInset=UIEdgeInsetsMake(0,0,0,0);
    self.mTableView.delegate = self;
    self.mTableView.dataSource = self;
    [self.view addSubview:self.mTableView];
    [self getDormList];
}
-(void)getDormList
{
    alertTip = [[OLGhostAlertView alloc] initWithIndicator:@"载入中..." timeout:0 dismissible:NO];
    [alertTip show];
    NSURL *url = [NSURL URLWithString:[kYingXinURL stringByAppendingString:@"baodaoHandle.php"]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    NSError *error;
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init ];
    [dic setObject:@"getDormList" forKey:@"action"];
    [dic setObject:[teacherInfoDic objectForKey:@"用户名"] forKey:@"userid"];
    [dic setObject:self.sex forKey:@"sex"];
    request.username=@"获取宿舍";
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
    if([request.username isEqualToString:@"获取宿舍"])
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
                
                friendDic=[NSMutableDictionary dictionaryWithDictionary:[res objectForKey:@"宿舍列表"]];
                NSString *dormStr=[res objectForKey:@"宿舍楼字符串"];
                groupArray=[dormStr componentsSeparatedByString:@","];
                [self.mTableView reloadData];
                
            }
        }
    }
    else if([request.username isEqualToString:@"获取床位"])
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
                
                bedList=[NSArray arrayWithArray:[res objectForKey:@"床位列表"]];
                NSString *dormName=[res objectForKey:@"dormName"];
                
                CGFloat xWidth = self.view.bounds.size.width - 20.0f;
                CGFloat yHeight = 45*bedList.count+32.0f;
                CGFloat yOffset = (self.view.bounds.size.height - yHeight)/2.0f;
                if(!poplistview)
                {
                    poplistview = [[UIPopoverListView alloc] initWithFrame:CGRectMake(10, yOffset, xWidth, yHeight)];
                    poplistview.delegate = self;
                    poplistview.datasource = self;
                    poplistview.listView.scrollEnabled = FALSE;
                    
                }
                [poplistview setTitle:[NSString stringWithFormat:@"%@选择床位",dormName]];
                [poplistview show:self.view];
                [poplistview.listView reloadData];
                
            }
        }
    }
    else if([request.username isEqualToString:@"更新床位"])
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
                [self notifyParentControl:res];
                [self.navigationController popViewControllerAnimated:YES];

            }
            else
            {
                alertTip = [[OLGhostAlertView alloc] initWithTitle:[res objectForKey:@"结果"]];
                [alertTip show];
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
        
        

        UIButton *btn=[[UIButton alloc]initWithFrame:CGRectMake(10, 4, 40, 40)];
        //btn.backgroundColor=[UIColor grayColor];
        btn.tag=11;
        [cell addSubview:btn];
        [btn.layer setMasksToBounds:YES];
        [btn.layer setCornerRadius:5.0];
        
        UILabel *lbName=[[UILabel alloc]initWithFrame:CGRectMake(60, 10, 240, 30)];
        lbName.tag=12;
        lbName.font=[UIFont boldSystemFontOfSize:18];
        lbName.backgroundColor=[UIColor clearColor];
        [cell addSubview:lbName];
        
    }
    NSDictionary *linkman=nil;
    
    NSArray *linkManOfGroup=[friendDic objectForKey:groupArray[indexPath.section]];
    linkman=[linkManOfGroup objectAtIndex:indexPath.row];
    
    NSString *dormName=[linkman objectForKey:@"房间名称"];
    NSNumber *alreadyIn=[linkman objectForKey:@"已住人数"];
    NSNumber *bedsNum=[linkman objectForKey:@"房间床位数"];
    NSString *imageUrl=[linkman objectForKey:@"url"];
    UILabel *lbName=(UILabel *)[cell viewWithTag:12];

    lbName.text=[NSString stringWithFormat:@"%@(%@/%@)",dormName,alreadyIn,bedsNum];
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
    return 48;
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
        UILabel *lbcount = [[UILabel alloc] initWithFrame:CGRectMake(225, 0, 80, 44)];
        lbcount.textAlignment=NSTextAlignmentRight;
        lbcount.textColor=[UIColor grayColor];
        lbcount.font=[UIFont systemFontOfSize:12];
        lbcount.backgroundColor=[UIColor clearColor];
        lbcount.tag=1002;
        lbcount.text=[NSString stringWithFormat:@"%lu%@",(unsigned long)linkManOfGroup.count,@"个房间"];
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
    alertTip = [[OLGhostAlertView alloc] initWithIndicator:@"载入中..." timeout:0 dismissible:NO];
    [alertTip show];
    NSURL *url = [NSURL URLWithString:[kYingXinURL stringByAppendingString:@"baodaoHandle.php"]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    NSError *error;
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init ];
    [dic setObject:@"getBedList" forKey:@"action"];
    [dic setObject:[linkman objectForKey:@"房间名称"] forKey:@"dormName"];
    request.username=@"获取床位";
    NSData *postData=[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
    postStr=[GTMBase64 base64StringBystring:postStr];
    [request setPostValue:postStr forKey:@"DATA"];
    [request setDelegate:self];
    [request setTimeOutSeconds:60];
    [request startAsynchronous];
    [requestArray addObject:request];
}

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
}
-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshBaodaoHandle" object:nil];
    [super viewWillDisappear:animated];
}
-(void)notifyParentControl:(NSDictionary *)dic
{
    NSMutableDictionary *result=[NSMutableDictionary dictionaryWithDictionary:dic];
    [result setObject:@"分配宿舍" forKey:@"action"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshBaodaoHandle" object:nil userInfo:result];
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
    [dic setObject:[teacherInfoDic objectForKey:@"用户名"] forKey:@"userid"];
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
