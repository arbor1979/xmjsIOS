//
//  homeViewController.m
//  CollectionView
//
//  Created by d2space on 14-2-12.
//  Copyright (c) 2014年 D2space. All rights reserved.
//

#import "DDIWaterFallAlbum.h"
#import "WaterFLayout.h"
extern int kUserType;
extern NSString *kInitURL;//默认单点webServic
extern NSString *kUserIndentify;//用户登录后的唯一识别码
extern NSMutableDictionary *teacherInfoDic;//老师数据
extern Boolean kIOS7;
extern DDIDataModel *datam;
extern NSString *kStuState;
@interface DDIWaterFallAlbum ()

@end

@implementation DDIWaterFallAlbum

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addWaterFollow];
    aiv=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    aiv.center=CGPointMake(self.waterfall.view.bounds.size.width/2, self.waterfall.view.bounds.size.height/2-50);
    [aiv setHidesWhenStopped:YES];
    [self.view addSubview:aiv];
    requestArray=[NSMutableArray array];
    
    
    //设置导航栏菜单
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 26.0, 26.0)];
    [backBtn setTitle:@"" forState:UIControlStateNormal];
    [backBtn setBackgroundImage:[UIImage imageNamed:@"photograph"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(beginPhotograph) forControlEvents:UIControlEventTouchUpInside];
    cameraBtn = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    
    
    segmentedControl=[[UISegmentedControl alloc] initWithFrame:CGRectMake(0, 8, 100, 26) ];
    [segmentedControl insertSegmentWithTitle:@"全校" atIndex:0 animated:NO];
    if(kUserType==1)
        [segmentedControl insertSegmentWithTitle:@"本部门" atIndex:1 animated:NO];
    else
        [segmentedControl insertSegmentWithTitle:@"本班" atIndex:1 animated:NO];
    [segmentedControl insertSegmentWithTitle:@"人气" atIndex:2 animated:NO];
    
    [segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    segmentedControl.selectedSegmentIndex=0;
    segmentedControl.tintColor = [UIColor blackColor];
    if(!kIOS7)
    {
        [segmentedControl.layer setBorderColor:[UIColor colorWithWhite:0 alpha:0.8].CGColor];
        [segmentedControl.layer setBorderWidth:1.0f];
        [segmentedControl.layer setCornerRadius:4.0f];
        [segmentedControl.layer setMasksToBounds:YES];
    }
    
    [self segmentAction:segmentedControl];
    if([kStuState isEqualToString:@"新生状态"])
    {
        segmentedControl.hidden=YES;
        cameraBtn=nil;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(addNewImage:)
                                                 name:@"newImageUpload"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getAlbumUnreadList)
                                                 name:@"newAlbumMessage"
                                               object:nil];
    lbUnread=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 24)];
    lbUnread.backgroundColor=[UIColor colorWithRed:228/255.0 green:244/255.0 blue:234/255.0 alpha:0.8f];
    lbUnread.titleLabel.font=[UIFont systemFontOfSize:12];
    [lbUnread setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [lbUnread addTarget:self action:@selector(gotoUnreadList) forControlEvents:UIControlEventTouchUpInside];
    [self getAlbumUnreadList];
}
-(void)getAlbumUnreadList
{
    msgList=[datam getAlbumMsgList:[teacherInfoDic objectForKey:@"用户唯一码"] ifRead:0];
    if(msgList && msgList.count>0)
    {

        [lbUnread setTitle:[NSString stringWithFormat:@"你有%lu条未读消息,点击查看",(unsigned long)msgList.count] forState:UIControlStateNormal];
        [lbUnread removeFromSuperview];
        [self.view addSubview:lbUnread];
    }
    
}
-(void)gotoUnreadList
{
    
    [lbUnread removeFromSuperview];
    self.tabBarItem.badgeValue=nil;
    [datam updateUnreadAlbumMsg:msgList];
    if(msgList && msgList.count>0)
    {
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        DDIPraiseDetail *itemController=[mainStoryboard instantiateViewControllerWithIdentifier:@"praiseDetail"];
        itemController.praiseList=msgList;
        itemController.title=@"相册未读消息";
        [self.navigationController pushViewController:itemController animated:YES];
    }
}
-(void)addNewImage:(NSNotification *)notification
{
    if(notification)
    {
        NSDictionary *item=[notification userInfo];
        NSString *action=[item objectForKey:@"action"];
        if([action isEqualToString:@"新增"])
        {
            NSString *fanwei1=[item objectForKey:@"可见范围"];
            NSString *fanwei=[segmentedControl titleForSegmentAtIndex:[segmentedControl selectedSegmentIndex]];
            if([fanwei isEqual:@"本部门"])
                fanwei=@"本班";
            if([fanwei1 isEqual:fanwei])
            {
                [self.waterfall.imagesArr insertObject:item atIndex:0];
                [self.waterfall.collectionView reloadData];
            }
        }
        else if ([action isEqualToString:@"点赞"])
        {
            NSArray *praisedArray=[item objectForKey:@"praisedArray"];
            for(NSDictionary *item in praisedArray)
            {
                NSString *imageName=[item objectForKey:@"文件名"];
                for(NSMutableDictionary *wItem in self.waterfall.imagesArr)
                {
                    NSString *wImageName=[wItem objectForKey:@"文件名"];
                    if([imageName isEqualToString:wImageName])
                    {
                        NSArray *praiseList=[item objectForKey:@"点赞列表"];
                        [wItem setObject:[NSNumber numberWithInt:(int)praiseList.count] forKey:@"被赞次数"];
                        break;
                    }
                }
            }
            if(praisedArray.count>0)
            {
                [self.waterfall.collectionView reloadData];
            }
        }
        else if ([action isEqualToString:@"删除"])
        {
            NSArray *deleteArray=[item objectForKey:@"deleteArray"];
            for(NSDictionary *item in deleteArray)
            {
                NSString *imageName=[item objectForKey:@"文件名"];
                for(NSMutableDictionary *wItem in self.waterfall.imagesArr)
                {
                    NSString *wImageName=[wItem objectForKey:@"文件名"];
                    if([imageName isEqualToString:wImageName])
                    {
                        [self.waterfall.imagesArr removeObject:wItem];
                        break;
                    }
                }
            }
            if(deleteArray.count>0)
            {
                [self.waterfall.collectionView reloadData];
            }

        }
    }
}
-(void)beginPhotograph
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
}
-(void)segmentAction:(UISegmentedControl *)Seg{
    
    self.waterfall.imagesArr=nil;
    [self.waterfall.collectionView reloadData];
    [self loadInternetData];
    
}
- (void)loadInternetData{
    // Request
    NSURL *url = [NSURL URLWithString:[kInitURL stringByAppendingString:@"AlbumDownload.php?IsZip=1"]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    NSError *error;
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init ];
    [dic setObject:kUserIndentify forKey:@"用户较验码"];
    NSString *fanwei=@"全校";
    if([kStuState isEqualToString:@"新生状态"])
        fanwei=@"新生";
    else
    {
        if(segmentedControl.selectedSegmentIndex==0)
        {
            fanwei=@"全校";
        }
        else if(segmentedControl.selectedSegmentIndex==1)
        {
            if(kUserType==1)
                fanwei=[teacherInfoDic objectForKey:@"部门"];
            else
                fanwei=[teacherInfoDic objectForKey:@"班级"];
        }
        else if(segmentedControl.selectedSegmentIndex==2)
        {
            fanwei=@"人气";
        }
    }
    [dic setObject:fanwei forKey:@"范围"];
    if(self.waterfall.imagesArr!=nil && self.waterfall.imagesArr.count>0)
    {
        NSDictionary *item=[self.waterfall.imagesArr objectAtIndex:0];
        NSString *filename=[item objectForKey:@"文件名"];
        [dic setObject:filename forKey:@"curImageName"];
    }
    
    NSNumber *timeStamp=[[NSNumber alloc] initWithLong:[[NSDate new] timeIntervalSince1970]];
    [dic setObject:timeStamp forKey:@"DATETIME"];
    request.username=@"获取相册";
    NSData *postData=[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
    postStr=[GTMBase64 base64StringBystring:postStr];
    [request setPostValue:postStr forKey:@"DATA"];
    [request setDelegate:self];
    request.timeOutSeconds=300;
    [request startAsynchronous];
    [requestArray addObject:request];
    [aiv startAnimating];
    
}
- (void)requestFinished:(ASIHTTPRequest *)request
{
    [aiv stopAnimating];
    if([request.username isEqualToString:@"获取相册"])
    {
        
        NSData *data = [request responseData];
        NSString* dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        data   = [[NSData alloc] initWithBase64EncodedString:dataStr options:0];
        NSData *upzipData = [LFCGzipUtillity uncompressZippedData:data];
        
        id res = [NSJSONSerialization JSONObjectWithData:upzipData options:NSJSONReadingMutableContainers error:nil];
        if (res && [res isKindOfClass:[NSDictionary class]]) {
            if(self.waterfall.imagesArr==nil || self.waterfall.imagesArr.count==0)
            {
                self.waterfall.imagesArr=[NSMutableArray arrayWithArray:[res objectForKey:@"相册"]];
                if(self.waterfall.imagesArr.count==0)
                {
                    OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"还没有照片，现在就上传一张吧"];
                    [tipView showInView:self.view];
                }
            }
            else
            {
                NSArray *newDataArray=[res objectForKey:@"相册"];
                if(newDataArray!=nil)
                {
                    for(int i=(int)newDataArray.count-1;i>=0;i--)
                    {
                        NSDictionary *item=[newDataArray objectAtIndex:i];
                        [self.waterfall.imagesArr insertObject:item atIndex:0];
                    }
                }
                [self.waterfall doneLoadingTableViewData:[NSNumber numberWithInt:(int)newDataArray.count]];
            }
            [self.waterfall.collectionView reloadData];
            
        } else {
            
            NSLog(@"arr dataSourceDidError == %@",self.waterfall.imagesArr);
        }
    }
    if([request.username isEqualToString:@"浏览"])
    {
        
    }
}
- (void)requestFailed:(ASIHTTPRequest *)request
{
    [aiv stopAnimating];
    NSError *error = [request error];
    NSLog(@"请求失败:%@",[error localizedDescription]);
    OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:[error localizedDescription]];
    [tipView showInView:self.view];
}
- (void)addWaterFollow
{
//    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    WaterFLayout* flowLayout = [[WaterFLayout alloc] init];
    self.waterfall = [[WaterF alloc]initWithCollectionViewLayout:flowLayout];
    //self.waterfall.textsArr = self.texts;
    self.waterfall.sectionNum = 1;
    self.waterfall.textViewHeight=18;
    [self.waterfall.view setFrame:self.view.bounds];
    CGFloat width = self.view.bounds.size.width- flowLayout.sectionInset.left - flowLayout.sectionInset.right;
    CGFloat itemWidth = floorf((width - (flowLayout.columnCount - 1) * flowLayout.minimumColumnSpacing) / flowLayout.columnCount);
    self.waterfall.imagewidth = itemWidth;
    [self.view addSubview:self.waterfall.view];
    self.waterfall.delegate=self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)viewDidAppear:(BOOL)animated
{
    self.parentViewController.navigationItem.title=nil;
    self.parentViewController.navigationItem.titleView=segmentedControl;
    self.parentViewController.navigationItem.rightBarButtonItem=cameraBtn;
    [super viewDidAppear:animated];
}
-(void)viewWillDisappear:(BOOL)animated
{
    self.parentViewController.navigationItem.titleView=Nil;
    self.parentViewController.navigationItem.rightBarButtonItem=nil;
    [super viewWillDisappear:animated];
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"newImageUpload" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"newAlbumMessage" object:nil];
    for(ASIHTTPRequest *req in requestArray)
    {
        [req clearDelegatesAndCancel];
    }
}
#pragma UIImagePickerController Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage  *img;
    if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:(NSString*)kUTTypeImage]) {
        img = [info objectForKey:UIImagePickerControllerOriginalImage];
        CGSize newsize=CGSizeMake(800, 800);
        img=[img scaleToSize:newsize];
        //NSData *fileData = UIImageJPEGRepresentation(img, 0.5);
        
        
        
    }
    [picker dismissViewControllerAnimated:NO completion:nil];
    if(img)
        [self performSegueWithIdentifier:@"popSendView" sender:img];
    else
    {
        OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"获取图片失败"];
        [tipView showInView:self.view];
    }
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}



