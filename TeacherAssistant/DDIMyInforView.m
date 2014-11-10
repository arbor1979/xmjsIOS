//
//  DDIMyInforView.m
//  老师助手
//
//  Created by yons on 13-12-20.
//  Copyright (c) 2013年 dandian. All rights reserved.
//

#import "DDIMyInforView.h"
extern NSMutableDictionary *teacherInfoDic;//老师数据
extern NSDictionary *LinkMandic;
extern NSString *kUserIndentify;
extern Boolean kIOS7;
extern int kUserType;
@interface DDIMyInforView ()

@end

@implementation DDIMyInforView

- (void)viewDidLoad
{
    [super viewDidLoad];
    if(kIOS7)
    {
        //self.automaticallyAdjustsScrollViewInsets=NO;
        self.edgesForExtendedLayout=UIRectEdgeNone;
    }
    requestArray=[[NSMutableArray alloc] init];
    _disableChangeArray=[[NSMutableArray alloc] init];
   
    
    if(_userWeiYi==nil || [_userWeiYi isEqualToString:[teacherInfoDic objectForKey:@"用户唯一码"]])
    {
        _userWeiYi=[teacherInfoDic objectForKey:@"用户唯一码"];
        theTeacherDic=teacherInfoDic;
    }
    else
    {
        NSDictionary *duizhaoDic=[LinkMandic objectForKey:@"数据源_用户信息列表_对照表"];
        NSArray *allLinkManArray=[LinkMandic objectForKey:@"数据源_用户信息列表"];
        NSNumber *key=[duizhaoDic objectForKey:_userWeiYi];
        if(key)
            theTeacherDic=[allLinkManArray objectAtIndex:key.intValue];
    }
    
    NSArray *tmpArray=[_userWeiYi componentsSeparatedByString:@"_"];
    if([[tmpArray objectAtIndex:1] isEqualToString:@"老师"])
    {

        [_disableChangeArray addObject:@"性别"];
        if(kUserType==1)
            [_disableChangeArray addObject:@"手机"];
        [_disableChangeArray addObject:@"电邮"];
        [_disableChangeArray addObject:@"部门"];
        [_disableChangeArray addObject:@"所带班级"];
        [_disableChangeArray addObject:@"所带课程"];
        [_disableChangeArray addObject:@"登录时间"];
    }
    else
    {
        [_disableChangeArray addObject:@"性别"];
        [_disableChangeArray addObject:@"学号"];
        [_disableChangeArray addObject:@"班级"];
        [_disableChangeArray addObject:@"登录时间"];
    }
    
    _headImage=[UIImage imageNamed:@"unknowMan"];
    _headImage=[_headImage scaleToSize1:CGSizeMake(80, 80)];
    
    //获取已保存的头像
    /*
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,  NSUserDomainMask,YES);
    _savePath=[[documentPaths objectAtIndex:0] stringByAppendingString:@"/teachers/"];
    BOOL fileExists = [fileManager fileExistsAtPath:_savePath];
    if(!fileExists)
        [fileManager createDirectoryAtPath:_savePath withIntermediateDirectories:NO attributes:nil error:nil];
    NSString *fileName=[NSString stringWithFormat:@"%@%@.jpg",_savePath,_userWeiYi];
    
    if([fileManager fileExistsAtPath:fileName])
    {
        _oldImage=[UIImage imageWithContentsOfFile:fileName];
        CGSize newSize=CGSizeMake(80, 80);
        _headImage=[_oldImage scaleToSize1:newSize];
        _headImage=[_headImage cutFromImage:CGRectMake(0, 0, 80, 80)];
    }
    else
    {
     */
        NSString *urlStr=[theTeacherDic objectForKey:@"用户头像"];
        NSURL *url = [NSURL URLWithString:urlStr];
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        request.username=_userWeiYi;
        [request setDelegate:self];
        [request startAsynchronous];
        [requestArray addObject:request];
    //}
    
    
    

}
- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSData *datas = [request responseData];
    _oldImage=[[UIImage alloc]initWithData:datas];
    if(_oldImage!=nil)
    {
        NSString *path=[CommonFunc getImageSavePath:request.username ifexist:NO];
        [datas writeToFile:path atomically:YES];
        _headImage=[_oldImage scaleToSize1:CGSizeMake(80, 80)];
        CGRect newSize=CGRectMake(0, 0,80,80);
        _headImage=[_headImage cutFromImage:newSize];
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];

    }
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    if(section==0)
        return 1;
    else
        return _disableChangeArray.count;
        
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=nil;
    if(indexPath.section==0)
    {
        static NSString *CellIdentifier1 = @"Cell1";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1 forIndexPath:indexPath];
        UIButton *headBtn=(UIButton *)[cell viewWithTag:11];
        [headBtn.layer setMasksToBounds:YES];
        [headBtn.layer setCornerRadius:5.0]; //设置矩形四个圆角半径
        
        [headBtn setImage:_headImage forState:UIControlStateNormal];
        UILabel *realName=(UILabel *)[cell viewWithTag:12];
        realName.text=[theTeacherDic objectForKey:@"姓名"];
        UILabel *usertype=(UILabel *)[cell viewWithTag:13];
        if([theTeacherDic objectForKey:@"用户类型"])
            usertype.text=[NSString stringWithFormat:@"(%@)",[theTeacherDic objectForKey:@"用户类型"]];
        else
            usertype.text=@"";
    }
    else
    {
        static NSString *CellIdentifier2 = @"Cell2";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
        UILabel *title=nil;
        UILabel *detail=nil;
        if(cell==nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier2] ;
            [cell.detailTextLabel setNumberOfLines:0];
            cell.detailTextLabel.font=[UIFont systemFontOfSize:15];
        }
        
        title=cell.textLabel;
        detail=cell.detailTextLabel;
        title.text=[_disableChangeArray objectAtIndex:indexPath.row];
        if([[theTeacherDic objectForKey:title.text] isEqual:[NSNull null]])
            detail.text=@"";
        else
            detail.text=[theTeacherDic objectForKey:title.text];
        
        CGSize size = [detail.text sizeWithFont:detail.font constrainedToSize:CGSizeMake(220, 1000) lineBreakMode:NSLineBreakByWordWrapping];
        
        [detail setFrame:CGRectMake(detail.frame.origin.x, detail.frame.origin.y, size.width, size.height)];
        [detail sizeToFit];
    }
    
        
    // Configure the cell...
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==0)
        return 100;
    else
    {
        UITableViewCell *cell=[self tableView:tableView cellForRowAtIndexPath:indexPath];
        UILabel *detail=cell.detailTextLabel;
        
        if(detail.frame.size.height>24)
            return detail.frame.size.height+20;
        else
            return 44;
    
    }
}

