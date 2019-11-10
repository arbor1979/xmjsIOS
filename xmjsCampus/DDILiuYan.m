//
//  DDINewsTitle.m
//  掌上校园
//
//  Created by yons on 14-3-10.
//  Copyright (c) 2014年 dandian. All rights reserved.
//

#import "DDILiuYan.h"
extern NSString *kUserIndentify;//用户登录后的唯一识别码
extern NSString *kInitURL;//默认单点webServic
extern NSString *kServiceURL ;
extern NSString *kYingXinURL ;
extern NSString *kStuState;
extern NSDictionary *teacherInfoDic;
extern int kUserType;
@interface DDILiuYan ()

@end

@implementation DDILiuYan

- (void)viewDidLoad
{
    [super viewDidLoad];
    if([kStuState isEqualToString:@"新生状态"])
        theUrl=[NSURL URLWithString:[kYingXinURL stringByAppendingString:self.interfaceUrl]];
    else
        theUrl=[NSURL URLWithString:[NSString stringWithFormat:@"%@InterfaceStudent/%@",kInitURL,self.interfaceUrl]];
    self.tableView.backgroundColor=[UIColor colorWithRed:228/255.0 green:244/255.0 blue:234/255.0 alpha:1];
    savePath=[CommonFunc createPath:@"/News/"];
    requestArray=[NSMutableArray array];
    isLoading=false;
    newsList=[NSMutableArray array];
    delImg=[UIImage imageNamed:@"delete.png"];
    replyImg=[UIImage imageNamed:@"reply.png"];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clearAndReload)
                                                 name:@"needRefreshTitle"
                                               object:nil];
    
    segmentedControl=[[UISegmentedControl alloc] initWithFrame:CGRectMake(0, 8, 100, 26) ];
    [segmentedControl insertSegmentWithTitle:@"全部" atIndex:0 animated:NO];
    [segmentedControl insertSegmentWithTitle:@"我的" atIndex:1 animated:NO];
    
    [segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    segmentedControl.selectedSegmentIndex=0;
    segmentedControl.tintColor = [UIColor blackColor];
    self.navigationItem.titleView=segmentedControl;
    [self loadDetailData];
}

