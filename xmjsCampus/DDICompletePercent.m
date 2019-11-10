//
//  DDIMessageList.m
//  老师助手
//
//  Created by yons on 13-12-31.
//  Copyright (c) 2013年 dandian. All rights reserved.
//

#import "DDICompletePercent.h"
extern Boolean kIOS7;
extern NSString *kYingXinURL;
extern NSMutableDictionary *teacherInfoDic;//老师数据
extern NSDictionary *LinkMandic;//联系人数据
extern int kUserType;
extern NSString *kUserIndentify;//用户登录后的唯一识别码
@interface DDICompletePercent ()

@end

@implementation DDICompletePercent


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupRefresh];
    requestArray=[[NSMutableArray alloc]init];
    savePath=[CommonFunc createPath:@"/utils/"];
    titleArray=[NSArray array];
    //_aTimer=[NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(timerFireMethod:) userInfo:nil repeats:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getDataList)
                                                 name:@"needRefreshTitle"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getDataList)name:UIApplicationWillEnterForegroundNotification object:nil];
    [self getDataList];
    
}
-(void)viewDidAppear:(BOOL)animated
{
    self.parentViewController.navigationItem.rightBarButtonItem=nil;
    [super viewDidAppear:animated];
}
-(void)getDataList
{
    NSURL *url = [NSURL URLWithString:[kYingXinURL stringByAppendingString:@"school-module.php?action=needSubmit"]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    NSError *error;
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init ];
    [dic setObject:kUserIndentify forKey:@"用户较验码"];
    NSNumber *timeStamp=[[NSNumber alloc] initWithLong:[[NSDate new] timeIntervalSince1970]];
    [dic setObject:timeStamp forKey:@"DATETIME"];
    [dic setObject:[CommonFunc getLocalLanguage] forKey:@"language"];
    request.username=@"初始化标题";
    NSData *postData=[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
    postStr=[GTMBase64 base64StringBystring:postStr];
    [request setPostValue:postStr forKey:@"DATA"];
    [request setDelegate:self];
    request.timeOutSeconds=60;
    [request startAsynchronous];
    [requestArray addObject:request];
}
- (void)requestFinished:(ASIHTTPRequest *)request
{
    if([request.username isEqualToString:@"初始化标题"])
    {
        
        NSData *data = [request responseData];
        //NSString* dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        data   = [[NSData alloc] initWithBase64EncodedData:data options:0];
        NSArray *tmpArray= [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        if(tmpArray)
            titleArray=[NSArray arrayWithArray:tmpArray];
        if(titleArray.count==0)
        {
            OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"没有数据"];
            [tipView showInView:self.view];
        }
        else
        {
            [self.tableView reloadData];

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
            NSIndexSet *indexset=[[NSIndexSet alloc]initWithIndex:indexPath.section];
            [self.tableView reloadSections:indexset withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
}
- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"请求失败:%@",[error localizedDescription]);
    OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:[error localizedDescription]];
    [tipView show];
}
- (void)dealloc
{
    
    for(ASIHTTPRequest *req in requestArray)
    {
        [req setDownloadProgressDelegate:nil];
        [req clearDelegatesAndCancel];
    }
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:@"needRefreshTitle" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
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
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return titleArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSMutableDictionary *item=[titleArray objectAtIndex:indexPath.row];
    UIImageView *imgv=(UIImageView *)[cell viewWithTag:101];
    UILabel *title=(UILabel *)[cell viewWithTag:102];
    UILabel *detail=(UILabel *)[cell viewWithTag:103];
    UIImageView *imgShenhe=(UIImageView *)[cell viewWithTag:105];
    ASProgressPopUpView *prog=(ASProgressPopUpView *)[cell viewWithTag:104];
    NSString *titleImage=[item objectForKey:@"图标"];
    [self loadImageAndSave:titleImage parentView:imgv indexPath:indexPath];
    title.text=[item objectForKey:@"标题"];
    detail.text=[item objectForKey:@"完成度文字"];
    NSString *shenhe=[item objectForKey:@"审核状态"];
    if(shenhe!=nil && shenhe.length>0)
    {
        [imgShenhe setHidden:false];
        if([shenhe isEqualToString:@"已审核"])
            [imgShenhe setImage:[UIImage imageNamed:@"needsubmit_hasreview"]];
        else if([shenhe isEqualToString:@"待审核"])
            [imgShenhe setImage:[UIImage imageNamed:@"needsubmit_waitreview"]];
        else if([shenhe isEqualToString:@"未完成"] || [shenhe isEqualToString:@"被拒绝"])
            [imgShenhe setImage:[UIImage imageNamed:@"needsubmit_unfinish"]];
        else
            [imgShenhe setHidden:true];
    }
    
    [prog setFont:[UIFont systemFontOfSize:15]];
    NSNumber *persent=[item objectForKey:@"完成度"];
    [prog setProgress:persent.floatValue/100 animated:YES];
    prog.popUpViewAnimatedColors = @[[UIColor redColor], [UIColor orangeColor], [UIColor greenColor]];
    [prog showPopUpViewAnimated:YES];
    return cell;
}
-(void)loadImageAndSave:(NSString *)imageUrl parentView:(UIImageView *)imgv indexPath:(NSIndexPath *)indexPath
{
    if(imageUrl && imageUrl.length>0)
    {
        NSArray *sepArray=[imageUrl componentsSeparatedByString:@"/"];
        NSString *filename=[sepArray objectAtIndex:sepArray.count-1];
        filename=[savePath stringByAppendingString:filename];
        if([CommonFunc fileIfExist:filename])
        {
            UIImage *img=[UIImage imageWithContentsOfFile:filename];
            imgv.image=img;
        }
        else
        {
            
            NSURL *url = [NSURL URLWithString:imageUrl];
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
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *item=[titleArray objectAtIndex:indexPath.row];
    NSString *urlStr=[kYingXinURL stringByAppendingString:[item objectForKey:@"接口地址"]];
    DDIWenJuanDetail *detail=[self.storyboard instantiateViewControllerWithIdentifier:@"wenjuanDetail"];
    
    detail.title=[item objectForKey:@"标题"];
    detail.interfaceUrl=urlStr;
    detail.examStatus=@"进行中";
    detail.key=-1;
    detail.parentTitleArray=nil;
    [self.navigationController pushViewController:detail animated:YES];
}
// 下拉刷新
- (void)setupRefresh {
    NSLog(@"setupRefresh -- 下拉刷新");
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshClick:) forControlEvents:UIControlEventValueChanged];
    refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"正在刷新"];
    //刷新图形时的颜色，即刷新的时候那个菊花的颜色
    refreshControl.tintColor = [UIColor redColor];
    [self.tableView addSubview:refreshControl];
    [refreshControl beginRefreshing];
    [self refreshClick:refreshControl];
}
// 下拉刷新触发，在此获取数据
- (void)refreshClick:(UIRefreshControl *)refreshControl {
    NSLog(@"refreshClick: -- 刷新触发");
    [self getDataList];
    [refreshControl endRefreshing];
}

@end