- (IBAction)showBigPic:(id)sender {
    
    UIImageView *imageView = [UIImageView new];
    imageView.bounds = CGRectMake(0,0,0,0);
    imageView.backgroundColor=[UIColor blackColor];
    
    imageView.center = CGPointMake(60, 80);
    //imageView.transform = CGAffineTransformMakeRotation(M_PI_2);
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.image = _oldImage;
    imageView.userInteractionEnabled = YES;

    UITapGestureRecognizer *gesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture1:)];
    UIPanGestureRecognizer *gesture2 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:nil];
    [imageView addGestureRecognizer:gesture1];
    [imageView addGestureRecognizer:gesture2];
    [self.view addSubview:imageView];
    [UIView animateWithDuration:0.5 animations:^{
        imageView.frame = CGRectMake(0,self.tableView.contentOffset.y,self.view.frame.size.width,self.view.frame.size.height);
    }];
    
}
- (void)handleGesture1:(UIGestureRecognizer *)gesture
{
    UIView *view = gesture.view;
    
    [UIView animateWithDuration:0.5 animations:^{
        view.bounds = CGRectMake(0,0,0,0);
        view.center = CGPointMake(60, 80);
    } completion:^(BOOL finished) {
        [view removeFromSuperview];
    }];
}
@end
