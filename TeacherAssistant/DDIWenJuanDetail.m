//
//  DDIWenJuanDetail.m
//  掌上校园
//
//  Created by yons on 14-3-17.
//  Copyright (c) 2014年 dandian. All rights reserved.
//

#import "DDIWenJuanDetail.h"
extern NSString *kUserIndentify;//用户登录后的唯一识别码
extern NSString *kInitURL;
@interface DDIWenJuanDetail ()

@end

@implementation DDIWenJuanDetail

- (void)viewDidLoad
{
    [super viewDidLoad];

    requestArray=[NSMutableArray array];
    detailArray= [NSMutableArray array];
    self.tableView.backgroundColor=[UIColor colorWithRed:228/255.0 green:244/255.0 blue:234/255.0 alpha:1];
    [self loadDetailData];
    
    myGreen=[UIColor colorWithRed:39/255.0 green:174/255.0 blue:98/255.0 alpha:1];
    //定义一个toolBar
    topView = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
    //设置style
    [topView setBarStyle:UIBarStyleDefault];
    
    //定义两个flexibleSpace的button，放在toolBar上，这样完成按钮就会在最右边
    UIBarButtonItem * button1 =[[UIBarButtonItem  alloc]initWithBarButtonSystemItem:                                        UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem * button2 = [[UIBarButtonItem  alloc]initWithBarButtonSystemItem:                                        UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    //定义完成按钮
    UIBarButtonItem * doneButton = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStyleBordered  target:self action:@selector(resignKeyboard)];
    //在toolBar上加上这些按钮
    NSArray * buttonsArray = [NSArray arrayWithObjects:button1,button2,doneButton,nil];
    [topView setItems:buttonsArray];
    
    if([_examStatus isEqualToString:@"进行中"])
        enabled=true;
    else
        
        enabled=false;
    
    rightBtn= [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleBordered target:self action:@selector(saveAnswer)];
    savePath=[CommonFunc createPath:@"/wenJuanPic/"];
    addPhoto=[UIImage imageNamed:@"addPhoto"];
    
    pickerActionSheet = [[UIActionSheet alloc] initWithTitle:@"\n\n\n\n\n\n\n\n\n\n" delegate:nil  cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil, nil];
    pickerActionSheet.backgroundColor=[UIColor whiteColor];
    [pickerActionSheet setBounds:CGRectMake(0, 0, 100, 160)];
    pickerView= [[UIPickerView alloc] initWithFrame:CGRectMake(0, 40, 320, 120)];
    pickerView.delegate = self;
    pickerView.dataSource = self;
    pickerView.showsSelectionIndicator = YES;
    
    UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:nil];
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleBordered target:self action:@selector(docancel)];
    navItem.leftBarButtonItem = leftButton;
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStyleDone target:self action:@selector(done)];
    navItem.rightBarButtonItem = rightButton;
    NSArray *array = [[NSArray alloc] initWithObjects:navItem, nil];
    [navBar setItems:array];
    
    [pickerActionSheet addSubview:navBar];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    
    
    alertController = [UIAlertController alertControllerWithTitle:@"\n\n\n\n\n\n\n\n\n\n" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    pickerView.frame=CGRectMake(0, 40, alertController.view.bounds.size.width-16, 120);
    navBar.frame=CGRectMake(0, 0, alertController.view.bounds.size.width-16, 40);
    
    [alertController.view addSubview:navBar];
    [alertController.view addSubview:pickerView];
    
#endif
    
    //[actionSheet addSubview:pickerView];
    
    dtPickerView = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 40, 320, 120)];
    // [oneDatePicker setDate:[NSDate dateWithTimeIntervalSinceNow:48 * 20 * 18] animated:YES]; // 设置时间，有动画效果
    //dtPickerView.timeZone = [NSTimeZone timeZoneWithName:@"GTM+8"]; // 设置时区，中国在东八区
    //oneDatePicker.minimumDate = [NSDate dateWithTimeIntervalSinceNow:72 * 60 * 60 * -1]; // 设置最小时间
    //oneDatePicker.maximumDate = [NSDate dateWithTimeIntervalSinceNow:72 * 60 * 60]; // 设置最大时间
    dtPickerView.datePickerMode = UIDatePickerModeDate; // 设置样式
    // 以下为全部样式
    // typedef NS_ENUM(NSInteger, UIDatePickerMode) {
    //    UIDatePickerModeTime,           // 只显示时间
    //    UIDatePickerModeDate,           // 只显示日期
    //    UIDatePickerModeDateAndTime,    // 显示日期和时间
    //    UIDatePickerModeCountDownTimer  // 只显示小时和分钟 倒计时定时器
    // };

    
}

