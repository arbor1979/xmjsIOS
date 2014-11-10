//
//  DDICourseInfo.m
//  老师助手
//
//  Created by yons on 14-2-10.
//  Copyright (c) 2014年 dandian. All rights reserved.
//

#import "DDICourseInfo.h"
extern NSDictionary *LinkMandic;//联系人数据
extern NSMutableDictionary *userInfoDic;//课表数据
extern NSMutableDictionary *teacherInfoDic;//老师数据
extern Boolean kIOS7;
extern NSString *kUserIndentify;
extern int kUserType;
extern NSString *kInitURL;
@interface DDICourseInfo ()

@end

@implementation DDICourseInfo

- (void)viewDidLoad
{
    [super viewDidLoad];
    requestArray=[NSMutableArray array];
    grayStar=[UIImage imageNamed:@"star"];
    goldStar=[UIImage imageNamed:@"goldStar"];
    savePath=[CommonFunc createPath:@"/classNotes/"];
    [self.headBtn.imageView.layer setMasksToBounds:YES];
    [self.headBtn.imageView.layer setCornerRadius:5.0];
    NSArray *allLinkManArray=[LinkMandic objectForKey:@"数据源_用户信息列表"];
    for(int i=0;i<allLinkManArray.count;i++)
    {
        NSDictionary *item=[allLinkManArray objectAtIndex:i];
        NSString *userName=[item objectForKey:@"用户名"];
        if(userName && [userName isEqualToString:self.teacherUserName])
        {
            self.teacherName.text=[item objectForKey:@"姓名"];
            NSString *weiyima=[item objectForKey:@"用户唯一码"];
            NSString *picUrl=[item objectForKey:@"用户头像"];
            self.chargeClass.text=[item objectForKey:@"所带班级"];
            self.chargeCourse.text=[item objectForKey:@"所带课程"];
            
            
            NSString *userPic=[CommonFunc getImageSavePath:weiyima ifexist:YES];
            UIImage *headImage;
            if(userPic)
            {
                headImage=[UIImage imageWithContentsOfFile:userPic];
                oldImage=headImage;
                CGSize newSize=CGSizeMake(80, 80);
                headImage=[headImage scaleToSize1:newSize];
                headImage=[headImage cutFromImage:CGRectMake(0, 0, 80, 80)];
                
            }
            else
            {
                headImage=[UIImage imageNamed:@"unknowMan"];
                oldImage=headImage;
                headImage=[headImage scaleToSize1:CGSizeMake(80, 80)];
                if(picUrl && picUrl.length>0)
                {
                    NSURL *url = [NSURL URLWithString:picUrl];
                    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
                    request.username=weiyima;
                    [request setDelegate:self];
                    [request startAsynchronous];
                    [requestArray addObject:request];
                }
                
            }
            [self.headBtn setImage:headImage forState:UIControlStateNormal];
            break;
        }
    }
    [self getPingJiaData];
    /*
    NSNumber *grade=[item objectForKey:@"用户评级"];
    if(!grade) grade=[NSNumber numberWithInt:3];
    for(int j=0;j<grade.intValue;j++)
    {
        UIImageView *iv=[self.teacherGrade objectAtIndex:j];
        iv.image=goldStar;
    }
    NSMutableArray *scheduleArray=[[NSMutableArray alloc] initWithArray:[userInfoDic objectForKey:@"教师上课记录"]];
    NSMutableDictionary *classInfoDic=[[NSMutableDictionary alloc] initWithDictionary:[scheduleArray objectAtIndex:self.classIndex.intValue]];
    self.courseContent.text=[classInfoDic objectForKey:@"授课内容"];
    self.courseZuoYe.text=[classInfoDic objectForKey:@"作业布置"];
    NSNumber *grade1=[classInfoDic objectForKey:@"课程评级"];
    
    if(!grade1) grade1=[NSNumber numberWithInt:3];
    for(int j=0;j<grade1.intValue;j++)
    {
        UIImageView *iv=[self.courseGrade objectAtIndex:j];
        iv.image=goldStar;
    }
    NSString *chuqinrenName=[teacherInfoDic objectForKey:@"姓名"];
    NSArray *tmpArray=[chuqinrenName componentsSeparatedByString:@"["];
    self.chuqinren.text=[[tmpArray objectAtIndex:0] stringByAppendingString:@"的出勤"];
    NSArray *queqinArray=[classInfoDic objectForKey:@"缺勤情况登记JSON"];
    if(queqinArray && ![queqinArray isEqual:[NSNull null]])
    {
        for(int i=0;i<queqinArray.count;i++)
        {
            NSDictionary *item=[queqinArray objectAtIndex:i];
            NSString *xuehao=[item objectForKey:@"学号"];
            NSString *userid=[teacherInfoDic objectForKey:@"学号"];
            userid=[userid stringByReplacingOccurrencesOfString:@"jz" withString:@""];
            if([xuehao isEqualToString:userid])
            {
                self.chuqin.text=[item objectForKey:@"考勤类型"];
                break;
            }
        }
    }
    */
}
-(void) getPingJiaData
{
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init];
    [dic setObject:kUserIndentify forKey:@"用户较验码"];
    [dic setObject:self.classNo forKey:@"老师上课记录编号"];
    NSNumber *timeStamp=[[NSNumber alloc] initWithLong:[[NSDate new] timeIntervalSince1970]];
    [dic setObject:timeStamp forKey:@"DATETIME"];
    [dic setObject:self.teacherUserName forKey:@"老师用户名"];
    [dic setObject:self.className forKey:@"课程名称"];
    
    NSURL *url = [NSURL URLWithString:[kInitURL stringByAppendingString:@"GetCourseAndTeacherInfo.php"]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    NSError *error;
    request.userInfo=dic;
    NSData *postData=[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
    postStr=[GTMBase64 base64StringBystring:postStr];
    [request setPostValue:postStr forKey:@"DATA"];
    [request setDelegate:self];
    request.username=@"获取数据";
    [request startAsynchronous];
    [requestArray addObject:request];
    alertTip = [[OLGhostAlertView alloc] initWithTitle:@"正在获取数据" message:nil timeout:0 dismissible:NO];
    [alertTip showInView:self.view];
}
-(void)dealloc
{
    for(ASIHTTPRequest *req in requestArray)
    {
        [req clearDelegatesAndCancel];
    }
}
- (void)requestFinished:(ASIHTTPRequest *)request
{
    if([request.username isEqualToString:@"获取数据"])
    {
        if(alertTip)
            [alertTip removeFromSuperview];
        NSData *data = [request responseData];
        NSString* dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        dataStr=[GTMBase64 stringByBase64String:dataStr];
        data = [dataStr dataUsingEncoding: NSUTF8StringEncoding];
        NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        if(dict)
        {
            NSNumber *grade=[dict objectForKey:@"老师评分"];
            if(!grade) grade=[NSNumber numberWithInt:3];
            for(int j=0;j<grade.intValue;j++)
            {
                UIImageView *iv=[self.teacherGrade objectAtIndex:j];
                iv.image=goldStar;
            }
            NSNumber *grade1=[dict objectForKey:@"课程评分"];
            if(!grade1) grade1=[NSNumber numberWithInt:3];
            for(int j=0;j<grade1.intValue;j++)
            {
                UIImageView *iv=[self.courseGrade objectAtIndex:j];
                iv.image=goldStar;
            }
            self.courseContent.text=[dict objectForKey:@"授课内容"];
            self.courseZuoYe.text=[dict objectForKey:@"课后作业"];
            NSString *chuqinrenName=[teacherInfoDic objectForKey:@"姓名"];
            NSArray *tmpArray=[chuqinrenName componentsSeparatedByString:@"["];
            self.chuqinren.text=[[tmpArray objectAtIndex:0] stringByAppendingString:@"的出勤"];
            self.chuqin.text=[dict objectForKey:@"个人出勤"];
            photosArray=[dict objectForKey:@"课堂笔记图片"];
            if (photosArray!=nil && photosArray.count>0 && self.courseContent.text.length>0) {
                self.courseContent.text=[NSString stringWithFormat:@"%@\n\n\n",[dict objectForKey:@"授课内容"]];
            }
            [self.tableView reloadData];
            int top=[self tableView:self.tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]]-40;
            [self drawImageFromArray:top];
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
        UIView *parentCell=[item objectForKey:@"parentCell"];
        UIButton *btn=(UIButton *)[parentCell viewWithTag:request.tag];
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
    else
    {
        NSData *datas = [request responseData];
        UIImage *headImage=[[UIImage alloc]initWithData:datas];
        if(headImage!=nil)
        {
            NSString *path=[CommonFunc getImageSavePath:request.username ifexist:NO];
            [datas writeToFile:path atomically:YES];
            oldImage=headImage;
            headImage=[headImage scaleToSize1:CGSizeMake(80, 80)];
            CGRect newSize=CGRectMake(0, 0,80,80);
            headImage=[headImage cutFromImage:newSize];
            [self.headBtn setImage:headImage forState:UIControlStateNormal];
        }
    }
}

-(void)drawImageFromArray:(int)top
{
    UITableViewCell *parentCell=[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
    for(int i=0;i<5;i++)
    {
        UIView *subview=[parentCell viewWithTag:100+i];
        if(subview)
            [subview removeFromSuperview];
    }
    int j=(int)photosArray.count;
    int left=100;
    if(kIOS7)
        left=110;
    for(int i=0;i<j;i++)
    {
        UIButton *selBtn=[[UIButton alloc]initWithFrame:CGRectMake(left+i*41, top, 35, 35)];
        NSMutableDictionary *item=[NSMutableDictionary dictionaryWithDictionary:[photosArray objectAtIndex:i]];
        [item setObject:parentCell forKey:@"parentCell"];
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
        [selBtn addTarget:self action:@selector(popPhotoView:) forControlEvents:UIControlEventTouchUpInside];
        [parentCell addSubview:selBtn];
        
        
    }
    [self.tableView reloadData];
    
}

-(void)popPhotoView:(UIButton *)sender
{
    
    DDIPictureBrows *browserView = [[DDIPictureBrows alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    NSMutableArray *picArray=[NSMutableArray array];
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
        [browserView showFromIndex:(int)sender.tag-100];
    }
}
-(void)viewWillAppear:(BOOL)animated
{
    self.parentViewController.navigationItem.title=self.className;
    self.parentViewController.navigationItem.rightBarButtonItem =nil;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showBigPic:(id)sender {
    
    UIImageView *imageView = [UIImageView new];
    _headBtn=(UIButton *)sender;
    imageView.bounds = _headBtn.frame;
    imageView.backgroundColor=[UIColor blackColor];
    CGPoint point = CGPointMake(_headBtn.frame.origin.x+_headBtn.frame.size.width/2, _headBtn.frame.origin.y+_headBtn.frame.size.height/2);
    imageView.center = point;
    //imageView.transform = CGAffineTransformMakeRotation(M_PI_2);
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.image = oldImage;
    imageView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *gesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture1:)];
    UIPanGestureRecognizer *gesture2 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:nil];
    [imageView addGestureRecognizer:gesture1];
    [imageView addGestureRecognizer:gesture2];
    
    [self.view addSubview:imageView];
    [UIView animateWithDuration:0.5 animations:^{
        imageView.frame = CGRectMake(0,0+self.tableView.contentOffset.y,self.view.frame.size.width,self.view.frame.size.height);
    }];
    
}
- (void)handleGesture1:(UIGestureRecognizer *)gesture
{
    UIView *view = gesture.view;
    CGPoint point = CGPointMake(_headBtn.frame.origin.x+_headBtn.frame.size.width/2, _headBtn.frame.origin.y+_headBtn.frame.size.height/2);
    [UIView animateWithDuration:0.5 animations:^{
        view.bounds = CGRectMake(0,0,0,0);
        view.center = point;
    } completion:^(BOOL finished) {
        [view removeFromSuperview];
    }];
}

#pragma tableview
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int height=[super tableView:tableView heightForRowAtIndexPath:indexPath];
    UITableViewCell *cell=[self tableView:tableView cellForRowAtIndexPath:indexPath];
    if([self.cellsChangeHeight containsObject:cell] && cell.detailTextLabel.text.length>0)
    {
        [cell.detailTextLabel sizeToFit];
        NSString *text=cell.detailTextLabel.text;
        CGSize constraint =CGSizeMake(180.0f, 1000.0f);
        CGSize labelSize=[text sizeWithFont:cell.detailTextLabel.font constrainedToSize:constraint  lineBreakMode:NSLineBreakByCharWrapping];
        if(labelSize.height+20>height)
            height=labelSize.height+20;

    }
    return height;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if(section==1)
        return 10;
    else
        return 1;
}

@end