-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"popSendView"])
    {
        UINavigationController *NavController=segue.destinationViewController;
        
        DDIAlbumSend *dest1=[NavController.childViewControllers objectAtIndex:0];
        dest1.image=sender;
        
    }
    
}
-(void)reloadNewAlbumData
{
    [self loadInternetData];
}
-(NSMutableArray *)getNewImageArray:(NSString *)lastImageName
{
    bool flag=false;
    NSMutableArray *newImageArray=[NSMutableArray array];
    for(int i=0;i<self.waterfall.imagesArr.count;i++)
    {
        NSDictionary *item=[self.waterfall.imagesArr objectAtIndex:i];
        NSString *filename=[item objectForKey:@"文件名"];
        if([lastImageName isEqualToString:filename])
        {
            flag=true;
        }
        if(flag)
        {
            [newImageArray addObject:item];
            if(newImageArray.count>=20)
                break;
        }
    }
    return newImageArray;
}
-(void)cellOnClick:(NSInteger)index
{
    NSMutableArray *imageArray=[NSMutableArray array];
    for(int i=(int)index;i<self.waterfall.imagesArr.count;i++)
    {
        [imageArray addObject:[self.waterfall.imagesArr objectAtIndex:i]];
        if(imageArray.count>=20)
            break;
    }
    DDIAlbumScrollPage *asp=[[DDIAlbumScrollPage alloc]init];
    asp.imageArray=imageArray;
    asp.delegate=self;
    UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController:asp];
    
 
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 100.0, 29.0, 29.0)];
    [backBtn setTitle:@"" forState:UIControlStateNormal];
    [backBtn setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    asp.navigationItem.leftBarButtonItem=backButtonItem;
    [self presentViewController:nav animated:YES completion:nil];
}
-(void)backAction{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