- (void) done{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    [alertController dismissViewControllerAnimated:YES completion:nil];
#else
    [pickerActionSheet dismissWithClickedButtonIndex:0 animated:YES];
#endif
    
    if([dtPickerView.superview isKindOfClass:[UIActionSheet class]])
    {
        
        NSString *currentDateStr = [CommonFunc stringFromDateShort:dtPickerView.date];
        [senderBtn setTitle:currentDateStr forState:UIControlStateNormal];
        
    }
    else if([pickerView.superview isKindOfClass:[UIActionSheet class]])
    {
        NSInteger index=[pickerView selectedRowInComponent:0];
        NSString *currentDateStr = [pickerArray objectAtIndex:index];
        [senderBtn setTitle:currentDateStr forState:UIControlStateNormal];
    }
    NSMutableDictionary *item=[NSMutableDictionary dictionaryWithDictionary:[detailArray objectAtIndex:senderBtn.tag]];
    [item setValue:senderBtn.titleLabel.text forKey:@"用户答案"];
    [detailArray replaceObjectAtIndex:senderBtn.tag withObject:item];
    
}

- (void) docancel{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    [alertController dismissViewControllerAnimated:YES completion:nil];
#else
    [pickerActionSheet dismissWithClickedButtonIndex:1 animated:YES];
#endif
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(enabled)
        self.navigationItem.rightBarButtonItem =rightBtn;
}

