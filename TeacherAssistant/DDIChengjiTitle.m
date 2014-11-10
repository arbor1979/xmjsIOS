//
//  DDIChengjiTitle.m
//  掌上校园
//
//  Created by yons on 14-3-14.
//  Copyright (c) 2014年 dandian. All rights reserved.
//

#import "DDIChengjiTitle.h"
extern NSString *kInitURL;//默认单点webServic
extern NSString *kUserIndentify;//用户登录后的唯一识别码

@interface DDIChengjiTitle ()

@end

@implementation DDIChengjiTitle



- (void)viewDidLoad
{
    [super viewDidLoad];
    savePath=[CommonFunc createPath:@"/utils/"];
    requestArray=[NSMutableArray array];
    titleArray= [NSArray array];
    self.tableView.backgroundColor=[UIColor colorWithRed:228/255.0 green:244/255.0 blue:234/255.0 alpha:1];
    mygreen=[UIColor colorWithRed:39/255.0 green:174/255.0 blue:98/255.0 alpha:0.8];
    [self loadTitleData];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadTitleData)
                                                 name:@"needRefreshTitle"
                                               object:nil];
    
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
        [req setDownloadProgressDelegate:nil];
        [req clearDelegatesAndCancel];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"needRefreshTitle" object:nil];
}
-(void)loadTitleData
{
    NSString *urlStr=[NSString stringWithFormat:@"%@InterfaceStudent/%@",kInitURL,self.interfaceUrl];
    NSURL *url = [NSURL URLWithString:urlStr];
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
    [request startAsynchronous];
    [requestArray addObject:request];
    alertTip = [[OLGhostAlertView alloc] initWithTitle:@"正在获取数据" message:nil timeout:0 dismissible:NO];
    [alertTip showInView:self.view];
    
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    if([request.username isEqualToString:@"初始化标题"])
    {
        if(alertTip)
            [alertTip removeFromSuperview];
        NSData *data = [request responseData];
        NSString* dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        data   = [[NSData alloc] initWithBase64Encoding:dataStr];
        NSDictionary *dict= [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        if(dict)
            titleArray=[dict objectForKey:@"成绩数值"];
        if(!dict || !titleArray || titleArray.count==0)
        {
            OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"没有任何数据"];
            [tipView showInView:self.view];
        }
        [self.tableView reloadData];
   
        NSString *btName=[dict objectForKey:@"右上按钮"];
        if(btName!=nil)
        {
            
            btnUrl=[dict objectForKey:@"右上按钮URL"];
            UIBarButtonItem *rightBtn= [[UIBarButtonItem alloc] initWithTitle:btName style:UIBarButtonItemStyleBordered target:self action:@selector(addNew)];
            
            self.navigationItem.rightBarButtonItem=rightBtn;
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
            UIView *parent=[indexDic objectForKey:@"parentView"];
            NSIndexPath *indexPath=[indexDic objectForKey:@"indexPath"];
            headImage=[headImage scaleToSize:CGSizeMake(42, 42)];
            if([parent isKindOfClass:[UIButton class]])
            {
                UIButton *btn=(UIButton *)parent;
                [btn setBackgroundImage:headImage forState:UIControlStateNormal];
            }
            else if([parent isKindOfClass:[UIImageView class]])
            {
                UIImageView *iv=(UIImageView *)parent;
                iv.image=headImage;
            }
            
            UIActivityIndicatorView *aiv=[indexDic objectForKey:@"aiv"];
            if(aiv)
            {
                [aiv stopAnimating];
                [aiv removeFromSuperview];
            }
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            
        }
    }
    
    
}

