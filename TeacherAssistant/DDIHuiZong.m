//
//  DDIHuiZong.m
//  掌上校园
//
//  Created by yons on 14-3-8.
//  Copyright (c) 2014年 dandian. All rights reserved.
//

#import "DDIHuiZong.h"
extern NSString *kInitURL;//默认单点webServic
extern NSString *kUserIndentify;//用户登录后的唯一识别码
extern NSDictionary *teacherInfoDic;
extern DDIDataModel *datam;
@interface DDIHuiZong ()

@end

@implementation DDIHuiZong


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //设置导航栏菜单
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 100.0, 29.0, 29.0)];
    [backBtn setTitle:@"" forState:UIControlStateNormal];
    [backBtn setBackgroundImage:[UIImage imageNamed:@"mainMenu"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(mainMenuAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backBarBtn = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.parentViewController.navigationItem.leftBarButtonItem=backBarBtn;
    
    self.collectionView.backgroundColor=[UIColor colorWithRed:228/255.0 green:244/255.0 blue:234/255.0 alpha:1];
	requestArray=[NSMutableArray array];
    titleArray=[NSMutableArray array];
    unreadDic=[NSDictionary dictionary];
    savepath=[CommonFunc createPath:@"/utils/"];
    [self loadTitleData];
    
    //载入第二个tabItem
    UITabBarController *TabBarView=(UITabBarController *)self.parentViewController;
    DDIClassSchedule *tabItem1=[TabBarView.childViewControllers objectAtIndex:1];
    TabBarView.selectedViewController=tabItem1;
    DDIMessageList *tabItem2=[TabBarView.childViewControllers objectAtIndex:2];
    TabBarView.selectedViewController=tabItem2;
    DDILinkManGroup *tabItem3=[TabBarView.childViewControllers objectAtIndex:3];
    TabBarView.selectedViewController=tabItem3;
    [tabItem3 getLinkManGroup];
    
    TabBarView.selectedViewController=self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getAlbumUnreadCount)
                                                 name:@"newAlbumMessage"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadTitleData)
                                                 name:@"reloadNotice"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateBadge)
                                                 name:@"updateBadge"
                                               object:nil];
    [self getAlbumUnreadCount];

}
-(void)getAlbumUnreadCount
{
    UITabBarItem *baritem=[self.tabBarController.tabBar.items objectAtIndex:4];
    int msgcount=(int)[datam getAlbumUnreadCount:[teacherInfoDic objectForKey:@"用户唯一码"]];
    if(msgcount>0)
        baritem.badgeValue=[NSString stringWithFormat:@"%d",(msgcount>99?99:msgcount)];
    else
        baritem.badgeValue=nil;
    
    
}
-(void) mainMenuAction
{
   // [self performSegueWithIdentifier:@"gotoMenu" sender:nil];
    [(XHDrawerController *)self.parentViewController.parentViewController.parentViewController toggleDrawerSide:XHDrawerSideLeft animated:YES completion:NULL];
    if ([[SidebarViewController share] respondsToSelector:@selector(mainMenuAction)]) {
        [[SidebarViewController share] mainMenuAction];
    }
}
-(void)loadTitleData
{
    NSURL *url = [NSURL URLWithString:[kInitURL stringByAppendingString:@"InterfaceStudent/XUESHENG.PHP"]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    NSError *error;
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init ];
    [dic setObject:kUserIndentify forKey:@"用户较验码"];
    NSNumber *timeStamp=[[NSNumber alloc] initWithLong:[[NSDate new] timeIntervalSince1970]];
    [dic setObject:timeStamp forKey:@"DATETIME"];
    request.username=@"初始化标题";
    NSData *postData=[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
    postStr=[GTMBase64 base64StringBystring:postStr];
    [request setPostValue:postStr forKey:@"DATA"];
    [request setDelegate:self];
    request.timeOutSeconds=300;
    [request startAsynchronous];
    [requestArray addObject:request];
    
}
-(void)getUnreadFromServer
{
    
        NSURL *url = [NSURL URLWithString:[kInitURL stringByAppendingString:@"InterfaceStudent/count.php"]];
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        NSError *error;
        NSMutableDictionary *dic=[[NSMutableDictionary alloc] init ];
        [dic setObject:kUserIndentify forKey:@"用户较验码"];
        NSNumber *timeStamp=[[NSNumber alloc] initWithLong:[[NSDate new] timeIntervalSince1970]];
        [dic setObject:timeStamp forKey:@"DATETIME"];
        request.username=@"获取未读数";
        NSData *postData=[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
        NSString *postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
        postStr=[GTMBase64 base64StringBystring:postStr];
        [request setPostValue:postStr forKey:@"DATA"];
        [request setDelegate:self];
        [request startAsynchronous];
        [requestArray addObject:request];
    
        
}
-(void)viewWillAppear:(BOOL)animated
{
    self.parentViewController.navigationItem.title=self.title;
    [self updateBadge];
    if(needCount)
        [self getUnreadFromServer];
    [super viewWillAppear:animated];
}
-(void)dealloc
{
    for(ASIHTTPRequest *req in requestArray)
    {
        [req clearDelegatesAndCancel];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"newAlbumMessage" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"reloadNotice" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateBadge" object:nil];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)requestFinished:(ASIHTTPRequest *)request
{
    if([request.username isEqualToString:@"初始化标题"])
    {
        
        NSData *data = [request responseData];
        NSString* dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        data   = [[NSData alloc] initWithBase64Encoding:dataStr];
        NSArray *tmpArray= [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        if(tmpArray)
            titleArray=[NSMutableArray arrayWithArray:tmpArray];
        if(titleArray.count==0)
        {
            OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"没有任何数据"];
            [tipView showInView:self.collectionView];
        }
        else
        {
            [self.collectionView reloadData];
            for(NSDictionary *item in titleArray)
            {
                if([[item objectForKey:@"模板名称"] isEqualToString:@"通知"])
                {
                    NSString *wenzi=[item objectForKey:@"文字"];
                    [self getNewsList:[datam getMaxNewsId:wenzi userId:kUserIndentify] Item:item];
                }
                else if ([[item objectForKey:@"模板名称"] isEqualToString:@"浏览器"])
                    needCount=true;
            }
            if(needCount)
                [self getUnreadFromServer];
           
        }
    }
    if([request.username isEqualToString:@"获取未读数"])
    {
        
        NSData *data = [request responseData];
        NSString* dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        data   = [[NSData alloc] initWithBase64Encoding:dataStr];
        unreadDic=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        
        [self updateBadge];
        
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
            [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
        }
    }
    else if([request.username isEqualToString:@"获取新闻"])
    {
        NSData *data = [request responseData];
        NSString* dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        dataStr=[GTMBase64 stringByBase64String:dataStr];
        data = [dataStr dataUsingEncoding: NSUTF8StringEncoding];
        NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        if(dict)
        {
            NSArray *newsList=[dict objectForKey:@"通知项"];
            NSDictionary *olddic=request.userInfo;
            NSString *newsType=[olddic objectForKey:@"文字"];
            //NSString *interface=[olddic objectForKey:@"接口地址"];
            for(NSDictionary *item in newsList)
            {
                NSMutableDictionary *newItem=[NSMutableDictionary dictionaryWithDictionary:item];
                NSString *newUrl=[NSString stringWithFormat:@"%@",[newItem objectForKey:@"最下边一行URL"]];
                [newItem setObject:newUrl forKey:@"最下边一行URL"];
                [newItem setObject:kUserIndentify forKey:@"用户唯一码"];
                [datam insertNewsRecord:newItem newsType:newsType];
            }
            [self updateBadge];
            
        }
        
        
    }
}
-(void)updateBadge
{
    if(unreadDic==Nil)
        unreadDic=[NSDictionary dictionary];
    
    allUnread=0;
    NSMutableArray *indexArray=[NSMutableArray array];
    for(int i=0;i<titleArray.count;i++)
    {
        NSMutableDictionary *item=[NSMutableDictionary dictionaryWithDictionary:[titleArray objectAtIndex:i]];
        if([[item objectForKey:@"模板名称"] isEqualToString:@"通知"])
        {
            NSString *newsType=[item objectForKey:@"文字"];
            int unread=[datam getUnreadNews:newsType userId:kUserIndentify];
            if(unread>0)
                allUnread=allUnread+unread;
            [item setObject:[NSNumber numberWithInt:unread] forKey:@"未读"];
            [titleArray replaceObjectAtIndex:i withObject:item];
            NSIndexPath *indexPath=[NSIndexPath indexPathForRow:i inSection:0];
            [indexArray addObject:indexPath];
        }
        else if([[item objectForKey:@"模板名称"] isEqualToString:@"浏览器"])
        {
            NSString *newsType=[item objectForKey:@"文字"];
            NSString *unreadStr=[unreadDic objectForKey:newsType];
            int unread=unreadStr.intValue;
            NSString *oldunreadStr=[item objectForKey:@"未读"];
            if(unread!=oldunreadStr.intValue)
            {
                allUnread=allUnread+unread;
                [item setObject:[NSNumber numberWithInt:unread] forKey:@"未读"];
                [titleArray replaceObjectAtIndex:i withObject:item];
                NSIndexPath *indexPath=[NSIndexPath indexPathForRow:i inSection:0];
                [indexArray addObject:indexPath];
            }
        }
    }
    if(allUnread>0)
        self.tabBarItem.badgeValue=[NSString stringWithFormat:@"%d",(allUnread>99?99:allUnread)];
    else
        self.tabBarItem.badgeValue=nil;
    if(indexArray.count>0)
    {
        [self.collectionView reloadData];
       
    }
    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"请求失败:%@",[error localizedDescription]);
    OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:[error localizedDescription]];
    [tipView show];
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView;
{
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return titleArray.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    UICollectionViewCell *cell = (UICollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"colCell" forIndexPath:indexPath];
    NSDictionary *item=[titleArray objectAtIndex:indexPath.row];
    NSString *urlStr=[item objectForKey:@"图标"];
    NSArray *iconArray=[urlStr componentsSeparatedByString:@"/"];
    NSString *iconName=[iconArray objectAtIndex:iconArray.count-1];
    
    NSString *filename=[savepath stringByAppendingString:iconName];
    UIImageView *imgv=(UIImageView *)[cell viewWithTag:101];
    UILabel *lbl=(UILabel *)[cell viewWithTag:102];
    lbl.text=[item objectForKey:@"文字"];
    if([CommonFunc fileIfExist:filename])
    {
        UIImage *img=[UIImage imageWithContentsOfFile:filename];
        imgv.image=img;
    }
    else
    {
        urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString:urlStr];
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        request.username=@"下载图片";
        NSMutableDictionary *indexDic=[[NSMutableDictionary alloc]init];
        [indexDic setObject:filename forKey:@"filename"];
        [indexDic setObject:indexPath forKey:@"indexPath"];
        request.userInfo=indexDic;
        [request setDelegate:self];
        [request startAsynchronous];
        [requestArray addObject:request];
    }
    for(JSBadgeView *subview in imgv.subviews)
    {
        [subview removeFromSuperview];
    }
    JSBadgeView *badgeView = [[JSBadgeView alloc] initWithParentView:imgv alignment:JSBadgeViewAlignmentTopRight];
    badgeView.badgePositionAdjustment=CGPointMake(-6,3);
    badgeView.badgeTextShadowOffset=CGSizeMake(-1, 1);
    /*
    JSBadgeView *badgeView=[badgeDic objectForKey:lbl.text];
    if(badgeView==nil)
    {
        badgeView = [[JSBadgeView alloc] initWithParentView:imgv alignment:JSBadgeViewAlignmentTopRight];
        badgeView.badgePositionAdjustment=CGPointMake(-6,5);
        badgeView.badgeTextShadowOffset=CGSizeMake(-1, 1);
        [badgeDic setObject:badgeView forKey:lbl.text];
        
    }
    */
    NSNumber *unRead=[item objectForKey:@"未读"];
    if(unRead.intValue>0)
    {
        
        badgeView.badgeText = [NSString stringWithFormat:@"%d",unRead.intValue];

    }
    else
        badgeView.badgeText =nil;
    

    return cell;
    
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
{
    NSDictionary *item=[titleArray objectAtIndex:indexPath.row];
    NSString *modelName=[item objectForKey:@"模板名称"];
    if([modelName isEqualToString:@"通知"])
    {
        [self performSegueWithIdentifier:@"News" sender:item];
    }
    if([modelName isEqualToString:@"考勤"])
    {
        [self performSegueWithIdentifier:@"kaoqin" sender:item];
    }
    if([modelName isEqualToString:@"成绩"])
    {
        [self performSegueWithIdentifier:@"chengji" sender:item];
    }
    if([modelName isEqualToString:@"调查问卷"])
    {
        [self performSegueWithIdentifier:@"wenjuan" sender:item];
    }
    if([modelName isEqualToString:@"浏览器"])
    {
        NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
        NSString *userName = [userDefaultes stringForKey:@"用户名"];
        NSString *password = [userDefaultes stringForKey:@"密码"];
        userName=[[userName componentsSeparatedByString:@"@"] objectAtIndex:0];
        DDIHelpView *controller=[self.storyboard instantiateViewControllerWithIdentifier:@"HelpView"];
        controller.navigationItem.title=[item objectForKey:@"文字"];
        controller.urlStr=[NSString stringWithFormat:@"%@&username=%@&password=%@",[item objectForKey:@"接口地址"],userName,password];
        [self.navigationController pushViewController:controller animated:YES];

    }
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSDictionary *dic=(NSDictionary *)sender;
    NSString *name=[dic objectForKey:@"文字"];
    if([segue.identifier isEqualToString:@"News"])
    {
        DDINewsTitle *newsTitle=segue.destinationViewController;
        newsTitle.title=name;
        newsTitle.newsType=name;
        newsTitle.interfaceUrl=[dic objectForKey:@"接口地址"];
    }
    if([segue.identifier isEqualToString:@"kaoqin"])
    {
        DDIKaoQinTitle *newsTitle=segue.destinationViewController;
        newsTitle.title=name;
        newsTitle.interfaceUrl=[dic objectForKey:@"接口地址"];
    }
    if([segue.identifier isEqualToString:@"chengji"])
    {
        DDIChengjiTitle *newsTitle=segue.destinationViewController;
        newsTitle.title=name;
        newsTitle.interfaceUrl=[dic objectForKey:@"接口地址"];
    }
    if([segue.identifier isEqualToString:@"wenjuan"])
    {
        DDIWenJuanTitle *newsTitle=segue.destinationViewController;
        newsTitle.title=name;
        newsTitle.interfaceUrl=[dic objectForKey:@"接口地址"];
    }
}
- (void)getNewsList:(int)maxId Item:(NSDictionary *)item
{
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init ];
    [dic setObject:kUserIndentify forKey:@"用户较验码"];
    [dic setObject:[NSNumber numberWithInt:maxId]  forKey:@"LASTID"];
    NSError *error;
    NSData *postData=[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
    postStr=[GTMBase64 base64StringBystring:postStr];
    NSString *interface=[item objectForKey:@"接口地址"];
    NSString *urlStr=[NSString stringWithFormat:@"%@InterfaceStudent/%@",kInitURL,interface];
    NSURL *url = [NSURL URLWithString:urlStr];
    ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:postStr forKey:@"DATA"];
    [request setDelegate:self];
    request.username=@"获取新闻";
    request.timeOutSeconds=60;
    request.userInfo=item;
    [request startAsynchronous];
    [requestArray addObject:request];
}
@end