-(void) saveAnswer
{
    NSMutableArray *result=[NSMutableArray new];
    for (int i=0; i<detailArray.count; i++) {
        NSDictionary *item=[detailArray objectAtIndex:i];
        NSString *ifNeed=[item objectForKey:@"是否必填"];
        if(!ifNeed)
            ifNeed=@"是";
        if([[item objectForKey:@"类型"] isEqualToString:@"图片"])
        {
            NSArray *answer=[item objectForKey:@"用户答案"];
            if((!answer || answer.count==0 || [answer isEqual:[NSNull null]]) && [ifNeed isEqualToString:@"是"])
            {
                OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"请上传图片"];
                [tipView show];
                NSIndexPath *indexPath=[NSIndexPath indexPathForRow:0 inSection:i];
                [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
                return;
            }
            [result addObject:answer];
        }
        else
        {
            NSString *answer=[item objectForKey:@"用户答案"];
            if((!answer || answer.length==0 || [answer isEqual:[NSNull null]]) && [ifNeed isEqualToString:@"是"])
            {
                OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"请填写所有选项"];
                [tipView show];
                NSIndexPath *indexPath=[NSIndexPath indexPathForRow:0 inSection:i];
                [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
                return;
            }
            [result addObject:answer];
        }
        
    }
    rightBtn.enabled=false;
    [rightBtn setTitle:@"保存中"];
    NSArray *tmp=[_interfaceUrl componentsSeparatedByString:@"?"];
    NSString *urlStr=[tmp objectAtIndex:0];
    urlStr=[urlStr stringByAppendingString:saveUrl];
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init];
    [dic setObject:kUserIndentify forKey:@"用户较验码"];
    [dic setObject:result forKey:@"选项记录集"];
    NSNumber *timeStamp=[[NSNumber alloc] initWithLong:[[NSDate new] timeIntervalSince1970]];
    [dic setObject:timeStamp forKey:@"DATETIME"];
    
    NSURL *url = [NSURL URLWithString:urlStr];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    NSError *error;
    request.userInfo=dic;
    NSData *postData=[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
    postStr=[GTMBase64 base64StringBystring:postStr];
    [request setPostValue:postStr forKey:@"DATA"];
    [request setDelegate:self];
    request.username=@"保存数据";
    [request startAsynchronous];
    [requestArray addObject:request];
    
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
            self.title=[dict objectForKey:@"标题显示"];
            saveUrl=[dict objectForKey:@"提交地址"];
            detailArray=[NSMutableArray arrayWithArray:[dict objectForKey:@"调查问卷数值"]];
            
        }
        if(!dict || !detailArray || detailArray.count==0)
        {
            OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"没有任何数据"];
            [tipView showInView:self.view];
        }
        else
        {
            [self.tableView reloadData];
        }
    }
    else if([request.username isEqualToString:@"保存数据"])
    {
        rightBtn.enabled=true;
        [rightBtn setTitle:@"保存"];
        NSData *data = [request responseData];
        NSString* dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        dataStr=[GTMBase64 stringByBase64String:dataStr];
        data = [dataStr dataUsingEncoding: NSUTF8StringEncoding];
        NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        
        NSString *result=[dict objectForKey:@"状态"];
        if([result isEqualToString:@"成功"] || [[dict objectForKey:@"结果"] isEqualToString:@"成功"])
        {
            result=@"已保存";
            NSDictionary *outData=[dict objectForKey:@"输出数据"];
            if(outData)
            {
                detailArray=[NSMutableArray arrayWithArray:[outData objectForKey:@"调查问卷数值"]];
                _examStatus=[outData objectForKey:@"调查问卷状态"];
                if([_examStatus isEqualToString:@"进行中"])
                    enabled=true;
                else
                    enabled=false;
                if(!enabled)
                    self.navigationItem.rightBarButtonItem =Nil;
                [self.tableView reloadData];
                NSString *secLine=@"";
                outData=[dict objectForKey:@"调查问卷列表"];
                if(outData)
                {
                    NSArray *valueArray=[outData objectForKey:@"调查问卷数值"];
                    if(valueArray)
                    {
                        NSDictionary *tmpDic=[valueArray objectAtIndex:_key];
                        if(tmpDic)
                            secLine=[tmpDic objectForKey:@"第二行之日期"];
                    }
                    
                }
                if(_key>-1)
                {
                    NSMutableDictionary *item=[[NSMutableDictionary alloc]initWithDictionary:[_parentTitleArray objectAtIndex:_key]];
                    [item setObject:_examStatus forKey:@"第二行之状态"];
                    if(secLine && secLine.length>0)
                        [item setObject:secLine forKey:@"第二行之日期"];
                    [_parentTitleArray replaceObjectAtIndex:_key withObject:item];
                    
                }
                
            }
            
            NSString *autoClose=[dict objectForKey:@"自动关闭"];
            if([autoClose isEqualToString:@"是"])
            {
                [self.navigationController popViewControllerAnimated:YES];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"needRefreshDetail" object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"needRefreshTitle" object:nil];
                return;
            }
            
        }
        else
        {
            if([dict objectForKey:@"结果"]!=nil)
                result=[NSString stringWithFormat:@"保存失败:%@",[dict objectForKey:@"结果"]];
        }
        OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:result];
        [tipView show];
    }
    else if([request.username isEqualToString:@"上传问卷调查"])
    {
        if(rpv) [rpv removeFromSuperview];
        NSData *data = [request responseData];
        NSString *dataStr=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        dataStr=[GTMBase64 stringByBase64String:dataStr];
        data = [dataStr dataUsingEncoding: NSUTF8StringEncoding];
        NSMutableDictionary* dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSString * status=[dict objectForKey:@"STATUS"];
        if([status.lowercaseString isEqualToString:@"ok"])
        {
            
            NSDictionary *dic=request.userInfo;
            NSData *data=[dic objectForKey:@"data"];
            NSString *filename=[dict objectForKey:@"文件名"];
            filename=[savePath stringByAppendingString:filename];
            [data writeToFile:filename atomically:YES];
            NSMutableDictionary *item=[NSMutableDictionary dictionaryWithDictionary:[detailArray objectAtIndex:curRow]];
            NSMutableArray *photosArray=[NSMutableArray arrayWithArray:[item objectForKey:@"用户答案"]];
            [photosArray addObject:dict];
            [item setObject:photosArray forKey:@"用户答案"];
            [detailArray replaceObjectAtIndex:curRow withObject:item];
            NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:curRow];
            [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
            
        }
    }
    if([request.username isEqualToString:@"下载图片"])
    {
        NSData *datas = [request responseData];
        UIImage *img=[[UIImage alloc]initWithData:datas];
        NSDictionary *item=request.userInfo;
        NSString *filename=[item objectForKey:@"文件名"];
        filename=[savePath stringByAppendingString:filename];
        [datas writeToFile:filename atomically:YES];
        UIButton *btn=(UIButton *)[parentCell.contentView viewWithTag:request.tag];
        for(UIActivityIndicatorView *v in btn.subviews)
        {
            if([v isKindOfClass:[UIActivityIndicatorView class]])
            {
                [v stopAnimating];
                [v removeFromSuperview];
            }
        }
        [btn setImage:img forState:UIControlStateNormal];
    }
    if([request.username isEqualToString:@"删除图片"])
    {
        NSDictionary *dict=request.userInfo;
        NSString *filename=[dict objectForKey:@"文件名"];
        filename=[savePath stringByAppendingString:filename];
        [CommonFunc deleteFile:filename];
        NSMutableDictionary *item=[NSMutableDictionary dictionaryWithDictionary:[detailArray objectAtIndex:curRow]];
        NSMutableArray *photosArray=[NSMutableArray arrayWithArray:[item objectForKey:@"用户答案"]];
        [photosArray removeObject:dict];
        [item setObject:photosArray forKey:@"用户答案"];
        [detailArray replaceObjectAtIndex:curRow withObject:item];
        NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:curRow];
        [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
    }

    
}
- (void)requestFailed:(ASIHTTPRequest *)request
{
    if(alertTip)
        [alertTip removeFromSuperview];
    if([request.username isEqualToString:@"保存数据"])
    {
        rightBtn.enabled=true;
        [rightBtn setTitle:@"保存"];
    }
    if([request.username isEqualToString:@"上传问卷调查"])
    {
        if(rpv) [rpv removeFromSuperview];
    }
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
    return detailArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"rCell";
    UITableViewCell *cell= [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, 280, 20)];
        [titleLabel setLineBreakMode:NSLineBreakByCharWrapping];
        [titleLabel setNumberOfLines:0];
        [titleLabel setFont:[UIFont systemFontOfSize:16]];
        titleLabel.backgroundColor=[UIColor clearColor];
        [titleLabel setTag:11];
        
        [[cell contentView] addSubview:titleLabel];
        
        UILabel *lblResult=[[UILabel alloc]initWithFrame:CGRectZero];
        lblResult.tag=100;
        [lblResult setNumberOfLines:0];
        [lblResult setFont:[UIFont systemFontOfSize:15]];
        lblResult.backgroundColor=[UIColor clearColor];
        [[cell contentView] addSubview:lblResult];
    }
    
    float curY=0;
    NSString *groupId=[NSString stringWithFormat:@"%d",(int)indexPath.section];
    NSDictionary *item=[detailArray objectAtIndex:indexPath.section];
    NSString *type=[item objectForKey:@"类型"];
    for(UIView *subView in cell.contentView.subviews)
    {
        if([subView isKindOfClass:[QRadioButton class]])
        {
            [subView removeFromSuperview];
        }
        if([subView isKindOfClass:[QCheckBox class]])
        {
            [subView removeFromSuperview];
        }
        if([subView isKindOfClass:[UITextView class]])
            [subView removeFromSuperview];
        if([subView isKindOfClass:[UIButton class]])
            [subView removeFromSuperview];
        
        
    }
    UILabel *titleLabel=(UILabel *)[cell viewWithTag:11];
    [titleLabel setFrame:CGRectMake(10, 10, cell.contentView.frame.size.width-20, cell.frame.size.height-10)];
    titleLabel.text=[NSString stringWithFormat:@"%d.%@",(int)indexPath.section+1,[item objectForKey:@"题目"]];
    [titleLabel sizeToFit];
    curY=titleLabel.frame.size.height+10;
    NSArray *abcArray=[item objectForKey:@"选项"];
    for(int i=0;i<abcArray.count;i++)
    {
        
        NSString *neirong=[abcArray objectAtIndex:i];
        if(neirong==nil || neirong.length==0)
            continue;
        
        if([type isEqualToString:@"单选"])
        {

            QRadioButton *bodybtn = [[QRadioButton alloc] initWithDelegate:self groupId:groupId];
            bodybtn.tag=12+i;
            bodybtn.enabled=enabled;
            [bodybtn setFrame:CGRectMake(20, curY, cell.frame.size.width-40, 25)];
            
            UILabel *detailLabel=[[UILabel alloc]initWithFrame:CGRectMake(20, 5, bodybtn.frame.size.width-20, 20)];
            [detailLabel setTextColor:[UIColor darkGrayColor]];
            [detailLabel setBackgroundColor:[UIColor clearColor]];
            
            [detailLabel setFont:[UIFont boldSystemFontOfSize:15.0f]];
            [detailLabel setNumberOfLines:0];
            detailLabel.tag=100;
            [bodybtn addSubview:detailLabel];
            //bodybtn.titleLabel.lineBreakMode=NSLineBreakByWordWrapping;
            //[bodybtn addTarget:self action:@selector(answerClick:) forControlEvents:UIControlEventTouchUpInside];
            [[cell contentView] addSubview:bodybtn];
            
            
            detailLabel.text=neirong;
            [detailLabel sizeToFit];
            
            [bodybtn setFrame:CGRectMake(20, curY, cell.frame.size.width-40, detailLabel.frame.size.height+10)];
            curY=curY+bodybtn.frame.size.height+5;
            
            NSString *myAnswer=[item objectForKey:@"用户答案"];
            if([myAnswer isEqual:[NSNull null]])
                myAnswer=@"";
            if([myAnswer isEqualToString:neirong])
            {
                bodybtn.checked=YES;
            }
            else
                bodybtn.checked=NO;
        }
        else if([type isEqualToString:@"多选"])
        {

            QCheckBox *bodybtn = [[QCheckBox alloc] initWithDelegate:self];
            bodybtn.enabled=enabled;
            [bodybtn setTag:12+i];
            [bodybtn setFrame:CGRectMake(20, curY, cell.frame.size.width-40, 25)];
            
            UILabel *detailLabel=[[UILabel alloc]initWithFrame:CGRectMake(20, 5, bodybtn.frame.size.width-20, 20)];
            [detailLabel setTextColor:[UIColor darkGrayColor]];
            [detailLabel setBackgroundColor:[UIColor clearColor]];
            
            [detailLabel setFont:[UIFont boldSystemFontOfSize:15.0f]];
            [detailLabel setNumberOfLines:0];
            detailLabel.tag=100;
            [bodybtn addSubview:detailLabel];
            
            
            bodybtn.titleLabel.tag=indexPath.section;
            
            //[bodybtn addTarget:self action:@selector(answerClick:) forControlEvents:UIControlEventTouchUpInside];
            [[cell contentView] addSubview:bodybtn];
            
            detailLabel.text=neirong;
            [detailLabel sizeToFit];
            
            [bodybtn setFrame:CGRectMake(20, curY, cell.frame.size.width-40, detailLabel.frame.size.height+10)];
            curY=curY+bodybtn.frame.size.height+5;
            
            NSString *myAnswer=[item objectForKey:@"用户答案"];
            if([myAnswer isEqual:[NSNull null]])
                myAnswer=@"";
            NSArray *answerArray=[myAnswer componentsSeparatedByString:@"@"];
            if([answerArray containsObject:neirong])
                bodybtn.Checked=YES;
            else
                bodybtn.Checked=NO;
            
            
        }
        
    }
    
    if([type isEqualToString:@"单行文本输入框"])
    {
        UITextView *txtView=[[UITextView alloc] initWithFrame:CGRectMake(10,curY+5,cell.contentView.frame.size.width-20,100)];
        txtView.tag=indexPath.section;
        txtView.editable=enabled;
        txtView.font=[UIFont systemFontOfSize:15];
        txtView.delegate=self;
        [txtView setInputAccessoryView:topView];
        txtView.layer.borderWidth=1.0;
        txtView.layer.borderColor=[UIColor grayColor].CGColor;
        txtView.layer.cornerRadius=5.0;
        [[cell contentView] addSubview:txtView];
        txtView.text=[item objectForKey:@"用户答案"];
        curY=curY+txtView.frame.size.height+15;
    }
    
    if([type isEqualToString:@"日期"])
    {
         UIButton *dateBtn=[[UIButton alloc] initWithFrame:CGRectMake(10,curY+5,cell.contentView.frame.size.width-20,25)];
        dateBtn.tag=indexPath.section;
        [dateBtn setTitle:[item objectForKey:@"用户答案"] forState:UIControlStateNormal];
        [dateBtn setTitleColor:dateBtn.tintColor forState:UIControlStateNormal];
        [dateBtn addTarget:self action:@selector(popDatePicker:) forControlEvents:UIControlEventTouchUpInside];
        [[cell contentView] addSubview:dateBtn];
        curY=curY+dateBtn.frame.size.height+15;
    }
    
    if([type isEqualToString:@"下拉"])
    {
        UIButton *comboBtn=[[UIButton alloc] initWithFrame:CGRectMake(10,curY+5,cell.contentView.frame.size.width-20,25)];
        comboBtn.tag=indexPath.section;
        [comboBtn setTitle:[item objectForKey:@"用户答案"] forState:UIControlStateNormal];
        [comboBtn setTitleColor:comboBtn.tintColor forState:UIControlStateNormal];
        [comboBtn addTarget:self action:@selector(popComboPicker:) forControlEvents:UIControlEventTouchUpInside];
        [[cell contentView] addSubview:comboBtn];
        curY=curY+comboBtn.frame.size.height+15;
    }
    
    if([type isEqualToString:@"图片"])
    {
        
        parentCell=cell;
        top=curY+5;
        curY=curY+65;
        curRow=(int)indexPath.section;
        [self drawImageFromArray];
    }
    if([_examStatus isEqualToString:@"已结束"] && ![type isEqualToString:@"单行文本输入框"] && ![type isEqualToString:@"图片"] && ![type isEqualToString:@"日期"])
    {
     
        UILabel *lblResult=(UILabel *)[cell viewWithTag:100];
        [lblResult setFrame:CGRectMake(20, curY, cell.frame.size.width-40, 20)];
        lblResult.text=[item objectForKey:@"备注"];
        if(lblResult.text.length>7 && [[lblResult.text substringToIndex:7] isEqualToString:@"答题状态:错误"])
            [lblResult setTextColor:[UIColor redColor]];
        else if(lblResult.text.length>7 && [[lblResult.text substringToIndex:7] isEqualToString:@"答题状态:正确"])
            [lblResult setTextColor:myGreen];
        else
            [lblResult setTextColor:[UIColor blueColor]];
        [lblResult sizeToFit];
        curY=curY+lblResult.frame.size.height+5;
    }
    
    [cell setFrame:CGRectMake(0, 0, 320, curY)];
    return cell;
}
-(void)popDatePicker:(UIButton *)sender
{
    senderBtn=sender;
    for(UIView *item in pickerActionSheet.subviews)
    {
        if([item isKindOfClass:[UIDatePicker class]] || [item isKindOfClass:[UIPickerView class]])
        {
            [item removeFromSuperview];
        }
    }
    [pickerActionSheet addSubview:dtPickerView];
    dtPickerView.date = [CommonFunc dateFromStringShort:sender.titleLabel.text]; // 设置初始时间
    NSDictionary *item=[detailArray objectAtIndex:sender.tag];
    NSArray *subitem=[item objectForKey:@"选项"];
    if(subitem.count==2)
    {
        NSDate *minDate=[CommonFunc dateFromStringShort:[subitem objectAtIndex:0]];
        NSDate *maxDate=[CommonFunc dateFromStringShort:[subitem objectAtIndex:1]];
        dtPickerView.minimumDate=minDate;
        dtPickerView.maximumDate=maxDate;
    }
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    [self presentViewController:alertController animated:YES completion:nil];
#else
    [pickerActionSheet showInView:[UIApplication sharedApplication].keyWindow];
#endif
    
}

