//
//  DDILinkManGroup.m
//  老师助手
//
//  Created by yons on 14-1-13.
//  Copyright (c) 2014年 dandian. All rights reserved.
//

#import "DDILinkManGroup.h"
extern NSString *kInitURL;
extern NSString *kUserIndentify;
extern Boolean kIOS7;
extern NSMutableDictionary *userInfoDic;//课表数据
extern NSMutableDictionary *teacherInfoDic;//老师数据
extern NSDictionary *LinkMandic;//联系人数据
extern int kUserType;
extern NSMutableDictionary *lastMsgDic;
extern DDIDataModel *datam;
@interface DDILinkManGroup ()

@end

@implementation DDILinkManGroup

- (void)viewDidLoad
{
    [super viewDidLoad];
    arrayRight=[UIImage imageNamed:@"arrowRight"];
    arrayDown=[UIImage imageNamed:@"arrowDown"];
    imageMan=[UIImage imageNamed:@"defaultPerson"];
    imageWoman=[UIImage imageNamed:@"defaultWoman"];
    greenTel=[UIImage imageNamed:@"greenTel"];
    hostUser=[teacherInfoDic objectForKey:@"用户唯一码"];
    
    imageArray=[[NSMutableDictionary alloc]init];
    friendDic=[[NSMutableDictionary alloc]init];
    requestArray=[[NSMutableArray alloc]init];
    
    linkManSavePath=[CommonFunc getLinkManPath:hostUser];
    if([CommonFunc fileIfExist:linkManSavePath])
    {
        LinkMandic=[CommonFunc readFromPlistFile:linkManSavePath];
        [self loadLinkMansFromDic];
    }
    
    
    float height=self.view.frame.size.height-self.tabBarController.tabBar.frame.size.height-self.parentViewController.navigationController.navigationBar.frame.size.height;
    if(kIOS7)
        height-=20;
    self.mTableView = [[TQMultistageTableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,height)];
    if(kIOS7)
        self.mTableView.tableView.separatorInset=UIEdgeInsetsMake(0,0,0,0);
    self.mTableView.delegate = self;
    self.mTableView.dataSource = self;
    [self.view addSubview:self.mTableView];
    headViewArray=[[NSMutableDictionary alloc]init];
    
    //在这里创建搜索栏和搜索显示控制器
    self.searchBar=[[UISearchBar  alloc] initWithFrame:CGRectMake(0.0f, 0.0f,320, 44)];
    self.searchBar.placeholder=[NSString stringWithCString:"请输入姓名搜索"  encoding: NSUTF8StringEncoding];
    self.mTableView.tableView.tableHeaderView=self.searchBar;
    
    self.searchDc=[[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.searchDc.searchResultsDataSource=self.mTableView;
    self.searchDc.searchResultsDelegate=self.mTableView;
    self.searchDc.delegate=self.mTableView;
    [self.searchDc  setActive:NO];
    
    
}

-(void)loadLinkMansFromDic
{
    @try
    {
        groupArray=[LinkMandic objectForKey:@"好友分组"];
        NSDictionary *friendsIdDic=[LinkMandic objectForKey:@"老师好友信息"];
        NSDictionary *duizhaoDic=[LinkMandic objectForKey:@"数据源_用户信息列表_对照表"];
        NSArray *allLinkManArray=[LinkMandic objectForKey:@"数据源_用户信息列表"];
        [friendDic removeAllObjects];
        NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"拼音" ascending:YES]];
        for(int i=0;i<groupArray.count;i++)
        {
            NSString *groupName=[groupArray objectAtIndex:i];
            NSArray *userIdArray=[friendsIdDic objectForKey:groupName];
            NSMutableArray *item=[[NSMutableArray alloc]init];
            for(int j=0;j<userIdArray.count;j++)
            {
                NSString *userId=[userIdArray objectAtIndex:j];
                if([userId isEqualToString:hostUser]) continue;
                NSNumber *key=[duizhaoDic objectForKey:userId];
                if(key==nil)
                    continue;
                NSMutableDictionary *manDic=[[NSMutableDictionary alloc] initWithDictionary:[allLinkManArray objectAtIndex:key.intValue]];
                NSString *userName=[manDic objectForKey:@"姓名"];
                NSString *Pinyin=[[NSString stringWithFormat:@"%c",pinyinFirstLetter([userName characterAtIndex:0])]uppercaseString];
                Pinyin=[Pinyin stringByAppendingString:userName];
                [manDic setObject:Pinyin forKey:@"拼音"];
                [manDic setObject:userId forKey:@"用户唯一码"];
                [item addObject:manDic];
            }
            [item sortUsingDescriptors:sortDescriptors];
            [friendDic setObject:item forKey:groupName];
        }
    }
    @catch(NSException * e)
    {
        NSLog(@"Exception: %@", e);
    }
}
-(void)viewWillAppear:(BOOL)animated
{
    self.parentViewController.navigationItem.title=@"联系人";
}
-(void)viewDidAppear:(BOOL)animated
{
    if(lastMsgDic==nil && kUserIndentify)
    {
        [self getLastMsgDic];
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(tableView==self.mTableView.tableView)
        return groupArray.count;
    else
        return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    if(tableView==self.mTableView.tableView)
    {
        NSArray *linkManOfGroup=[friendDic objectForKey:groupArray[section]];
        return linkManOfGroup.count;
    }
    else
        return filteredMessages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"TQMultistageTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        if(kIOS7)
            cell.separatorInset=UIEdgeInsetsMake(0, 0, 0, 0);
        //cell.imageView.layer.cornerRadius = 5;
        //cell.imageView.layer.masksToBounds = YES;
        UIButton *action = [[UIButton alloc] initWithFrame:CGRectMake(320-60, 0, 60, 44)];
        action.titleLabel.tag=indexPath.section;
        //action.backgroundColor=[UIColor grayColor];
        [action addTarget:self action:@selector(detailButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        //cell.accessoryType=UITableViewCellAccessoryDetailButton;
        cell.accessoryView=action;
        [cell.imageView setUserInteractionEnabled:YES];
        UIButton *btn=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
        //btn.backgroundColor=[UIColor grayColor];
        btn.tag=11;
        [btn addTarget:self action:@selector(headBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [cell.imageView addSubview:btn];
        [cell.imageView.layer setMasksToBounds:YES];
        [cell.imageView.layer setCornerRadius:5.0];
    }
    NSDictionary *linkman=nil;
    if(tableView==self.mTableView.tableView)
    {
        NSArray *linkManOfGroup=[friendDic objectForKey:groupArray[indexPath.section]];
        linkman=[linkManOfGroup objectAtIndex:indexPath.row];
    }
    else
        linkman=[filteredMessages objectAtIndex:indexPath.row];
    
    
    NSString *userid=[linkman objectForKey:@"用户唯一码"];
    NSString *userName=[linkman objectForKey:@"姓名"];
    NSString *sex=[linkman objectForKey:@"性别"];
    NSString *picUrl=[linkman objectForKey:@"用户头像"];
    NSString *tel=[linkman objectForKey:@"手机"];
    if(tel==nil)
        tel=[linkman objectForKey:@"学生电话"];
    
    cell.detailTextLabel.text=@"";
    if(lastMsgDic && lastMsgDic.count>0)
    {
        NSDictionary *item=[lastMsgDic objectForKey:userid];
        if(item)
        {
            NSDictionary *lastMsg=[item objectForKey:@"最后一次聊天记录"];

            if([lastMsg objectForKey:@"TYPE"]==nil || [[lastMsg objectForKey:@"TYPE"] isEqualToString:@"txt"])
                cell.detailTextLabel.text=([[lastMsg objectForKey:@"CONTENT"] isEqual:[NSNull null]]?@"":[lastMsg objectForKey:@"CONTENT"]);
            else
                cell.detailTextLabel.text=@"[图片]";
        }
    }

    cell.textLabel.text=userName;
    UIButton *btn=(UIButton *)[cell.imageView viewWithTag:11];
    btn.titleLabel.text=userid;
    
    UIButton *callBtn=(UIButton *)cell.accessoryView;
    if(tel.length==11 && kUserType==1)
    {
        //[callBtn setBackgroundImage:greenTel forState:UIControlStateNormal];
        [callBtn setImage:greenTel forState:UIControlStateNormal];
        
    }
    else
    {
        //[callBtn setBackgroundImage:nil forState:UIControlStateNormal];
        [callBtn setImage:nil forState:UIControlStateNormal];
    }
    
    UIImage *img=[imageArray objectForKey:userid];
    if (img==Nil)
    {
        NSString *userPic=[CommonFunc getImageSavePath:userid ifexist:YES];
        
        if(userPic)
        {
            UIImage *headImage=[UIImage imageWithContentsOfFile:userPic];
            CGSize newSize=CGSizeMake(40, 40);
            headImage=[headImage scaleToSize1:newSize];
            headImage=[headImage cutFromImage:CGRectMake(0, 0, 40, 40)];
            [imageArray setObject:headImage forKey:userid];
            cell.imageView.image=headImage;
        }
        else
        {
            if(picUrl && picUrl.length>0)
            {
                NSURL *url = [NSURL URLWithString:picUrl];
                ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
                request.username=userid;
                NSMutableDictionary *indexDic=[[NSMutableDictionary alloc]init];
                [indexDic setObject:indexPath forKey:@"indexPath"];
                request.userInfo=indexDic;
                [request setDelegate:self];
                [request startAsynchronous];
                [requestArray addObject:request];
            }
            if([sex isEqualToString:@"女"])
                cell.imageView.image=imageWoman;
            else
                cell.imageView.image=imageMan;
        }
    }
    else
    {
        cell.imageView.image=img;
        
    }

    return cell;
}
-(void)headBtnClick:(UIButton *)sender
{
    NSString *text=sender.titleLabel.text;
    NSArray *textArray=[text componentsSeparatedByString:@"_"];
    
    if([[textArray objectAtIndex:1] isEqualToString:@"学生"] && kUserType==1)
    {
        [self performSegueWithIdentifier:@"theStudentInfor" sender:sender];
        
    }
    else
        [self performSegueWithIdentifier:@"theTeacherInfor" sender:sender];
}
-(void)detailButtonClicked:(UIButton *)sender
{
    
    UIView *parent=[sender superview];
    while(![parent isKindOfClass:[UITableViewCell class]])
        parent=[parent superview];
    UITableViewCell *cell=(UITableViewCell *)parent;
    while(![parent isKindOfClass:[UITableView class]])
        parent=[parent superview];
    UITableView *tableView=(UITableView *)parent;
    
    NSIndexPath *indexPath=[self.mTableView indexPathForCell:cell];
    NSDictionary *linkman=nil;
    if(tableView==self.mTableView.tableView)
    {
        NSArray *linkManOfGroup=[friendDic objectForKey:groupArray[indexPath.section]];
        linkman=[linkManOfGroup objectAtIndex:indexPath.row];
    }
    else
        linkman=[filteredMessages objectAtIndex:indexPath.row];
    NSString *tel=[linkman objectForKey:@"手机"];
    if(tel==nil)
        tel=[linkman objectForKey:@"学生电话"];
    if(tel.length==11)
    {
        tel=[@"tel://" stringByAppendingString:tel];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:tel]];
    }
    NSLog(@"拨打电话：%@",tel);
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
        lbcount.text=[NSString stringWithFormat:@"%lu人",(unsigned long)linkManOfGroup.count];
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
    UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"gotoChat" sender:cell];
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"gotoChat"])
    {
        NSDictionary *linkman=nil;
        UITableViewCell *cell=sender;
        UITableView *tableView;
        if(kIOS7)
            tableView=(UITableView *)cell.superview.superview;
        else
            tableView=(UITableView *)cell.superview;
        NSIndexPath *indexPath=[tableView indexPathForCell:cell];
        if(tableView==self.mTableView.tableView)
        {
            NSArray *linkManOfGroup=[friendDic objectForKey:groupArray[indexPath.section]];
            linkman=[linkManOfGroup objectAtIndex:indexPath.row];
        }
        else
        {
            linkman=[filteredMessages objectAtIndex:indexPath.row];
            [self.searchDc  setActive:NO];
        }
        
        
        NSString *userId=[linkman objectForKey:@"用户唯一码"];
        NSString *userName=[linkman objectForKey:@"姓名"];
        DDIChatView *chatView=segue.destinationViewController;
        chatView.respondName=userName;
        chatView.respondUser=userId;
        
    }
    else if([segue.identifier isEqualToString:@"theTeacherInfor"])
    {
        UIButton *btn=(UIButton *)sender;
        DDIMyInforView *view=segue.destinationViewController;
        view.userWeiYi=btn.titleLabel.text;
    }else if([segue.identifier isEqualToString:@"theStudentInfor"])
    {
        UIButton *btn=(UIButton *)sender;
        DDIStudentInfo *view=segue.destinationViewController;
        view.userWeiYi=btn.titleLabel.text;
    }

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