-(void)addNew
{
    
    NSString *urlStr=[NSString stringWithFormat:@"%@InterfaceStudent/%@",kInitURL,self.interfaceUrl];
    NSArray *tmparray=[urlStr componentsSeparatedByString:@"?"];
    urlStr=[[tmparray objectAtIndex:0] stringByAppendingString:btnUrl];
    DDIWenJuanDetail *detail=[self.storyboard instantiateViewControllerWithIdentifier:@"wenjuanDetail"];
    
    detail.title=self.title;
    detail.interfaceUrl=urlStr;
    detail.examStatus=@"进行中";
    detail.key=-1;
    detail.parentTitleArray=nil;
    [self.navigationController pushViewController:detail animated:YES];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    if(alertTip)
        [alertTip removeFromSuperview];
    NSError *error = [request error];
    NSLog(@"请求失败:%@",[error localizedDescription]);
    OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:[error localizedDescription]];
    [tipView show];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return titleArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"myCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSDictionary *item=[titleArray objectAtIndex:indexPath.row];
    NSString *titleImage=[item objectForKey:@"图标"];
    [self loadImageAndSave:titleImage parentView:cell.imageView indexPath:indexPath];
    
    cell.textLabel.text=[item objectForKey:@"第一行"];
    cell.detailTextLabel.layer.cornerRadius =5.0;
    cell.detailTextLabel.backgroundColor=mygreen;
    
    cell.detailTextLabel.text=[NSString stringWithFormat:@" %@ ",[item objectForKey:@"第二行左"]];
    UILabel *rightLbl=(UILabel *)[cell viewWithTag:101];
    
    rightLbl.text=[item objectForKey:@"第二行右"];
    
    NSString *detailURL=[item objectForKey:@"内容项URL"];
    if(!detailURL || detailURL.length==0)
    {
        cell.accessoryType=UITableViewCellAccessoryNone;
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
    }
    return cell;
}
-(void)loadImageAndSave:(NSString *)imageUrl parentView:(UIView *)parentView indexPath:(NSIndexPath *)indexPath
{
    if(imageUrl && imageUrl.length>0)
    {
        NSArray *sepArray=[imageUrl componentsSeparatedByString:@"/"];
        NSString *filename=[sepArray objectAtIndex:sepArray.count-1];
        filename=[savePath stringByAppendingString:filename];
        if([CommonFunc fileIfExist:filename])
        {
            UIImage *img=[UIImage imageWithContentsOfFile:filename];
            img=[img scaleToSize:CGSizeMake(42, 42)];
            if([parentView isKindOfClass:[UIButton class]])
            {
                UIButton *btn=(UIButton *)parentView;
                [btn setBackgroundImage:img forState:UIControlStateNormal];
                
            }
            else if([parentView isKindOfClass:[UIImageView class]])
            {
                UIImageView *iv=(UIImageView *)parentView;
                iv.image=img;
            }
        }
        else
        {
            UIActivityIndicatorView *aiv=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(parentView.bounds.size.width/2-16, parentView.bounds.size.height/2-16, 32, 32)];
            aiv.activityIndicatorViewStyle=UIActivityIndicatorViewStyleGray;
            [parentView addSubview:aiv];
            [aiv startAnimating];
            
            NSURL *url = [NSURL URLWithString:imageUrl];
            ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
            request.username=@"下载图片";
            NSMutableDictionary *indexDic=[[NSMutableDictionary alloc]init];
            [indexDic setObject:filename forKey:@"filename"];
            [indexDic setObject:aiv forKey:@"aiv"];
            [indexDic setObject:parentView forKey:@"parentView"];
            [indexDic setObject:indexPath forKey:@"indexPath"];
            request.userInfo=indexDic;
            [request setDelegate:self];
            [request startAsynchronous];
            [requestArray addObject:request];
            
        }
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *item=[titleArray objectAtIndex:indexPath.row];
    NSString *detailURL=[item objectForKey:@"内容项URL"];
    if(detailURL && detailURL.length>0)
        [self performSegueWithIdentifier:@"chengjiDetail" sender:indexPath];
    
    
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath=(NSIndexPath *)sender;
    NSDictionary *item=[titleArray objectAtIndex:indexPath.row];
    NSString *detailURL=[item objectForKey:@"内容项URL"];
    NSString *urlStr=[NSString stringWithFormat:@"%@InterfaceStudent/%@",kInitURL,self.interfaceUrl];
    urlStr=[urlStr stringByAppendingString:detailURL];

    DDIChengjiDetail *detial=segue.destinationViewController;
    detial.title=[item objectForKey:@"第一行"];
    detial.interfaceUrl=urlStr;
}
@end