-(void)popComboPicker:(UIButton *)sender
{
    senderBtn=sender;
    for(UIView *item in pickerActionSheet.subviews)
    {
        if([item isKindOfClass:[UIDatePicker class]] || [item isKindOfClass:[UIPickerView class]])
        {
            [item removeFromSuperview];
        }
    }
    [pickerActionSheet addSubview:pickerView];

    NSDictionary *item=[detailArray objectAtIndex:sender.tag];
    pickerArray=[item objectForKey:@"选项"];
    if(pickerArray==nil)
        pickerArray=[NSArray array];
    NSInteger index=[pickerArray indexOfObject:sender.titleLabel.text];
    [pickerView selectRow:index inComponent:0 animated:NO];
    
    [pickerActionSheet showInView:[UIApplication sharedApplication].keyWindow];
}

#pragma mark 实现协议UIPickerViewDataSource方法
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component {

		return pickerArray.count;

	
}
#pragma mark 实现协议UIPickerViewDelegate方法
-(NSString *)pickerView:(UIPickerView *)pickerView
			titleForRow:(NSInteger)row forComponent:(NSInteger)component {

		return [pickerArray objectAtIndex:row];
	
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}
- (void)didSelectedRadioButton:(QRadioButton *)radio groupId:(NSString *)groupId
{
    NSMutableDictionary *item=[NSMutableDictionary dictionaryWithDictionary:[detailArray objectAtIndex:groupId.intValue]];
    UILabel *detailLabel=(UILabel *)[radio viewWithTag:100];
    [item setValue:detailLabel.text forKey:@"用户答案"];
    [detailArray replaceObjectAtIndex:groupId.intValue withObject:item];
}
- (void)didSelectedCheckBox:(QCheckBox *)checkbox checked:(BOOL)checked
{
    UILabel *detailLabel=(UILabel *)[checkbox viewWithTag:100];
    NSMutableDictionary *item=[NSMutableDictionary dictionaryWithDictionary:[detailArray objectAtIndex:checkbox.titleLabel.tag]];
    NSString *answer=[item objectForKey:@"用户答案"];
    NSMutableArray *answerArray=[NSMutableArray arrayWithArray:[answer componentsSeparatedByString:@"@"]];
    if(checked && ![answerArray containsObject:detailLabel.text])
        [answerArray addObject:detailLabel.text];
    else if(!checked && [answerArray containsObject:detailLabel.text])
        [answerArray removeObject:detailLabel.text];
    answer=[answerArray componentsJoinedByString:@"@"];
    [item setValue:answer forKey:@"用户答案"];
    [detailArray replaceObjectAtIndex:checkbox.titleLabel.tag withObject:item];
}
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    activeView=textView;

}
- (void)textViewDidChange:(UITextView *)textView
{
    NSMutableDictionary *item=[NSMutableDictionary dictionaryWithDictionary:[detailArray objectAtIndex:textView.tag]];
    [item setValue:textView.text forKey:@"用户答案"];
    [detailArray replaceObjectAtIndex:textView.tag withObject:item];

}
- (void)resignKeyboard {
    
    [activeView resignFirstResponder];
}

