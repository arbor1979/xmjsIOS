//
//  DDIHuiZong.m
//  掌上校园
//
//  Created by yons on 14-3-8.
//  Copyright (c) 2014年 dandian. All rights reserved.
//

#import "DDIHuiZong.h"
extern NSString *kInitURL;//默认单点webServic
extern NSString *kYingXinURL;
extern NSString *kUserIndentify;//用户登录后的唯一识别码
extern NSDictionary *teacherInfoDic;
extern DDIDataModel *datam;
extern NSString *kStuState;
extern NSMutableDictionary *userInfoDic;//用户所有数据
extern int kSchoolId;
@interface DDIHuiZong ()

@end

@implementation DDIHuiZong

static NSString *leaveDetailsHeadID = @"leaveDetailsHeadID";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if([kStuState isEqualToString:@"新生状态"])
    {
        UIButton *leftCustomButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 29, 29)];
        [leftCustomButton setBackgroundImage:[UIImage imageNamed:@"relogin"] forState:UIControlStateNormal];
        [leftCustomButton addTarget:self action:@selector(reLogin) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem * leftButtonItem =[[UIBarButtonItem alloc] initWithCustomView: leftCustomButton];
        self.parentViewController.navigationItem.leftBarButtonItems = @[leftButtonItem];
    }
    else
    {
        //设置导航栏菜单
        UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 100.0, 29.0, 29.0)];
        [backBtn setTitle:@"" forState:UIControlStateNormal];
        [backBtn setBackgroundImage:[UIImage imageNamed:@"mainMenu"] forState:UIControlStateNormal];
        [backBtn addTarget:self action:@selector(mainMenuAction) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *backBarBtn = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
        self.parentViewController.navigationItem.leftBarButtonItem=backBarBtn;
    }
    
    NSMutableArray *tabbarItems=[NSMutableArray arrayWithArray:self.tabBarController.viewControllers];
    NSArray * tmparray = [NSArray arrayWithArray: tabbarItems];
    for(UINavigationController *nav in tmparray)
    {
        if([kStuState isEqualToString:@"新生状态"])
        {
            if([nav.restorationIdentifier isEqualToString:@"kebiaoStoryboardID"])
                [tabbarItems removeObject:nav];
            else if([nav.restorationIdentifier isEqualToString:@"linkmanStoryboardID"])
                [tabbarItems removeObject:nav];
        }
        else if([kStuState isEqualToString:@"班主任"] || [kStuState isEqualToString:@"迎新管理员"])
        {
            if([nav.restorationIdentifier isEqualToString:@"baodaoStoryboardID"])
                [tabbarItems removeObject:nav];
            else if([nav.restorationIdentifier isEqualToString:@"xiangceStoryboardID"])
                [tabbarItems removeObject:nav];
        }
        else
        {
            if([nav.restorationIdentifier isEqualToString:@"mystatusStoryboardID"])
                [tabbarItems removeObject:nav];
            else if([nav.restorationIdentifier isEqualToString:@"baodaoStoryboardID"])
                [tabbarItems removeObject:nav];
        }
        
    }
    [self.tabBarController setViewControllers:tabbarItems];
    
    //载入第二个tabItem
    UITabBarController *tabBarView=(UITabBarController *)self.parentViewController;
    for(UIViewController *item in tabBarView.childViewControllers)
    {
        if([item isKindOfClass:[DDIMessageList class]] || [item isKindOfClass:[DDILinkManGroup class]])
            tabBarView.selectedViewController=item;
        if([item isKindOfClass:[DDILinkManGroup class]])
            [(DDILinkManGroup *)item getLinkManGroup];
        else if([item isKindOfClass:[DDIMessageList class]])
        {
            DDIMessageList *itemcontroller=(DDIMessageList *)item;
            [itemcontroller getNewMessageFromDB:nil];
        }
        
        
    }
    tabBarView.selectedViewController=self;
    
    //self.collectionView.backgroundColor=[UIColor colorWithRed:228/255.0 green:244/255.0 blue:234/255.0 alpha:1];
    self.collectionView.backgroundColor=[UIColor whiteColor];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:leaveDetailsHeadID];
	requestArray=[NSMutableArray array];
    titleArray=[NSMutableArray array];
    unreadDic=[NSDictionary dictionary];
    savepath=[CommonFunc createPath:@"/utils/"];
    [self loadTitleData];
    
    
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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pushtoad)
                                                 name:@"pushtoad"
                                               object:nil];
    [self getAlbumUnreadCount];
    
    // 1.判断沙盒中是否存在广告图片，如果存在，直接显示
    
    NSString *imgFileName=[kUserDefaults valueForKey:adImageName];
    NSDictionary *advDic=[userInfoDic objectForKey:@"广告设置"];
    NSString *picUrl=nil;
    if(advDic!=nil && [advDic isKindOfClass:[NSDictionary class]])
        picUrl=[advDic objectForKey:@"图片"];
    if(picUrl!=nil && picUrl.length>0)
    {
        NSNumber *second=[advDic objectForKey:@"显示秒数"];
        NSString *filename=[CommonFunc getFileRealName:picUrl];
        if(imgFileName!=nil && [imgFileName isEqualToString:filename])
        {
            NSString *filePath = [savepath stringByAppendingString:imgFileName];
            if([CommonFunc fileIfExist:filePath])
            {
                NSString *jumpUrl=[advDic objectForKey:@"跳转URL"];
                [kUserDefaults setValue:jumpUrl forKey:adUrl];
                [kUserDefaults synchronize];
                [self showAdvView:filePath second:second.intValue];
            }
            else
               [self downloadAdvImg:picUrl advDic:advDic];
        }
        else
        {
            [self downloadAdvImg:picUrl advDic:advDic];
        }
    }
   
}
-(void)pushtoad
{
    NSString *urlStr=[kUserDefaults valueForKey:adUrl];
    if(urlStr!=nil && urlStr.length>0)
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
}
-(void)downloadAdvImg:(NSString *)picUrl advDic:(NSDictionary *)advDic
{
    NSURL *url = [NSURL URLWithString:picUrl];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    request.username=@"下载广告图片";
    request.userInfo=advDic;
    [request setDelegate:self];
    [request startAsynchronous];
    [requestArray addObject:request];
}
-(void)showAdvView:(NSString *)filePath second:(int)second
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    AdvertiseView *advertiseView = [[AdvertiseView alloc] initWithFrame:window.bounds];
    advertiseView.filePath = filePath;
    advertiseView.showtime=second;
    [advertiseView show];
}
-(void)reLogin
{
    kUserIndentify=nil;
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    [userDefaultes setObject:nil forKey:@"用户名"];
    DDIVLoginMain *loginController = [self.storyboard instantiateViewControllerWithIdentifier:@"loginmain"];
    [UIApplication sharedApplication].keyWindow.rootViewController=loginController;
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
    NSURL *url = nil;
    if([kStuState isEqualToString:@"新生状态"])
        url=[NSURL URLWithString:[kYingXinURL stringByAppendingString:@"school-module.php"]];
    else
        url=[NSURL URLWithString:[kInitURL stringByAppendingString:@"InterfaceStudent/XUESHENG.PHP"]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    NSError *error;
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init ];
    [dic setObject:kUserIndentify forKey:@"用户较验码"];
    NSNumber *timeStamp=[[NSNumber alloc] initWithLong:[[NSDate new] timeIntervalSince1970]];
    [dic setObject:timeStamp forKey:@"DATETIME"];
    if(kStuState!=nil)
        [dic setObject:kStuState forKey:@"学生状态"];
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
        NSMutableDictionary *funcObj=[NSMutableDictionary dictionary];
        if(titleArray.count==0)
            return;
        for(NSDictionary *item in titleArray)
        {
            if([[item objectForKey:@"是否有角标"] isEqualToString:@"是"])
            {
                NSString *wenzi=[item objectForKey:@"文字"];
                [funcObj setObject:[item objectForKey:@"接口地址"] forKey:wenzi];
            }
        }
        [dic setObject:funcObj forKey:@"funcObj"];
        request.username=@"获取未读数";
        NSData *postData=[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
        NSString *postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
        postStr=[GTMBase64 base64StringBystring:postStr];
        [request setPostValue:postStr forKey:@"DATA"];
        [request setDelegate:self];
        [request startAsynchronous];
        [requestArray addObject:request];
    
        
}
-(void)viewDidAppear:(BOOL)animated
{
    self.parentViewController.navigationItem.title=@"厦门技师学院";
    self.parentViewController.navigationItem.rightBarButtonItem=nil;
    [self updateBadge];
//[self getUnreadFromServer];
    [super viewDidAppear:animated];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"pushtoad" object:nil];
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
        data   = [[NSData alloc] initWithBase64EncodedString:dataStr options:0];
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
            moduleGroup=[NSMutableArray array];
            moduleList=[NSMutableDictionary dictionary];
            for (NSDictionary *item in tmpArray) {
                NSString *groupname=[item objectForKey:@"分组"];
                if(groupname==nil) groupname=@"";
                if(![moduleGroup containsObject:groupname])
                   [moduleGroup addObject:groupname];
                
                NSMutableArray *itemarray=[moduleList objectForKey:groupname];
                if(itemarray==nil)
                    itemarray=[NSMutableArray array];
                [itemarray addObject:item];
                [moduleList setObject:itemarray forKey:groupname];
                
            }
            
            [self.collectionView reloadData];
            for(NSDictionary *item in titleArray)
            {
                if([[item objectForKey:@"模板名称"] isEqualToString:@"通知"])
                {
                    NSString *wenzi=[item objectForKey:@"文字"];
                    [self getNewsList:[datam getMaxNewsId:wenzi userId:kUserIndentify] Item:item];
                }
            }
            [self getUnreadFromServer];
           
        }
    }
    if([request.username isEqualToString:@"获取未读数"])
    {
        
        NSData *data = [request responseData];
        NSString* dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        data   = [[NSData alloc] initWithBase64EncodedString:dataStr options:NSDataBase64DecodingIgnoreUnknownCharacters];
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
    else if([request.username isEqualToString:@"下载广告图片"])
    {
        NSData *datas = [request responseData];
        UIImage *headImage=[[UIImage alloc]initWithData:datas];
        if(headImage!=nil)
        {
            NSDictionary *indexDic=request.userInfo;
            NSString *filename=[indexDic objectForKey:@"图片"];
            filename=[CommonFunc getFileRealName:filename];
            NSString *filePath=[savepath stringByAppendingString:filename];
            [datas writeToFile:filePath atomically:YES];
            NSNumber *second=[indexDic objectForKey:@"显示秒数"];
            NSString *url=[indexDic objectForKey:@"跳转URL"];
            NSString *oldImageName = [kUserDefaults valueForKey:adImageName];
            if (oldImageName) {
                NSString *filePath = [savepath stringByAppendingString:oldImageName];
                [CommonFunc deleteFile:filePath];
            }
            [kUserDefaults setValue:filename forKey:adImageName];
            [kUserDefaults setValue:url forKey:adUrl];
            [kUserDefaults synchronize];
            [self showAdvView:filePath second:second.intValue];
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
    for (NSString *groupname in moduleGroup) {
        NSMutableArray *itemarray=[moduleList objectForKey:groupname];
        for(int i=0;i<itemarray.count;i++)
        {
            NSMutableDictionary *item=[NSMutableDictionary dictionaryWithDictionary:[itemarray objectAtIndex:i]];
            if([[item objectForKey:@"模板名称"] isEqualToString:@"通知"])
            {
                NSString *newsType=[item objectForKey:@"文字"];
                int unread=[datam getUnreadNews:newsType userId:kUserIndentify];
                if(unread>0)
                    allUnread=allUnread+unread;
                [item setObject:[NSNumber numberWithInt:unread] forKey:@"未读"];
                [itemarray replaceObjectAtIndex:i withObject:item];
                NSIndexPath *indexPath=[NSIndexPath indexPathForRow:i inSection:0];
                [indexArray addObject:indexPath];
            }
            else
            {
                NSString *newsType=[item objectForKey:@"文字"];
                NSString *unreadStr=[unreadDic objectForKey:newsType];
                if(unreadStr!=nil)
                {
                    int unread=unreadStr.intValue;
                    allUnread=allUnread+unread;
                    NSString *oldunreadStr=[item objectForKey:@"未读"];
                    if(unread!=oldunreadStr.intValue)
                    {
                        [item setObject:[NSNumber numberWithInt:unread] forKey:@"未读"];
                        [itemarray replaceObjectAtIndex:i withObject:item];
                        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:i inSection:0];
                        [indexArray addObject:indexPath];
                    }
                }
            }
        }
        //[moduleList setObject:itemarray forKey:groupname];
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
-(NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return moduleGroup.count;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSString *groupname=[moduleGroup objectAtIndex:section];
    NSMutableArray *itemarray=[moduleList objectForKey:groupname];
    return itemarray.count;
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    if (kind == UICollectionElementKindSectionHeader)
    {
        UICollectionReusableView *reusableHeaderView = nil;
        
        if (reusableHeaderView==nil) {
            
            reusableHeaderView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader  withReuseIdentifier:leaveDetailsHeadID forIndexPath:indexPath];
            reusableHeaderView.backgroundColor = [UIColor colorWithRed:230/255.0 green:228/255.0 blue:226/255.0 alpha:1.0];
            
            //这部分一定要这样写 ，否则会重影，不然就自定义headview
            UILabel *label = (UILabel *)[reusableHeaderView viewWithTag:100];
            if (!label) {
                label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.view.frame.size.width, 25)];
                label.tag = 100;
                label.font=[UIFont systemFontOfSize: 13.0];
                [reusableHeaderView addSubview:label];
            }
            
            label.text = moduleGroup[indexPath.section];
            
            
        }
        
        
        return reusableHeaderView;
        
    }
    return nil;
    
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    UICollectionViewCell *cell = (UICollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"colCell" forIndexPath:indexPath];
    NSString *groupname=moduleGroup[indexPath.section];
    NSMutableArray *itemarray=[moduleList objectForKey:groupname];
    NSDictionary *item=[itemarray objectAtIndex:indexPath.row];
    NSString *urlStr=[item objectForKey:@"图标"];
    if([item objectForKey:@"透明图标"]!=nil)
        urlStr=[item objectForKey:@"透明图标"];
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
    NSString *groupname=[moduleGroup objectAtIndex:indexPath.section];
    NSArray *itemarray=[moduleList objectForKey:groupname];
    NSDictionary *item=[itemarray objectAtIndex:indexPath.row];
    NSString *modelName=[item objectForKey:@"模板名称"];
    if([modelName isEqualToString:@"通知"])
    {
        [self performSegueWithIdentifier:@"News" sender:item];
    }
    else if([modelName isEqualToString:@"考勤"])
    {
        [self performSegueWithIdentifier:@"kaoqin" sender:item];
    }
    else if([modelName isEqualToString:@"成绩"])
    {
        [self performSegueWithIdentifier:@"chengji" sender:item];
    }
    else if([modelName isEqualToString:@"调查问卷"])
    {
        [self performSegueWithIdentifier:@"wenjuan" sender:item];
    }
    else if([modelName isEqualToString:@"浏览器"])
    {
        DDIHelpView *controller=[self.storyboard instantiateViewControllerWithIdentifier:@"HelpView"];
        controller.navigationItem.title=[item objectForKey:@"文字"];
        NSString *urlstr=[item objectForKey:@"接口地址"];
        if(urlstr!=nil)
        {
            if([urlstr rangeOfString:@"pda2014"].location!=NSNotFound)
            {
                NSMutableDictionary *dic=[NSMutableDictionary dictionary];
                [dic setObject:kUserIndentify forKey:@"用户较验码"];
                NSNumber *timeStamp=[[NSNumber alloc] initWithLong:[[NSDate new] timeIntervalSince1970]];
                [dic setObject:timeStamp forKey:@"DATETIME"];
                NSError *error;
                NSData *postData=[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
                //NSString *postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
                NSString *postStr=[GTMBase64 stringByWebSafeEncodingData:postData padded:YES];
                //controller.urlStr=[NSString stringWithFormat:@"%@&username=%@&password=%@",[item objectForKey:@"接口地址"],postStr,password];
                if([urlstr rangeOfString:@"?"].location==NSNotFound)
                    urlstr=[urlstr stringByAppendingString:@"?a=1"];
                controller.urlStr=[NSString stringWithFormat:@"%@&jiaoyanma=%@",urlstr,postStr];
            }
            else
                controller.urlStr=urlstr;
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
    else if([modelName isEqualToString:@"博客"])
    {
        [self performSegueWithIdentifier:@"blog" sender:item];
    }
    else if([modelName isEqualToString:@"二维码"])
    {
        [self intoQRCodeVC:[item objectForKey:@"接口地址"]];
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
    if([segue.identifier isEqualToString:@"blog"])
    {
        DDILiuYan *newsTitle=segue.destinationViewController;
        //newsTitle.title=name;
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
    NSString *urlStr;
    if([[interface lowercaseString] hasPrefix:@"http"])
        urlStr=interface;
    else
    {
        if([kStuState isEqualToString:@"新生状态"])
            urlStr=[NSString stringWithFormat:@"%@%@",kYingXinURL,interface];
        else
            urlStr=[NSString stringWithFormat:@"%@InterfaceStudent/%@",kInitURL,interface];
    }
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
- (void)intoQRCodeVC:(NSString *)interfaceUrl {
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusDenied){
        if (IS_VAILABLE_IOS8) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"相机权限受限" message:@"请在iPhone的\"设置->隐私->相机\"选项中,允许\"掌上校园\"访问您的相机." preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            }]];
            [alert addAction:[UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if ([self canOpenSystemSettingView]) {
                    [self systemSettingView];
                }
            }]];
            [self presentViewController:alert animated:YES completion:nil];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"相机权限受限" message:@"请在iPhone的\"设置->隐私->相机\"选项中,允许\"掌上校园\"访问您的相机." delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil];
            [alert show];
        }
        
        return;
    }
    QRCodeController *qrcodeVC = [[QRCodeController alloc] init];
    qrcodeVC.view.alpha = 0;
    [qrcodeVC setDidReceiveBlock:^(NSString *result) {
        NSMutableDictionary *resultdic=[NSMutableDictionary dictionary];
        [resultdic setObject:result forKey:@"result"];
        [resultdic setObject:interfaceUrl forKey:@"jumpurl"];
        [self performSelector:@selector(handleScanResult:) withObject:resultdic afterDelay:0.1f];
    }];
    DDIAppDelegate *del = (DDIAppDelegate *)[UIApplication sharedApplication].delegate;
    [del.window.rootViewController addChildViewController:qrcodeVC];
    [del.window.rootViewController.view addSubview:qrcodeVC.view];
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        qrcodeVC.view.alpha = 1;
    } completion:^(BOOL finished) {
    }];
}
-(void) handleScanResult:(NSDictionary *)resultDic
{
    NSString *result=[resultDic objectForKey:@"result"];
    NSString *jumpurl=[resultDic objectForKey:@"jumpurl"];
    NSString *template=[CommonFunc findUrlQueryString:jumpurl :@"template"];
    NSString *templategrade=[CommonFunc findUrlQueryString:jumpurl :@"templategrade"];
    NSString *targettitle=[CommonFunc findUrlQueryString:jumpurl :@"targettitle"];
    NSString *templatetitle=[CommonFunc findUrlQueryString:jumpurl :@"templatetitle"];
    if(template==nil || template.length==0)
        template=@"浏览器";
    if([jumpurl containsString:@"?"])
        jumpurl=[jumpurl stringByAppendingString:@"&"];
    else
        jumpurl=[jumpurl stringByAppendingString:@"?"];
    jumpurl = [jumpurl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *resultstr=[GTMBase64 stringByBase64String:result];
    if(resultstr!=nil && resultstr.length>0)
    {
        if([template isEqualToString:@"浏览器"])
        {
            DDIHelpView *controller=[self.storyboard instantiateViewControllerWithIdentifier:@"HelpView"];
            controller.navigationItem.title=targettitle;
            jumpurl=[NSString stringWithFormat:@"%@scancode=%@&jiaoyanma=%@",jumpurl,[GTMBase64 base64ToSafeBase64ForURL:result],kUserIndentify];
            controller.urlStr=jumpurl;
            [self.navigationController pushViewController:controller animated:YES];
        }
        else
        {
            jumpurl=[NSString stringWithFormat:@"%@scancode=%@",jumpurl,[GTMBase64 base64ToSafeBase64ForURL:result]];
            NSMutableDictionary *item=[NSMutableDictionary dictionary];
            [item setObject:templatetitle forKey:@"文字"];
            [item setObject:jumpurl forKey:@"接口地址"];
            if([template isEqualToString:@"通知"])
            {
                [self performSegueWithIdentifier:@"News" sender:item];
            }
            else if([template isEqualToString:@"考勤"])
            {
                [self performSegueWithIdentifier:@"kaoqin" sender:item];
            }
            else if([template isEqualToString:@"成绩"])
            {
                [self performSegueWithIdentifier:@"chengji" sender:item];
            }
            else if([template isEqualToString:@"调查问卷"])
            {
                if([templategrade isEqualToString:@"main"])
                    [self performSegueWithIdentifier:@"wenjuan" sender:item];
                else
                {
                    DDIWenJuanDetail *detail=[self.storyboard instantiateViewControllerWithIdentifier:@"wenjuanDetail"];
                    detail.title=templatetitle;
                    detail.interfaceUrl=jumpurl;
                    detail.examStatus=@"进行中";
                    detail.key=-1;
                    detail.parentTitleArray=nil;
                    detail.autoClose=@"是";
                    [self.navigationController pushViewController:detail animated:YES];
                }
            }
            else if([template isEqualToString:@"个人资料"])
            {
                DDIMyInforView *itemController=[self.storyboard instantiateViewControllerWithIdentifier:@"MyInforView"];
                NSArray *tmparr=[resultstr componentsSeparatedByString:@"&"];
                NSString *usertype=@"学生";
                if(tmparr.count>=3)
                {
                    if([[tmparr objectAtIndex:2] isEqualToString:@"老师"])
                        usertype=@"老师";
                    else if([[tmparr objectAtIndex:2] isEqualToString:@"老师"])
                        usertype=@"家长";
                }
                itemController.userWeiYi=[NSString stringWithFormat:@"用户_%@_%@____%d",usertype,[tmparr objectAtIndex:0],kSchoolId];
                [self.navigationController pushViewController:itemController animated:YES];
            }
            else if([template isEqualToString:@"博客"])
            {
                [self performSegueWithIdentifier:@"blog" sender:item];
            }
            
        }
    }
    NSLog(@"%@", result);
}
- (BOOL)canOpenSystemSettingView {
    if (IS_VAILABLE_IOS8) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            return YES;
        } else {
            return NO;
        }
    } else {
        return NO;
    }
}

/**
 *  跳到系统设置页面
 */
- (void)systemSettingView {
    if (IS_VAILABLE_IOS8) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}
@end