-(void)segmentAction:(id)sender
{
    [self clearAndReload];
}
-(void)clearAndReload
{
    [newsList removeAllObjects];
    [self.tableView reloadData];
    [self loadDetailData];
}
-(void)loadDetailData
{
    NSString *fanwei=@"全部";
    if(segmentedControl.selectedSegmentIndex==1)
        fanwei=@"我的";

    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:theUrl];
    NSError *error;
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init ];
    [dic setObject:kUserIndentify forKey:@"用户较验码"];
    NSNumber *timeStamp=[[NSNumber alloc] initWithLong:[[NSDate new] timeIntervalSince1970]];
    [dic setObject:timeStamp forKey:@"DATETIME"];
    [dic setObject:[CommonFunc getLocalLanguage] forKey:@"language"];
    [dic setObject:[NSNumber numberWithInt:(int)newsList.count] forKey:@"start"];
    [dic setObject:[NSNumber numberWithInt:20] forKey:@"pagesize"];
    [dic setObject:fanwei forKey:@"fanwei"];
    if(kUserType==1)
        [dic setObject:[teacherInfoDic objectForKey:@"用户名"] forKey:@"userId"];
    else
    {
        if([kStuState isEqualToString:@"新生状态"])
            [dic setObject:[teacherInfoDic objectForKey:@"身份证号"] forKey:@"userId"];
        else
            [dic setObject:[teacherInfoDic objectForKey:@"学号"] forKey:@"userId"];
    }
    request.username=@"初始化标题";
    NSData *postData=[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
    postStr=[GTMBase64 base64StringBystring:postStr];
    [request setPostValue:postStr forKey:@"DATA"];
    [request setDelegate:self];
    request.timeOutSeconds=60;
    [request startAsynchronous];
    [requestArray addObject:request];
    alertTip = [[OLGhostAlertView alloc] initWithTitle:NSLocalizedString(@"loading", nil) message:nil timeout:0 dismissible:NO];
    [alertTip show];
    isLoading=true;
    
}
- (void)requestFinished:(ASIHTTPRequest *)request
{
    if([request.username isEqualToString:@"初始化标题"])
    {
        if(alertTip)
            [alertTip removeFromSuperview];
        [self performSelector:@selector(resetIsloading) withObject:nil afterDelay:1.0f];
        NSData *data = [request responseData];
        data   = [[NSData alloc] initWithBase64EncodedData:data options:0];
        NSDictionary *dict= [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        if(dict)
        {
            NSArray *tmpArray=[dict objectForKey:@"通知项"];
            if(tmpArray && ![tmpArray isEqual:[NSNull null]] && tmpArray.count>0)
            {
                [newsList addObjectsFromArray:tmpArray];
                
            }
            else
            {
                if(newsList.count>0)
                {
                    OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"没有更多了"];
                    [tipView show];
                }
            }
            if(!newsList || newsList.count==0)
            {
                OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"没有数据"];
                [tipView show];
            }
            [self.tableView reloadData];
            
            NSString *btName=[dict objectForKey:@"右上按钮"];
            if(btName!=nil && btnUrl==nil)
            {
                
                btnUrl=[dict objectForKey:@"右上按钮URL"];
                UIBarButtonItem *rightBtn= [[UIBarButtonItem alloc] initWithTitle:btName style:UIBarButtonItemStylePlain target:self action:@selector(addNew)];
                self.navigationItem.rightBarButtonItem=rightBtn;
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
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
    if([request.username isEqualToString:@"删除留言"])
    {
        if(alertTip)
            [alertTip removeFromSuperview];
        NSData *data = [request responseData];
        data   = [[NSData alloc] initWithBase64EncodedData:data options:0];
        NSDictionary *dict= [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        if(dict)
        {
            if([[dict objectForKey:@"结果"] isEqualToString:@""])
            {
                for (NSDictionary *item in newsList) {
                    if([[item objectForKey:@"编号"] isEqual:[dict objectForKey:@"编号"]])
                    {
                        [newsList removeObject:item];
                        [self.tableView reloadData];
                        break;
                    }
                }
            }
        }
    }

    
}
-(void)resetIsloading
{
    isLoading=false;
}
-(void)addNew
{
    NSArray *tmparray=[theUrl.absoluteString componentsSeparatedByString:@"?"];
    NSString *urlStr=[[tmparray objectAtIndex:0] stringByAppendingString:btnUrl];
    DDIWenJuanDetail *detail=[self.storyboard instantiateViewControllerWithIdentifier:@"wenjuanDetail"];
    
    detail.title=self.title;
    detail.interfaceUrl=urlStr;
    detail.examStatus=@"进行中";
    detail.key=-1;
    detail.parentTitleArray=nil;
    [self.navigationController pushViewController:detail animated:YES];

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
- (void)scrollToBottomAnimated
{
    NSInteger rows = [self.tableView numberOfSections];
    
    if(rows > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:rows-1]
                              atScrollPosition:UITableViewScrollPositionBottom
                                      animated:NO];
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

    return newsList.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *dic=[newsList objectAtIndex:section];
    NSString *contentStr=[dic objectForKey:@"回答内容"];
    if(contentStr && contentStr.length>0)
        return 2;
    else
        return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier1 = @"titleCell";
    static NSString *CellIdentifier2 = @"detailCell";
    NSDictionary *dic=[newsList objectAtIndex:indexPath.section];
    UITableViewCell *cell;
    if(indexPath.row==0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1 forIndexPath:indexPath];
        UIImageView *imagev1=(UIImageView *)[cell viewWithTag:101];
        UILabel *name1=(UILabel *)[cell viewWithTag:102];
        UILabel *time1=(UILabel *)[cell viewWithTag:103];
        UILabel *content1=(UILabel *)[cell viewWithTag:104];
        UIButton *delete1=(UIButton *)[cell viewWithTag:105];
        delete1.hidden=YES;
        if([[teacherInfoDic objectForKey:@"身份证号"] isEqual:[dic objectForKey:@"提问者ID"]] || [[teacherInfoDic objectForKey:@"学号"] isEqual:[dic objectForKey:@"提问者ID"]])
        {
            [delete1 setImage:delImg forState:UIControlStateNormal];
            delete1.hidden=NO;
            [delete1 addTarget:self action:@selector(deleteLiuYan:) forControlEvents:UIControlEventTouchUpInside];
        }
        else if(kUserType==1 && [[dic objectForKey:@"回答内容"] isEqual:@""])
        {
            [delete1 setImage:replyImg forState:UIControlStateNormal];
            delete1.hidden=NO;
            [delete1 addTarget:self action:@selector(replyLiuYan:) forControlEvents:UIControlEventTouchUpInside];
        }
        else
            delete1.hidden=YES;
        NSString *headUrl=[dic objectForKey:@"提问者头像"];
        [self getImageByUrl:headUrl imagev:imagev1 indexPath:indexPath];
        name1.text=[dic objectForKey:@"提问者"];
        time1.text=[dic objectForKey:@"提问时间"];
        content1.text=[dic objectForKey:@"问题"];
        content1.numberOfLines=0;
        [content1 sizeToFit];
    }
    else if(indexPath.row==1)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier2 forIndexPath:indexPath];
        UIImageView *imagev2=(UIImageView *)[cell viewWithTag:201];
        UILabel *name2=(UILabel *)[cell viewWithTag:202];
        UILabel *time2=(UILabel *)[cell viewWithTag:203];
        UILabel *content2=(UILabel *)[cell viewWithTag:204];
        
        NSString *headUrl=[dic objectForKey:@"回答者头像"];
        [self getImageByUrl:headUrl imagev:imagev2 indexPath:indexPath];
        name2.text=[dic objectForKey:@"回答者"];
        time2.text=[dic objectForKey:@"回答时间"];
        content2.text=[dic objectForKey:@"回答内容"];
        content2.numberOfLines=0;
        [content2 sizeToFit];
    }
    return cell;
}
-(void)replyLiuYan:(UIButton *)btn
{
    UIView *tmpview=btn.superview;
    while(![tmpview isKindOfClass:[UITableViewCell class]])
        tmpview=tmpview.superview;
    NSIndexPath *indexPath=[self.tableView indexPathForCell:(UITableViewCell *)tmpview];
    NSDictionary *item=[newsList objectAtIndex:indexPath.section];
    NSString *liuyanId=[item objectForKey:@"编号"];
    NSArray *tmparray=[theUrl.absoluteString componentsSeparatedByString:@"?"];
    NSString *urlStr=[NSString stringWithFormat:@"%@?ID=%@&action=reply",[tmparray objectAtIndex:0],liuyanId];
    DDIWenJuanDetail *detail=[self.storyboard instantiateViewControllerWithIdentifier:@"wenjuanDetail"];
    detail.title=self.title;
    detail.interfaceUrl=urlStr;
    detail.examStatus=@"进行中";
    detail.key=-1;
    detail.parentTitleArray=nil;
    [self.navigationController pushViewController:detail animated:YES];
}
-(void)deleteLiuYan:(UIButton *)btn
{
    UIView *tmpview=btn.superview;
    while(![tmpview isKindOfClass:[UITableViewCell class]])
        tmpview=tmpview.superview;
    NSIndexPath *indexPath=[self.tableView indexPathForCell:(UITableViewCell *)tmpview];
    NSDictionary *item=[newsList objectAtIndex:indexPath.section];
    
    NSString *title = @"是否确认删除？";
    NSString *cancelButtonTitle = @"否";
    NSString *otherButtonTitle = @"是";
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    // Create the actions.
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {

    }];
    
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:otherButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *strUrl=[NSString stringWithFormat:@"?action=delBlog&ID=%@",[item objectForKey:@"编号"]];
        NSArray *tmpArray=[self->theUrl.absoluteString componentsSeparatedByString:@"?"];
        strUrl=[tmpArray[0] stringByAppendingString:strUrl];
        NSURL *url = [NSURL URLWithString:strUrl];
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        NSError *error;
        NSMutableDictionary *dic=[[NSMutableDictionary alloc] init ];
        [dic setObject:kUserIndentify forKey:@"用户较验码"];
        NSNumber *timeStamp=[[NSNumber alloc] initWithLong:[[NSDate new] timeIntervalSince1970]];
        [dic setObject:timeStamp forKey:@"DATETIME"];
        request.username=@"删除留言";
        NSData *postData=[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
        NSString *postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
        postStr=[GTMBase64 base64StringBystring:postStr];
        [request setPostValue:postStr forKey:@"DATA"];
        [request setDelegate:self];
        [request setTag:indexPath.row];
        [request startAsynchronous];
        [self->requestArray addObject:request];
        self->alertTip = [[OLGhostAlertView alloc] initWithTitle:@"正在删除" message:nil timeout:0 dismissible:NO];
        [self->alertTip show];
    }];
    
    // Add the actions.
    [alertController addAction:cancelAction];
    [alertController addAction:otherAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
    

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
        imagev.image=img;
        [imagev.layer setMasksToBounds:YES];
        [imagev.layer setCornerRadius:21]; //设置矩形四个圆角半径
    }
    else
    {
        NSURL *url = [NSURL URLWithString:headUrl];
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

- (void)requestFailed:(ASIHTTPRequest *)request
{
    if(alertTip)
        [alertTip removeFromSuperview];
    NSError *error = [request error];
    NSLog(@"请求失败:%@",[error localizedDescription]);
    isLoading=false;
    OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:[error localizedDescription]];
    [tipView show];
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic=[newsList objectAtIndex:indexPath.section];
    NSStringDrawingOptions opts = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineBreakMode:NSLineBreakByCharWrapping];
    NSDictionary *attributes = @{ NSFontAttributeName : [UIFont systemFontOfSize:15], NSParagraphStyleAttributeName : style };
    
    
    if(indexPath.row==0)
    {
        NSString *content1=[dic objectForKey:@"问题"];
        
        CGRect rect=[content1 boundingRectWithSize:CGSizeMake(302, 1000) options:opts attributes:attributes context:nil];
        CGSize size=rect.size;
        //CGSize size = [content1 sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(300, 1000) lineBreakMode:NSLineBreakByCharWrapping];
        int sect1=60+size.height+10;
        return sect1;
    }
    else if(indexPath.row==1)
    {
        int sect2=58;
        NSString *content2=[dic objectForKey:@"回答内容"];
        
        if(content2 && content2.length>0)
        {
            CGRect rect=[content2 boundingRectWithSize:CGSizeMake(302, 1000) options:opts attributes:attributes context:nil];
            CGSize size=rect.size;
            //CGSize size = [content2 sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(300, 1000) lineBreakMode:NSLineBreakByCharWrapping];
            sect2+=size.height;
            
        }
        return sect2+10;
    }
    return 0;
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	

    CGPoint offset = scrollView.contentOffset;
    CGRect bounds = scrollView.bounds;
    CGSize size = scrollView.contentSize;
    UIEdgeInsets inset = scrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    // NSLog(@"offset: %f", offset.y);
    // NSLog(@"content.height: %f", size.height);
    // NSLog(@"bounds.height: %f", bounds.size.height);
    // NSLog(@"inset.top: %f", inset.top);
    // NSLog(@"inset.bottom: %f", inset.bottom);
    // NSLog(@"pos: %f of %f", y, h);
    float reload_distance = 15;
    if(y > h + reload_distance) {
        //NSLog(@"load more rows");
        
        if(!isLoading)
            [self loadDetailData];
    } 
    
}

@end