-(void)drawImageFromArray
{
    for(int i=0;i<5;i++)
    {
        UIView *subview=[parentCell.contentView viewWithTag:100+i];
        if(subview)
            [subview removeFromSuperview];
    }
    NSDictionary *item=[detailArray objectAtIndex:curRow];
    NSArray *photosArray=[item objectForKey:@"用户答案"];
    int j=(int)photosArray.count;
    for(int i=0;i<j;i++)
    {
        UIButton *selBtn=[[UIButton alloc]initWithFrame:CGRectMake(15+i*60, top, 50, 50)];
        NSDictionary *item=[photosArray objectAtIndex:i];
        NSString *filename=[item objectForKey:@"文件名"];
        filename=[savePath stringByAppendingString:filename];
        if([CommonFunc fileIfExist:filename])
        {
            UIImage *img=[UIImage imageWithContentsOfFile:filename];
            [selBtn setImage:img forState:UIControlStateNormal];
        }
        else
        {
            NSString *urlStr=[item objectForKey:@"文件地址"];
            NSURL *url = [NSURL URLWithString:urlStr];
            ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
            request.username=@"下载图片";
            request.userInfo=item;
            request.tag=100+i;
            UIActivityIndicatorView *aiv=[[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(10, 10, 30, 30)];
            aiv.activityIndicatorViewStyle=UIActivityIndicatorViewStyleGray;
            [selBtn addSubview:aiv];
            
            [request setDelegate:self];
            [request startAsynchronous];
            [requestArray addObject:request];
            [aiv startAnimating];
        }
        selBtn.tag=100+i;
        [selBtn.layer setMasksToBounds:YES];
        [selBtn.layer setCornerRadius:5];
        selBtn.layer.borderColor = [UIColor grayColor].CGColor;
        selBtn.layer.borderWidth =1.0;
        [selBtn addTarget:self action:@selector(addPhotoClick:) forControlEvents:UIControlEventTouchUpInside];
        [parentCell.contentView addSubview:selBtn];
    }
    if(j<5 && enabled)
    {
        UIButton *selBtn=[[UIButton alloc]initWithFrame:CGRectMake(15+j*60, top, 50, 50)];
        [selBtn setImage:addPhoto forState:UIControlStateNormal];
        selBtn.tag=100+j;
        [selBtn.layer setMasksToBounds:YES];
        [selBtn.layer setCornerRadius:5];
        selBtn.layer.borderColor = [UIColor grayColor].CGColor;
        selBtn.layer.borderWidth =1.0;
        [selBtn addTarget:self action:@selector(addPhotoClick:) forControlEvents:UIControlEventTouchUpInside];
        [parentCell.contentView addSubview:selBtn];
    }
    
}
-(void)addPhotoClick:(UIButton *)sender
{
    if([sender.imageView.image isEqual:addPhoto])
    {
        UIActionSheet* actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:nil
                                      delegate:self
                                      cancelButtonTitle:@"取消"
                                      destructiveButtonTitle:nil
                                      otherButtonTitles:@"照相机",@"本地相簿",nil];
        actionSheet.tag=-1;
       
        [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
    }
    else
    {
        if(enabled)
        {
            UIActionSheet* actionSheet = [[UIActionSheet alloc]
                                          initWithTitle:nil
                                          delegate:self
                                          cancelButtonTitle:@"取消"
                                          destructiveButtonTitle:@"删除"
                                          otherButtonTitles:@"打开",nil];
            actionSheet.tag=sender.tag;
            [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
        }
        else
            [self popPhotoView:[NSNumber numberWithInt:(int)sender.tag-100]];
    }
    
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(actionSheet.tag==-1)
    {
        
        switch (buttonIndex) {
            case 0://照相机
            {
                UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                imagePicker.delegate = self;
                imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                imagePicker.allowsEditing=false;
                imagePicker.mediaTypes =  [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
                [self presentViewController:imagePicker animated:YES completion:nil];
                
            }
                break;
            case 1://本地相簿
            {
                UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                imagePicker.delegate = self;
                imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                imagePicker.allowsEditing=false;
                imagePicker.mediaTypes =  [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
                [self presentViewController:imagePicker animated:YES completion:nil];
                
            }
                break;
                
            default:
                break;
        }
        
    }
    else
    {
        switch (buttonIndex) {
            case 0://删除
            {
                NSDictionary *item=[detailArray objectAtIndex:curRow];
                NSArray *photosArray=[item objectForKey:@"用户答案"];
                NSDictionary *subitem=[photosArray objectAtIndex:actionSheet.tag-100];
                [self deleteRemoteFile:subitem];
            }
                break;
            case 1://打开
            {
                int index=(int)actionSheet.tag-100;
                [self performSelector:@selector(popPhotoView:) withObject:[NSNumber numberWithInt:index] afterDelay:0.6];
            }
                break;
            default:
                break;
        }
    }
}
-(void) deleteRemoteFile:(NSDictionary *)item
{
    NSString *filename=[item objectForKey:@"文件名"];
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init];
    [dic setObject:kUserIndentify forKey:@"用户较验码"];
    NSNumber *timeStamp=[[NSNumber alloc] initWithLong:[[NSDate new] timeIntervalSince1970]];
    [dic setObject:timeStamp forKey:@"DATETIME"];
    [dic setObject:@"问卷调查" forKey:@"图片类别"];
    [dic setObject:filename forKey:@"课件名称"];
    
    NSURL *url = [NSURL URLWithString:[kInitURL stringByAppendingString:@"KeJianDelete.php"]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    NSError *error;
    NSData *postData=[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
    postStr=[GTMBase64 base64StringBystring:postStr];
    [request setPostValue:postStr forKey:@"DATA"];
    [request setDelegate:self];
    request.username=@"删除图片";
    request.userInfo=item;
    [requestArray addObject:request];
    [request startAsynchronous];
    
}
#pragma mark -
#pragma UIImagePickerController Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:(NSString*)kUTTypeImage]) {
        UIImage  *img = [info objectForKey:UIImagePickerControllerOriginalImage];
        CGSize newsize=CGSizeMake(1280, 720);
        img=[img scaleToSize:newsize];
        NSData *fileData = UIImageJPEGRepresentation(img, 0.5);
        [self uploadFile:fileData];
        
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}


-(void) uploadFile:(NSData *)data
{
    NSString *uploadUrl= [kInitURL stringByAppendingString:@"upload.php"];
    NSURL *url =[NSURL URLWithString:uploadUrl];
    
    ASIFormDataRequest *request =[ASIFormDataRequest requestWithURL:url];
    [request setPostFormat:ASIMultipartFormDataPostFormat];
    [request setRequestMethod:@"POST"];
    
    [request addData:data withFileName:@"jpg" andContentType:@"image/jpeg" forKey:@"filename"];//This would be the file name which is accepting image object on server side e.g. php page accepting file
    [request setPostValue:kUserIndentify forKey:@"用户较验码"];
    [request setPostValue:self.title forKey:@"课程名称"];
    [request setPostValue:self.title forKey:@"老师上课记录编号"];
    [request setPostValue:@"问卷调查" forKey:@"图片类别"];
    [request setDelegate:self];
    NSDictionary *dic=[NSDictionary dictionaryWithObject:data forKey:@"data"];
    request.username=@"上传问卷调查";
    request.userInfo=dic;
    request.uploadProgressDelegate=self;
    request.showAccurateProgress=YES;
    request.timeOutSeconds=300;
    [request startAsynchronous];
    [requestArray addObject:request];
    NSDictionary *item=[detailArray objectAtIndex:curRow];
    NSArray *photosArray=[item objectForKey:@"用户答案"];
    UIButton *btn=(UIButton *)[parentCell.contentView viewWithTag:photosArray.count+100];
    if(btn)
    {
        if(rpv)
            [rpv removeFromSuperview];
        else
        {
            MDRadialProgressTheme *newTheme = [[MDRadialProgressTheme alloc] init];
            newTheme.completedColor = [UIColor colorWithRed:90/255.0 green:212/255.0 blue:39/255.0 alpha:1.0];
            newTheme.incompletedColor = [UIColor colorWithRed:164/255.0 green:231/255.0 blue:134/255.0 alpha:1.0];
            newTheme.centerColor = [UIColor clearColor];
            newTheme.centerColor = [UIColor colorWithRed:224/255.0 green:248/255.0 blue:216/255.0 alpha:1.0];
            newTheme.sliceDividerHidden = YES;
            newTheme.labelColor = [UIColor blackColor];
            newTheme.labelShadowColor = [UIColor whiteColor];
            rpv = [[MDRadialProgressView alloc] initWithFrame:CGRectMake(0, 0, 50, 50) andTheme:newTheme];
        }
        rpv.progressTotal = 100;
        rpv.progressCounter = 0;
        [btn addSubview:rpv];
    }
    
}
-(void)setProgress:(float)newProgress;
{
    rpv.progressCounter = newProgress*100;
}
-(void)popPhotoView:(NSNumber *)index
{
    
    DDIPictureBrows *browserView = [[DDIPictureBrows alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    NSMutableArray *picArray=[NSMutableArray array];
    NSDictionary *item=[detailArray objectAtIndex:curRow];
    NSArray *photosArray=[item objectForKey:@"用户答案"];
    for(int i=0;i<photosArray.count;i++)
    {
        NSDictionary *item=[photosArray objectAtIndex:i];
        NSString *filename=[item objectForKey:@"文件名"];
        filename=[savePath stringByAppendingString:filename];
        if([CommonFunc fileIfExist:filename])
        {
            UIImage *img=[UIImage imageWithContentsOfFile:filename];
            [picArray addObject:img];
        }
    }
    if(picArray.count>0)
    {
        browserView.picArray=picArray;
        [browserView showFromIndex:index.intValue];
    }
}
@end
