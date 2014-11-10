//
//  DDIChengjiDetail.m
//  掌上校园
//
//  Created by yons on 14-3-14.
//  Copyright (c) 2014年 dandian. All rights reserved.
//

#import "DDIChengjiDetail.h"
extern NSString *kUserIndentify;//用户登录后的唯一识别码
extern NSString *kInitURL;
@interface DDIChengjiDetail ()

@end

@implementation DDIChengjiDetail



- (void)viewDidLoad
{
    [super viewDidLoad];

    requestArray=[NSMutableArray array];
    detailArray= [NSMutableArray array];
    self.tableView.backgroundColor=[UIColor colorWithRed:228/255.0 green:244/255.0 blue:234/255.0 alpha:1];
    savepath=[CommonFunc createPath:@"/utils/"];
    [self loadDetailData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadDetailData)
                                                 name:@"needRefreshDetail"
                                               object:nil];
}


-(void)loadDetailData
{
    
    NSURL *url = [NSURL URLWithString:self.interfaceUrl];
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
    alertTip = [[OLGhostAlertView alloc] initWithTitle:@"正在获取明细数据" message:nil timeout:0 dismissible:NO];
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
        {
            leftWidth=[dict objectForKey:@"左边宽度"];
            detailArray=[[NSMutableArray alloc] initWithArray:[dict objectForKey:@"成绩数值"]];
            if(!detailArray || detailArray.count==0)
            {
                OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"没有任何数据"];
                [tipView showInView:self.view];
            }
            [self.tableView reloadData];
            
            NSString *btName=[dict objectForKey:@"右上按钮"];
            if(btName!=nil)
            {
                
                btnUrl=[dict objectForKey:@"右上按钮URL"];
                UIBarButtonItem *rightBtn;
                if([[dict objectForKey:@"右上按钮Submit"] isEqualToString:@"是"])
                {
                    rightBtn= [[UIBarButtonItem alloc] initWithTitle:btName style:UIBarButtonItemStyleBordered target:self action:@selector(addSubmit)];
                }
                else
                {
                    rightBtn= [[UIBarButtonItem alloc] initWithTitle:btName style:UIBarButtonItemStyleBordered target:self action:@selector(addNew)];
                }
                self.navigationItem.rightBarButtonItem=rightBtn;
            }
        }
        
        
    }
    else if([request.username isEqualToString:@"删除行"])
    {
        if(alertTip)
           [alertTip removeFromSuperview];
        NSData *data = [request responseData];
        NSString* dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        data   = [[NSData alloc] initWithBase64Encoding:dataStr];
        NSDictionary *dict= [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        if(dict && [[dict objectForKey:@"结果"] isEqualToString:@"成功"])
        {
            NSIndexPath *index=[NSIndexPath indexPathForRow:request.tag inSection:0];
            [detailArray removeObjectAtIndex:request.tag];
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:index] withRowAnimation:UITableViewRowAnimationAutomatic];
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
    else if([request.username isEqualToString:@"右上按钮Submit"])
    {
        NSData *data = [request responseData];
        NSString* dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        data   = [[NSData alloc] initWithBase64Encoding:dataStr];
        NSDictionary *dict= [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSString *result=[dict objectForKey:@"结果"];
        if([result isEqualToString:@"成功"])
        {
            OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"操作成功"];
            [tipView showInView:self.view];
            NSString *autoClose=[dict objectForKey:@"自动关闭"];
            if([autoClose isEqualToString:@"是"])
            {
                [self.navigationController popViewControllerAnimated:YES];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"needRefreshTitle" object:nil];
            }
            
        }
    }
    
}
-(void)addNew
{
 
    NSString *urlStr=[NSString stringWithFormat:@"%@InterfaceStudent/%@",kInitURL,self.interfaceUrl];
    NSArray *tmparray=[self.interfaceUrl componentsSeparatedByString:@"?"];
    urlStr=[[tmparray objectAtIndex:0] stringByAppendingString:btnUrl];
    DDIWenJuanDetail *detail=[self.storyboard instantiateViewControllerWithIdentifier:@"wenjuanDetail"];
    
    detail.title=self.title;
    detail.interfaceUrl=urlStr;
    detail.examStatus=@"进行中";
    detail.key=-1;
    detail.parentTitleArray=nil;
    [self.navigationController pushViewController:detail animated:YES];
}
-(void)addSubmit
{
    NSArray *tmpArray=[self.interfaceUrl componentsSeparatedByString:@"?"];
    
    NSString *urlStr=[NSString stringWithFormat:@"%@%@",[tmpArray objectAtIndex:0],btnUrl];
    NSURL *url = [NSURL URLWithString:urlStr];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    NSError *error;
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init ];
    [dic setObject:kUserIndentify forKey:@"用户较验码"];
    NSNumber *timeStamp=[[NSNumber alloc] initWithLong:[[NSDate new] timeIntervalSince1970]];
    [dic setObject:timeStamp forKey:@"DATETIME"];
    request.username=@"右上按钮Submit";
    NSData *postData=[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
    postStr=[GTMBase64 base64StringBystring:postStr];
    [request setPostValue:postStr forKey:@"DATA"];
    [request setDelegate:self];
    [request startAsynchronous];
    [requestArray addObject:request];
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
-(void)dealloc
{
    for(ASIHTTPRequest *req in requestArray)
    {
        [req clearDelegatesAndCancel];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"needRefreshDetail" object:nil];
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

    // Return the number of rows in the section.
    return detailArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier=@"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UILabel *leftLbl;
    UILabel *rightLbl;
    if(!cell)
    {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        int width=self.view.frame.size.width*leftWidth.intValue/100-15;
        leftLbl=[[UILabel alloc] initWithFrame:CGRectMake(10, 3, width, cell.frame.size.height)];
        rightLbl=[[UILabel alloc]initWithFrame:CGRectMake(width+15, 3, cell.frame.size.width-width-20,cell.frame.size.height)];
        
        leftLbl.font=[UIFont systemFontOfSize:16];
        rightLbl.font=[UIFont systemFontOfSize:16];
        leftLbl.backgroundColor=[UIColor clearColor];
        rightLbl.backgroundColor=[UIColor clearColor];
        leftLbl.tag=101;
        rightLbl.tag=102;
        [leftLbl setNumberOfLines:0];
        [rightLbl setNumberOfLines:0];
        leftLbl.textColor=[UIColor colorWithRed:39/255.0 green:174/255.0 blue:98/255.0 alpha:1];;
        [cell addSubview:leftLbl];
        [cell addSubview:rightLbl];
        [rightLbl setLineBreakMode:NSLineBreakByWordWrapping];
        
        UIButton *hiddenBtn=[[UIButton alloc]initWithFrame:CGRectZero];
        hiddenBtn.tag=103;
        [cell addSubview:hiddenBtn];
        [hiddenBtn addTarget:self action:@selector(deleteCell:) forControlEvents:UIControlEventTouchUpInside];
        
        leftLbl.translatesAutoresizingMaskIntoConstraints = NO;
        leftLbl.textAlignment=NSTextAlignmentRight;
        
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:leftLbl attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f];
        [cell addConstraint:constraint];
        constraint = [NSLayoutConstraint constraintWithItem:leftLbl attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:width];
        [cell addConstraint:constraint];
        constraint = [NSLayoutConstraint constraintWithItem:leftLbl attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:hiddenBtn attribute:NSLayoutAttributeRight multiplier:1.0f constant:5];
        [cell addConstraint:constraint];
        
        rightLbl.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint *constraint1 = [NSLayoutConstraint constraintWithItem:rightLbl attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f];
        [cell addConstraint:constraint1];
        constraint1 = [NSLayoutConstraint constraintWithItem:rightLbl attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:leftLbl attribute:NSLayoutAttributeRight multiplier:1.0f constant:5];
        [cell addConstraint:constraint1];
        constraint1 = [NSLayoutConstraint constraintWithItem:rightLbl attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:cell.frame.size.width-width-20];
        [cell addConstraint:constraint1];
        
    }
    NSDictionary *item=[detailArray objectAtIndex:indexPath.row];
    leftLbl=(UILabel *)[cell viewWithTag:101];
    rightLbl=(UILabel *)[cell viewWithTag:102];
    leftLbl.text=[item objectForKey:@"左边"];
    rightLbl.text=[item objectForKey:@"右边"];

    CGSize size1 = [leftLbl.text sizeWithFont:leftLbl.font constrainedToSize:CGSizeMake(leftLbl.frame.size.width, 1000.0f) lineBreakMode:NSLineBreakByWordWrapping];
    CGSize size2 = [rightLbl.text sizeWithFont:rightLbl.font constrainedToSize:CGSizeMake(rightLbl.frame.size.width, 1000.0f) lineBreakMode:NSLineBreakByWordWrapping];
    int height=size1.height>size2.height?size1.height:size2.height;
    [leftLbl setFrame:CGRectMake(leftLbl.frame.origin.x, leftLbl.frame.origin.y, leftLbl.frame.size.width, height)];
    [rightLbl setFrame:CGRectMake(rightLbl.frame.origin.x, rightLbl.frame.origin.y, rightLbl.frame.size.width, height)];

    if([item objectForKey:@"lat"]==nil && [item objectForKey:@"隐藏按钮"]==nil)
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    if([item objectForKey:@"隐藏按钮"]!=nil)
    {
        NSString *urlStr=[item objectForKey:@"隐藏按钮"];
        NSArray *iconArray=[urlStr componentsSeparatedByString:@"/"];
        NSString *iconName=[iconArray objectAtIndex:iconArray.count-1];
        
        NSString *filename=[savepath stringByAppendingString:iconName];
        UIButton *hiddenBtn=(UIButton *)[cell viewWithTag:103];
        if([CommonFunc fileIfExist:filename])
        {
            UIImage *img=[UIImage imageWithContentsOfFile:filename];
            [hiddenBtn setImage:img forState:UIControlStateNormal];
        }
        else
        {
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
    }
    return cell;
}
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *item=[detailArray objectAtIndex:indexPath.row];
    
    if([item objectForKey:@"lat"]!=nil)
    {
        NSString *lat = [item objectForKey:@"lat"];
        NSString *lon = [item objectForKey:@"lon"];
        
        NSString *address=[item objectForKey:@"右边"];
        DDIHelpView *controller=[self.storyboard instantiateViewControllerWithIdentifier:@"HelpView"];
        controller.navigationItem.title=[item objectForKey:@"左边"];
        controller.urlStr=[NSString stringWithFormat:@"http://mo.amap.com/?q=%.10f,%.10f&name=%@&dev=1",lat.doubleValue,lon.doubleValue,address];
        [self.navigationController pushViewController:controller animated:YES];
    }
    else if([item objectForKey:@"隐藏按钮"]!=nil)
    {
        UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
        //UILabel *left=(UILabel *)[cell viewWithTag:101];
        //UILabel *right=(UILabel *)[cell viewWithTag:102];
        UIButton *btn=(UIButton *)[cell viewWithTag:103];
        if(btn.frame.size.width==0)
        {
            [UIView beginAnimations:@"my_own_animation" context:nil];
            [btn setFrame:CGRectMake(5, (cell.frame.size.height-32)/2, 32, 32)];
            //[left setFrame:CGRectMake(left.frame.origin.x+42, left.frame.origin.y, left.frame.size.width, left.frame.size.height)];
            //[right setFrame:CGRectMake(right.frame.origin.x+42, right.frame.origin.y, right.frame.size.width, right.frame.size.height)];
            [UIView commitAnimations];
            [self performSelector:@selector(hideDeleteBtn:) withObject:cell afterDelay:3.0];
        }

    }
    
}
-(void)hideDeleteBtn:(UITableViewCell *)cell
{
    
    //UILabel *left=(UILabel *)[cell viewWithTag:101];
    //UILabel *right=(UILabel *)[cell viewWithTag:102];
    UIButton *btn=(UIButton *)[cell viewWithTag:103];
    if(btn!=nil && btn.frame.size.width!=0)
    {
        [UIView beginAnimations:@"my_own_animation1" context:nil];
        [btn setFrame:CGRectZero];
        //[left setFrame:CGRectMake(left.frame.origin.x-42, left.frame.origin.y, left.frame.size.width, left.frame.size.height)];
        //[right setFrame:CGRectMake(right.frame.origin.x-42, right.frame.origin.y, right.frame.size.width, right.frame.size.height)];
        [UIView commitAnimations];
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 列寬
    CGFloat leftwidth =self.view.frame.size.width*leftWidth.intValue/100-15;
    CGFloat rightwidth=self.view.frame.size.width-leftwidth-20;
    // 用何種字體進行顯示
    UIFont *font = [UIFont systemFontOfSize:16];
    // 該行要顯示的內容
    NSDictionary *item=[detailArray objectAtIndex:indexPath.row];
    NSString *leftcontent=[item objectForKey:@"左边"];
    NSString *rightcontent=[item objectForKey:@"右边"];
   
    // 計算出顯示完內容需要的最小尺寸
    CGSize size1 = [leftcontent sizeWithFont:font constrainedToSize:CGSizeMake(leftwidth, 1000.0f) lineBreakMode:NSLineBreakByWordWrapping];
    CGSize size2 = [rightcontent sizeWithFont:font constrainedToSize:CGSizeMake(rightwidth, 1000.0f) lineBreakMode:NSLineBreakByWordWrapping];
    // 這裏返回需要的高度
    int height=(size1.height>size2.height?size1.height:size2.height)+6;
    if(height<40)
        height=40;
    return height;
}
-(void)deleteCell:(UIButton *)btn
{
    UIView *tmpview=btn.superview;
    while(![tmpview isKindOfClass:[UITableViewCell class]])
        tmpview=tmpview.superview;
    NSIndexPath *indexPath=[self.tableView indexPathForCell:(UITableViewCell *)tmpview];
    
    NSDictionary *item=[detailArray objectAtIndex:indexPath.row];
    NSString *strUrl=[item objectForKey:@"隐藏按钮URL"];
    NSArray *tmpArray=[self.interfaceUrl componentsSeparatedByString:@"?"];
    strUrl=[tmpArray[0] stringByAppendingString:strUrl];
    NSURL *url = [NSURL URLWithString:strUrl];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    NSError *error;
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init ];
    [dic setObject:kUserIndentify forKey:@"用户较验码"];
    NSNumber *timeStamp=[[NSNumber alloc] initWithLong:[[NSDate new] timeIntervalSince1970]];
    [dic setObject:timeStamp forKey:@"DATETIME"];
    request.username=@"删除行";
    NSData *postData=[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
    postStr=[GTMBase64 base64StringBystring:postStr];
    [request setPostValue:postStr forKey:@"DATA"];
    [request setDelegate:self];
    [request setTag:indexPath.row];
    [request startAsynchronous];
    [requestArray addObject:request];
    alertTip = [[OLGhostAlertView alloc] initWithTitle:@"正在删除" message:nil timeout:0 dismissible:NO];
    [alertTip showInView:self.view];
}


@end