- (void)getLinkManGroup {
    if(groupArray==nil || groupArray.count==0)
    {
        alertTip = [[OLGhostAlertView alloc] initWithTitle:@"正在获取联系人列表" message:nil timeout:0 dismissible:NO];
        [alertTip showInView:self.view];
    }

    NSURL *url = [NSURL URLWithString:[kInitURL stringByAppendingString:@"GetTeacherInfo.php?IsZip=1"]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    NSError *error;
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init ];
    [dic setObject:kUserIndentify forKey:@"用户较验码"];
    NSNumber *timeStamp=[[NSNumber alloc] initWithLong:[[NSDate new] timeIntervalSince1970]];
    [dic setObject:timeStamp forKey:@"DATETIME"];
    request.username=@"获取联系人";
    NSData *postData=[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
    postStr=[GTMBase64 base64StringBystring:postStr];
    [request setPostValue:postStr forKey:@"DATA"];
    [request setDelegate:self];
    [request startAsynchronous];
    [requestArray addObject:request];

}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    if([request.username isEqualToString:@"获取联系人"])
    {
        if(alertTip)
           [alertTip removeFromSuperview];
        NSData *data = [request responseData];
        NSString* dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSData *_decodedData   = [[NSData alloc] initWithBase64Encoding:dataStr];
        NSData *upzipData = [LFCGzipUtillity uncompressZippedData:_decodedData];
        dataStr = [[NSString alloc] initWithData:upzipData encoding:NSUTF8StringEncoding];
        
        if(dataStr.length==0)
        {
            OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"获取联系人失败"];
            [tipView show];
            return;
        }
        LinkMandic= [NSJSONSerialization JSONObjectWithData:upzipData options:NSJSONReadingAllowFragments error:nil];
        
        if([CommonFunc writeToPlistFile:linkManSavePath dic:LinkMandic])
            NSLog(@"通讯薄已保存");
        else
            NSLog(@"通讯薄保存失败");
        [self loadLinkMansFromDic];
        
        /*
        [datam clearLinkManGroup];
        for(int i=0;i<groupArray.count;i++)     
        {
            NSString *groupName=[groupArray objectAtIndex:i];
            [datam insertLinkManGroup:groupName];
            [datam clearLinkMans:groupName];
            NSArray *friendIdArray=[friendsIdDic objectForKey:groupName];
            for(int j=0;j<friendIdArray.count;j++)
            {
                NSString *userid=[friendIdArray objectAtIndex:j];
                NSNumber *index=[duizhaoDic objectForKey:userid];
                NSDictionary *item=[allLinkManArray objectAtIndex:index.intValue];
                LinkMan *linkman=[[LinkMan alloc]init];
                linkman.userId=userid;
                linkman.groupName=groupName;
                linkman.userName=[item objectForKey:@"姓名"];
                linkman.sex=[item objectForKey:@"性别"];
                if([item objectForKey:@"手机"])
                    linkman.tel=[item objectForKey:@"手机"];
                else if([item objectForKey:@"学生电话"])
                    linkman.tel=[item objectForKey:@"学生电话"];
                else
                    linkman.tel=@"";
                linkman.headImage=[item objectForKey:@"用户头像"];
                NSString *singlePinyinLetter=[[NSString stringWithFormat:@"%c",pinyinFirstLetter([linkman.userName characterAtIndex:0])]uppercaseString];
                linkman.pinyin=[singlePinyinLetter stringByAppendingString:linkman.userName];
                [datam insertLinkMan:linkman];
            }
            
        }
        [self loadLinkMansFromDB];
        */
        
        [self.mTableView reloadData];
        
    }
    else if([request.username isEqualToString:@"最后一次聊天记录"])
    {
        NSData *data = [request responseData];
        NSString* dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        dataStr=[GTMBase64 stringByBase64String:dataStr];
        data = [dataStr dataUsingEncoding: NSUTF8StringEncoding];
        NSDictionary *resultDic= [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        if(resultDic && resultDic.count>0)
        {
            lastMsgDic=[[NSMutableDictionary alloc] initWithDictionary:resultDic];
        }
        else
            lastMsgDic=[NSMutableDictionary dictionary];
        
    }
    else
    {
        NSData *datas = [request responseData];
        UIImage *headImage=[[UIImage alloc]initWithData:datas];
        if(headImage!=nil)
        {
            NSString *path=[CommonFunc getImageSavePath:request.username ifexist:NO];
            [datas writeToFile:path atomically:YES];
            headImage=[headImage scaleToSize1:CGSizeMake(40, 40)];
            CGRect newSize=CGRectMake(0, 0,40,40);
            headImage=[headImage cutFromImage:newSize];
            [imageArray setObject:headImage forKey:request.username];
            NSDictionary *indexDic=request.userInfo;
            NSIndexPath *indexPath=[indexDic objectForKey:@"indexPath"];
            UITableViewCell *cell=[self.mTableView cellForRowAtIndexPath:indexPath];
            if(cell)
                [self.mTableView reloadDataWithTableViewCell:cell];
        }
    }
    if([requestArray containsObject:request])
        [requestArray removeObject:request];
    request=nil;
}
-(void)getLastMsgDic
{
    NSURL *url = [NSURL URLWithString:[kInitURL stringByAppendingString:@"SendSMS_GetLast_ATOALL.php"]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    NSError *error;
    request.username=@"最后一次聊天记录";
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init];
    [dic setObject:kUserIndentify forKey:@"用户较验码"];
    NSNumber *timeStamp=[[NSNumber alloc] initWithLong:[[NSDate new] timeIntervalSince1970]];
    [dic setObject:timeStamp forKey:@"DATETIME"];
    
    NSData *postData=[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
    postStr=[GTMBase64 base64StringBystring:postStr];
    [request setPostValue:postStr forKey:@"DATA"];
    [request setDelegate:self];
    [request startAsynchronous];
    [requestArray addObject:request];
}
-(void)dealloc
{
    for(ASIHTTPRequest *req in requestArray)
    {
        [req clearDelegatesAndCancel];
    }
}
- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    filteredMessages = [LinkMandic objectForKey:@"数据源_用户信息列表"];
}
- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    filteredMessages = nil;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    filteredMessages = [LinkMandic objectForKey:@"数据源_用户信息列表"];
    filteredMessages = [filteredMessages filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.XingMing contains[cd] %@", searchString]];
    
    return YES;
}

@end
