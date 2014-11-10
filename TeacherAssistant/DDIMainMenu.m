//
//  DDIMainMenu.m
//  老师助手
//
//  Created by yons on 13-11-28.
//  Copyright (c) 2013年 dandian. All rights reserved.
//

#import "DDIMainMenu.h"
extern NSString *kUserIndentify;
extern NSMutableDictionary *userInfoDic;
extern NSMutableDictionary *lastMsgDic;
extern Boolean kIOS7;
extern NSString *curVersion;
extern NSMutableDictionary *teacherInfoDic;//老师数据

@interface DDIMainMenu ()

@end

@implementation DDIMainMenu



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    NSString *curName=[teacherInfoDic objectForKey:@"姓名"];
    curName=[curName stringByReplacingOccurrencesOfString:@"[家长]" withString:@""];
    curName=[curName stringByAppendingString:[NSString stringWithFormat:@"(%@)",[teacherInfoDic objectForKey:@"用户类型"]]];
    _lblName.text=curName;
    if([[teacherInfoDic objectForKey:@"用户类型"] isEqual:@"老师"])
        _lblBumen.text=[teacherInfoDic objectForKey:@"部门"];
    else
        _lblBumen.text=[teacherInfoDic objectForKey:@"班级"];
    
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,  NSUserDomainMask,YES);
    savePath=[[documentPaths objectAtIndex:0] stringByAppendingString:@"/teachers/"];
    BOOL fileExists = [fileManager fileExistsAtPath:savePath];
    if(!fileExists)
        [fileManager createDirectoryAtPath:savePath withIntermediateDirectories:NO attributes:nil error:nil];
    NSString *fileName=[NSString stringWithFormat:@"%@%@.jpg",savePath,[teacherInfoDic objectForKey:@"用户唯一码"]];
    
    requestArray=[[NSMutableArray alloc] init];
    if([fileManager fileExistsAtPath:fileName])
    {
        oldImage=[UIImage imageWithContentsOfFile:fileName];
        CGSize newSize=CGSizeMake(80, 80);
        headImage=[oldImage scaleToSize1:newSize];
        headImage=[headImage cutFromImage:CGRectMake(0, 0, 80, 80)];
        [_btnHead setImage:headImage forState:UIControlStateNormal];
    }
    else
    {
        
        NSString *urlStr=[teacherInfoDic objectForKey:@"用户头像"];
        NSURL *url = [NSURL URLWithString:urlStr];
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        request.username=[teacherInfoDic objectForKey:@"用户唯一码"];
        [request setDelegate:self];
        [request startAsynchronous];
        [requestArray addObject:request];
    }
        
    _lblBanben.text=[NSString stringWithFormat:@"软件版本：%@",curVersion];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSData *datas = [request responseData];
    oldImage=[[UIImage alloc]initWithData:datas];
    if(oldImage!=nil)
    {
        NSString *path=[CommonFunc getImageSavePath:request.username ifexist:NO];
        [datas writeToFile:path atomically:YES];
        headImage=[oldImage scaleToSize1:CGSizeMake(80, 80)];
        CGRect newSize=CGRectMake(0, 0,80,80);
        headImage=[headImage cutFromImage:newSize];
        [_btnHead setImage:headImage forState:UIControlStateNormal];
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


- (IBAction)reLogin:(id)sender {

    kUserIndentify=nil;
    userInfoDic=nil;
    if (lastMsgDic)
        lastMsgDic=nil;
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
    //[self dismissViewControllerAnimated:YES completion:nil];
    
}
-(UIBarButtonItem *) setupNavBackBtn
{
    //设置导航栏菜单
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 100.0, 29.0, 29.0)];
    [backBtn setTitle:@"" forState:UIControlStateNormal];
    [backBtn setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    backButtonItem.tintColor=[UIColor whiteColor];
    //self.navigationController.navigationItem.leftBarButtonItem = backButtonItem;
    return backButtonItem;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row==1)
    {
        DDIMyInforView *controller=[self.storyboard instantiateViewControllerWithIdentifier:@"MyInforView"];
        UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:controller];
        controller.navigationItem.leftBarButtonItem=[self setupNavBackBtn];
        controller.navigationItem.title=@"我的资料";
        [self presentViewController:nav animated:true completion:nil];
    }
    else if(indexPath.row==2)
    {
        DDINotifySetup *controller=[self.storyboard instantiateViewControllerWithIdentifier:@"notifySetup"];
        UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:controller];
        controller.navigationItem.leftBarButtonItem=[self setupNavBackBtn];
        controller.navigationItem.title=@"课程提醒";
        [self presentViewController:nav animated:true completion:nil];
        
    }
    else if(indexPath.row==3)
    {
        DDIShangkeTime *controller=[self.storyboard instantiateViewControllerWithIdentifier:@"ShangkeTime"];
        UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:controller];
        controller.navigationItem.leftBarButtonItem=[self setupNavBackBtn];
        controller.navigationItem.title=@"上课时间表";
        [self presentViewController:nav animated:true completion:nil];
        
    }
    else if(indexPath.row>=4 && indexPath.row<=6)
    {
        DDIHelpView *controller=[self.storyboard instantiateViewControllerWithIdentifier:@"HelpView"];
        UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:controller];
        controller.navigationItem.leftBarButtonItem=[self setupNavBackBtn];
        if(indexPath.row==4)
        {
            controller.navigationItem.title=@"常见问题";
            controller.urlStr=@"http://www.dandian.net/company/ICampus-faq.php";
        }
        else if(indexPath.row==5)
        {
            controller.navigationItem.title=@"软件授权协议";
            controller.urlStr=@"http://www.dandian.net/company/ICampus-contract.php";
        }
        else if(indexPath.row==6)
        {
            controller.navigationItem.title=@"关于我们";
            controller.urlStr=@"http://www.dandian.net/company/ICampus-aboutus.php";
        }
        [self presentViewController:nav animated:true completion:nil];
        
    }
    else if(indexPath.row==7)
    {
        DDIHelpQuest *controller=[self.storyboard instantiateViewControllerWithIdentifier:@"HelpQuest"];
        UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:controller];
        controller.navigationItem.leftBarButtonItem=[self setupNavBackBtn];
        controller.navigationItem.title=@"意见反馈";
        [self presentViewController:nav animated:true completion:nil];
        
    }
    else if(indexPath.row==8)
    {
        UIActionSheet *av=[[UIActionSheet alloc]initWithTitle:@"确认删除所有缓存图片，包括用户头像和聊天图片？" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确认" otherButtonTitles:nil, nil];
        [av showInView:self.view];
    }
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==0)
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *dirArray=[[NSArray alloc]initWithObjects:@"utils",@"teachers",@"students",@"parents",@"News",@"classRecord",@"classNotes",@"chatImages", nil];
        for(int i=0;i<dirArray.count;i++)
        {
            NSString *dir=[NSString stringWithFormat:@"/%@",[dirArray objectAtIndex:i]];
            NSString *path=[CommonFunc createPath:dir];
           [fileManager removeItemAtPath:path error:nil];
           [CommonFunc createPath:dir];
        }
        
        if(dirArray.count>0)
        {
            OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"已删除所有缓存文件"];
            [tipView show];
        }
    }
}

-(void)back:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)showBigPic:(id)sender {
    
    UIImageView *imageView = [UIImageView new];
    imageView.bounds = CGRectMake(0,0,0,0);
    imageView.backgroundColor=[UIColor blackColor];
    
    imageView.center = CGPointMake(60, 80);
    //imageView.transform = CGAffineTransformMakeRotation(M_PI_2);
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.image = oldImage;
    imageView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *gesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture1:)];
    UIPanGestureRecognizer *gesture2 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:nil];
    [imageView addGestureRecognizer:gesture1];
    [imageView addGestureRecognizer:gesture2];
    [self.parentViewController.view addSubview:imageView];
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
