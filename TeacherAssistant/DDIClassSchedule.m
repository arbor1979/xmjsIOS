//
//  DDIClassSchedule.m
//  TeacherAssistant
//
//  Created by yons on 13-11-13.
//  Copyright (c) 2013年 dandian. All rights reserved.
//

#import "DDIClassSchedule.h"
#import "DDIClassAttend.h"
#import "DDIKeJianDownload.h"
#import "DDIKeTangExam.h"
#import "DDIKeTangPingJia.h"

@interface DDIClassSchedule ()

@end

CGRect orgRectLeftBar;
CGRect orgRectTopBar;
CGRect orgRectMainView;
extern NSMutableDictionary *userInfoDic;
extern Boolean kIOS7;
extern NSMutableArray *colorArray;
extern int kUserType;
extern NSString *kServiceURL;
extern NSString *kUserIndentify;
@implementation DDIClassSchedule


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //设置背景图
    self.bgImage.image=[UIImage imageNamed:@"ScheduleBg"];

    
    
    //拖拽
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                        action:@selector(handlePanGestures:)];
    //无论最大还是最小都只允许一个手指
    self.panGestureRecognizer.minimumNumberOfTouches = 1;
    self.panGestureRecognizer.maximumNumberOfTouches = 1;
    [self.mainView addGestureRecognizer:self.panGestureRecognizer];
    
    //初始位置大小
    orgRectTopBar=self.topBarView.frame;
    orgRectLeftBar=self.leftBarView.frame;
    orgRectMainView=self.mainView.frame;
    
    //当前星期
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *now=[NSDate date];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit |
    NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;

    comps = [calendar components:unitFlags fromDate:now];
    NSInteger week = [comps weekday];
    [self.topBarView viewWithTag:week].backgroundColor=[UIColor colorWithRed:7/255.0f green:92/255.0f blue:27/255.0f alpha:1];
    
    
    //获取课表
    scheduleArray=[userInfoDic objectForKey:@"教师上课记录"];
    NSString *curWeek=[userInfoDic objectForKey:@"当前周次"];
    _WeekNo=[NSString stringWithFormat:@"第%@周(本周)",curWeek];
    weekSelBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    NSString *selWeek=@"";
    if([[userInfoDic objectForKey:@"选择周次"] isEqual:[userInfoDic objectForKey:@"当前周次"]])
        selWeek=_WeekNo;
    else
        selWeek=[NSString stringWithFormat:@"第%@周",[userInfoDic objectForKey:@"选择周次"]];
    [weekSelBtn addTarget:self action:@selector(popWeekList) forControlEvents:UIControlEventTouchUpInside];
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[selWeek stringByAppendingString:@"▼"]];
    [str addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:16] range:NSMakeRange(0, str.length-1)];
    [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:8] range:NSMakeRange(str.length-1,1)];
    
    if(kIOS7)
    {
        [str addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, str.length)];
        
    }
    else
    {
        [str addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, str.length)];
    }
    [weekSelBtn setAttributedTitle:str forState:UIControlStateNormal];
    //self.parentViewController.navigationItem.title=_WeekNo;
    
    
    for (int i=0;i<[scheduleArray count];i++)
    {
        NSDictionary *classInfo=[scheduleArray objectAtIndex:i];
        [self drawClassRect:classInfo index:i];
        
    }
    [self reSetLocalNotification];
    
    
    
    actionSheet = [[UIActionSheet alloc] initWithTitle:@"\n\n\n\n\n\n\n\n\n\n" delegate:nil  cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil, nil];
    actionSheet.backgroundColor=[UIColor whiteColor];
    [actionSheet setBounds:CGRectMake(0, 0, 100, 150)];
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
    
    
    [actionSheet addSubview:navBar];
    [actionSheet addSubview:pickerView];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    
    
    alertController = [UIAlertController alertControllerWithTitle:@"\n\n\n\n\n\n\n\n\n\n" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    pickerView.frame=CGRectMake(0, 40, alertController.view.bounds.size.width-16, 120);
    navBar.frame=CGRectMake(0, 0, alertController.view.bounds.size.width-16, 40);
    
    [alertController.view addSubview:navBar];
    [alertController.view addSubview:pickerView];
    
#endif
    
    weekArray=[NSMutableArray array];
    NSNumber *maxWeek=[userInfoDic objectForKey:@"最大周次"];
    if(curWeek.intValue>maxWeek.intValue)
        maxWeek=[NSNumber numberWithInt:curWeek.intValue+1];
  
    for(int i=1;i<=maxWeek.intValue;i++)
    {
        NSString *text=[NSString stringWithFormat:@"第%d周",i];
        NSNumber *n=[NSNumber numberWithInt:i];
        if(curWeek.intValue==n.intValue)
            text=[text stringByAppendingString:@"(本周)"];
        [weekArray addObject:text];
    }
    requestArray=[NSMutableArray array];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(ifChangeWeekToCurweek)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    if(scheduleArray.count==0)
    {
        OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"本周没有课程"];
        [tipView showInView:self.view];
        return;
    }
}
-(void)ifChangeWeekToCurweek
{
    if(![[userInfoDic objectForKey:@"选择周次"] isEqual:[userInfoDic objectForKey:@"当前周次"]])
    {
        NSString *selected1 = [NSString stringWithFormat:@"第%@周(本周)",[userInfoDic objectForKey:@"当前周次"]];
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[selected1 stringByAppendingString:@"▼"]];
        [str addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:16] range:NSMakeRange(0, str.length-1)];
        [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:8] range:NSMakeRange(str.length-1,1)];
        [weekSelBtn setAttributedTitle:str forState:UIControlStateNormal];
        [weekSelBtn sizeToFit];
        [self postUserInfo:[userInfoDic objectForKey:@"当前周次"]];
    }
}
- (void) done{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    [alertController dismissViewControllerAnimated:YES completion:nil];
#else
    [actionSheet dismissWithClickedButtonIndex:0 animated:YES];
#endif
    
    
    NSInteger row1 = [pickerView selectedRowInComponent:0];
	NSString *selected1 = [weekArray objectAtIndex:row1];
    if(selected1 )
    {
        NSRange range = [selected1 rangeOfString:@"(本周)"];
        if (range.length == 0)
            selected1=[selected1 stringByAppendingString:@"(非本周)"];
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[selected1 stringByAppendingString:@"▼"]];
        [str addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:16] range:NSMakeRange(0, str.length-1)];
        [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:8] range:NSMakeRange(str.length-1,1)];
        [weekSelBtn setAttributedTitle:str forState:UIControlStateNormal];
        [weekSelBtn sizeToFit];
        [self postUserInfo:[NSString stringWithFormat:@"%d",(int)row1+1]];
    }
    
}
-(void) postUserInfo:(NSString *)selWeek
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@appserver.php?action=initinfo&zip=1&WEEK=%@",kServiceURL,selWeek]];
	NSString *postStr = [NSString stringWithFormat:@"{\"用户较验码\":\"%@\"}",kUserIndentify];
    postStr =[GTMBase64 base64StringBystring:postStr];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];

    [request setPostValue:postStr forKey:@"DATA"];
    [request setDelegate:self];
    request.username=@"初始化数据";
    [requestArray addObject:request];
    [request startAsynchronous];
    alertTip = [[OLGhostAlertView alloc] initWithTitle:@"正在获取所选周课表" message:nil timeout:0 dismissible:NO];
    [alertTip showInView:self.view];
    
}
- (void)requestFinished:(ASIHTTPRequest *)request
{
    if(alertTip)
        [alertTip removeFromSuperview];
    if([request.username isEqualToString:@"初始化数据"])
    {
        NSString* dataStr;
        NSData *upzipData;
        @try
        {
            dataStr = [[NSString alloc] initWithData:request.responseData encoding:NSUTF8StringEncoding];
            NSData *_decodedData   = [[NSData alloc] initWithBase64Encoding:dataStr];
            upzipData = [LFCGzipUtillity uncompressZippedData:_decodedData];
            dataStr = [[NSString alloc] initWithData:upzipData encoding:NSUTF8StringEncoding];
        }
        @catch (NSException *e) {
            NSLog(@"Exception: %@", e);
        }
        if(dataStr==nil || dataStr.length==0)
        {
            OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"获取周课表失败"];
            [tipView showInView:self.view];
            
        }
        else
        {
            NSMutableDictionary* dict = [NSJSONSerialization JSONObjectWithData:upzipData options:NSJSONReadingAllowFragments error:nil];
            userInfoDic=[dict mutableCopy];
            
            for(UIButton *subview in self.mainView.subviews)
            {
                if([subview isKindOfClass:[UIButton class]])
                   [subview removeFromSuperview];
            }
            scheduleArray=[userInfoDic objectForKey:@"教师上课记录"];
            for (int i=0;i<[scheduleArray count];i++)
            {
                NSDictionary *classInfo=[scheduleArray objectAtIndex:i];
                [self drawClassRect:classInfo index:i];
                
            }
        }
        
    }
}
- (void)requestFailed:(ASIHTTPRequest *)request
{
    if(alertTip)
        [alertTip removeFromSuperview];
       NSError *error = [request error];
    NSLog(@"请求失败:%@",[error localizedDescription]);
    OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"操作失败" message:[error localizedDescription]];
    [tipView show];
    request=nil;
}
- (void) docancel{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    [alertController dismissViewControllerAnimated:YES completion:nil];
#else
    [actionSheet dismissWithClickedButtonIndex:1 animated:YES];
#endif
    
}
-(void)popWeekList
{
    NSString *str=[weekSelBtn.titleLabel.attributedText string];
    NSString *title=[str substringToIndex:str.length-1];
    title=[title stringByReplacingOccurrencesOfString:@"(非本周)" withString:@""];
    NSInteger row1=[weekArray indexOfObject:title];
    if(row1>=0 && row1<50)
    {
        [pickerView selectRow:row1 inComponent:0 animated:NO];
        
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
        [self presentViewController:alertController animated:YES completion:nil];
#else
        [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
#endif
    }
}
#pragma mark 实现协议UIPickerViewDataSource方法
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component {
        return weekArray.count;
}
#pragma mark 实现协议UIPickerViewDelegate方法
-(NSString *)pickerView:(UIPickerView *)pickerView
			titleForRow:(NSInteger)row forComponent:(NSInteger)component {
		return [weekArray objectAtIndex:row];
}
-(void)reSetLocalNotification
{
    NSMutableArray *allWeekDayClass=[[NSMutableArray alloc]init];
    for(int i=0;i<7;i++)
    {
        NSMutableArray *item=[[NSMutableArray alloc]init];
        [allWeekDayClass addObject:item];
    }
    scheduleArray=[userInfoDic objectForKey:@"教师上课记录"];
    for (int i=0;i<[scheduleArray count];i++)
    {
        NSDictionary *classInfo=[scheduleArray objectAtIndex:i];
        NSString *weekDay=[classInfo objectForKey:@"星期"];
        NSString *banJi;
        if(kUserType==1)
            banJi=[classInfo objectForKey:@"班级"];
        else
            
            banJi=[classInfo objectForKey:@"课程"];
        NSMutableArray *item=[allWeekDayClass objectAtIndex:weekDay.intValue-1];
        if(![item containsObject:banJi])
        {
            [item addObject:banJi];
        }
        [allWeekDayClass replaceObjectAtIndex:weekDay.intValue-1 withObject:item];
    }
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    NSString *ifPopDay=[defaults objectForKey:@"ifPopDay"];
    if(![ifPopDay isEqualToString:@"off"])
    {
        NSString *theTime=[defaults objectForKey:@"alertTime"];
        if(!theTime)
            theTime=@"前一天 20:00";
        NSArray *strArray=[theTime componentsSeparatedByString:@" "];
        NSString *day=[strArray objectAtIndex:0];
        NSString *str=[strArray objectAtIndex:1];
        strArray=[str componentsSeparatedByString:@":"];
        NSString *hour=[strArray objectAtIndex:0];
        NSString *minute=[strArray objectAtIndex:1];
        
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDate *now=[NSDate new];
        [calendar setTimeZone:[NSTimeZone localTimeZone]];
        NSDateComponents *weekdayComponents = [calendar components:(NSWeekdayCalendarUnit) fromDate:now];
        NSInteger todayWeekDay=weekdayComponents.weekday-1;
        if(todayWeekDay==0)
            todayWeekDay=7;
        NSDate *monday=[NSDate dateWithTimeInterval:-(todayWeekDay-1)*24*60*60 sinceDate:now];
        NSString *strMonday=[CommonFunc stringFromDate:monday];
        NSArray *dateStrArray=[strMonday componentsSeparatedByString:@" "];
        strMonday=[NSString stringWithFormat:@"%@ %@:%@:00",[dateStrArray objectAtIndex:0],hour,minute];
        monday=[CommonFunc dateFromString:strMonday];
        NSString *dayName=@"今天";
        if([day isEqualToString:@"前一天"])
            dayName=@"明天";
        for (int i=0; i<allWeekDayClass.count; i++) {
            NSMutableArray *item=[allWeekDayClass objectAtIndex:i];
            NSString *body=[NSString stringWithFormat:@"%@没有课哦",dayName];
            if(item.count>0)
            {
                if(kUserType==1)
                    body=[NSString stringWithFormat:@"%@有%d个班的课要上:",dayName,(int)item.count];
                else
                    body=[NSString stringWithFormat:@"%@有%d门课要上:",dayName,(int)item.count];
                for (int j=0; j<item.count; j++) {
                    body=[body stringByAppendingString:@"\n"];
                    body=[body stringByAppendingString:[item objectAtIndex:j]];
                }
            }
            NSDate *dates;
            if([day isEqualToString:@"当天"])
            {
                dates=[NSDate dateWithTimeInterval:i*24*60*60 sinceDate:monday];
            }
            else
                dates=[NSDate dateWithTimeInterval:(i-1)*24*60*60 sinceDate:monday];
            
            UILocalNotification *localNoti = [[UILocalNotification alloc]init];
            localNoti.alertBody = body;
            localNoti.fireDate=dates;
            localNoti.soundName=UILocalNotificationDefaultSoundName;
            localNoti.repeatInterval=NSWeekCalendarUnit;
            [[UIApplication sharedApplication] scheduleLocalNotification:localNoti];
            //NSLog(@"%@:%@",[CommonFunc stringFromDate:dates],body);
        }
    }
}


-(void)viewDidAppear:(BOOL)animated
{
    self.parentViewController.navigationItem.title=nil;
    self.parentViewController.navigationItem.titleView=weekSelBtn;
    
}
-(void)viewDidDisappear:(BOOL)animated
{
    self.parentViewController.navigationItem.titleView=Nil;
}
-(void) drawClassRect:(NSDictionary *)classInfo index:(NSInteger)index
{
    
    
    NSString *sectionStr=[classInfo objectForKey:@"节次"];
    NSString *weekDay=[classInfo objectForKey:@"星期"];
    NSString *className=[classInfo objectForKey:@"课程"];
    NSString *classRoom=[classInfo objectForKey:@"教室"];
    NSString *banJi;
    if(kUserType==1)
        banJi=[classInfo objectForKey:@"班级"];
    else
        banJi=[classInfo objectForKey:@"教师姓名"];
    NSArray *sectionArray=[sectionStr componentsSeparatedByString:@"-"];
    CGFloat x=([weekDay intValue]-1)*60+1;
    CGFloat y=([[sectionArray objectAtIndex:0] intValue]-1)*45;
    CGFloat height=[[sectionArray objectAtIndex:[sectionArray count]-1] intValue]*45-y;
   
    
    int m=0;
    for(int i=0;i<[banJi length];i++)
    {
        char c=[banJi characterAtIndex:i];
        m=m+(Byte)c;
    }
    UIColor *randColor=[colorArray objectAtIndex:m%colorArray.count];
    /*
    UIEdgeInsets insets=UIEdgeInsetsMake(5, 5, 5, 5);
    DDIInsetsLabel *classText = [[DDIInsetsLabel alloc] initWithFrame: CGRectMake(x, y, 60-1, height) andInsets:insets];
    classText.backgroundColor = randColor;
    classText.textColor=[UIColor blackColor];
    classText.lineBreakMode=NSLineBreakByCharWrapping;
    classText.alpha=1;
    classText.numberOfLines = 0;
    classText.tag=[classNo intValue];
    [classText setFont:[UIFont systemFontOfSize:10.0]];
    NSString *titleValue=[NSString stringWithFormat:@"%@(%@)",className,classRoom];
    [classText setText:titleValue];
    [self.mainView addSubview:classText];
     
    */
    UIButton *innerBtn=[[UIButton alloc] initWithFrame:CGRectMake(x, y, 60-1, height)];
    innerBtn.backgroundColor=randColor;
    innerBtn.titleEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    NSString *titleValue=[NSString stringWithFormat:@"%@(%@)%@",className,classRoom,banJi];
    [innerBtn setTitle:titleValue forState:UIControlStateNormal];
    [innerBtn setTag:index];
    [innerBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [innerBtn.titleLabel setFont:[UIFont systemFontOfSize:10.0]];
    innerBtn.titleLabel.numberOfLines=0;
    innerBtn.titleLabel.lineBreakMode=NSLineBreakByCharWrapping;
    
    innerBtn.alpha=1;
    [innerBtn addTarget:self action:@selector(openAttendView:) forControlEvents:UIControlEventTouchUpInside];
    [self.mainView addSubview:innerBtn];

}
-(void)openAttendView:(UIButton *)sender
{
    [self performSegueWithIdentifier:@"classAttend" sender:sender];
}
// 拖拽手势
- (void)handlePanGestures:(UIPanGestureRecognizer *)gestureRecognizer
{
    UIView *view = [gestureRecognizer view]; // 这个view是手势所属的view，也就是增加手势的那个view
    
    switch (gestureRecognizer.state) {
        
        case UIGestureRecognizerStateChanged:{
           
            CGRect screen = [ UIScreen mainScreen ].bounds;
            CGFloat minX=screen.size.width-self.mainView.frame.size.width;
            CGFloat maxX=20;
            CGFloat minY=self.view.frame.size.height-self.mainView.frame.size.height;
            CGFloat maxY=21;
            
            /*
             让view跟着手指移动
             
             1.获取每次系统捕获到的手指移动的偏移量translation
             2.根据偏移量translation算出当前view应该出现的位置
             3.设置view的新frame
             4.将translation重置为0（十分重要。否则translation每次都会叠加，很快你的view就会移除屏幕！）
             */
            
            CGPoint translation = [gestureRecognizer translationInView:self.view];
            if(gestureRecognizer.view.frame.origin.x + translation.x>maxX)
                translation.x=maxX-gestureRecognizer.view.frame.origin.x;
            if(gestureRecognizer.view.frame.origin.x + translation.x<minX)
                translation.x=minX-gestureRecognizer.view.frame.origin.x;
            if(gestureRecognizer.view.frame.origin.y + translation.y>maxY)
                translation.y=maxY-gestureRecognizer.view.frame.origin.y;
            if(gestureRecognizer.view.frame.origin.y + translation.y<minY)
                translation.y=minY-gestureRecognizer.view.frame.origin.y;
            view.center = CGPointMake(gestureRecognizer.view.center.x + translation.x, gestureRecognizer.view.center.y + translation.y);
            [gestureRecognizer setTranslation:CGPointMake(0, 0) inView:self.view];//  注意一旦你完成上述的移动，将translation重置为0十分重要。否则translation每次都会叠加，很快你的view就会移除屏幕！
            
            self.leftBarView.frame=CGRectMake(orgRectLeftBar.origin.x,view.frame.origin.y,orgRectLeftBar.size.width,orgRectLeftBar.size.height);
            self.topBarView.frame=CGRectMake(view.frame.origin.x,orgRectTopBar.origin.y,orgRectTopBar.size.width,orgRectTopBar.size.height);
            break;
        }
        default:{
            break;
        }
    }
}

-(void) moveView:(UIView *)view direct:(UISwipeGestureRecognizerDirection)direction rect:(CGRect) orgRect
{
    
    CGRect screen = [ UIScreen mainScreen ].bounds;
    [UIView animateWithDuration:0.5 animations:^(void){
       
        if(direction==UISwipeGestureRecognizerDirectionRight)
            [view setFrame:CGRectMake(orgRect.origin.x, view.frame.origin.y, view.frame.size.width, view.frame.size.height)];
        else if(direction==UISwipeGestureRecognizerDirectionLeft)
            [view setFrame:CGRectMake(screen.size.width-view.frame.size.width, view.frame.origin.y, view.frame.size.width, view.frame.size.height)];
        else if(direction==UISwipeGestureRecognizerDirectionUp)
            [view setFrame:CGRectMake(view.frame.origin.x, self.view.frame.size.height-view.frame.size.height, view.frame.size.width, view.frame.size.height)];
        else if(direction==UISwipeGestureRecognizerDirectionDown)
            [view setFrame:CGRectMake(view.frame.origin.x, orgRect.origin.y, view.frame.size.width, view.frame.size.height)];
        NSLog(@"self:%f Y:%f",self.view.frame.size.height,view.frame.size.height);
    }completion:^(BOOL finished){
       
    }];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"classAttend"])
    {
        UINavigationController *NavController=segue.destinationViewController;
        
        UITabBarController *destController=[NavController.childViewControllers objectAtIndex:0];
        
        DDIClassAttend *dest=[destController.childViewControllers objectAtIndex:0];
        UIButton *btn=(UIButton *)sender;
        NSDictionary *classInfo=[scheduleArray objectAtIndex:btn.tag];
        NSString *banjiName=[classInfo objectForKey:@"班级"];
        NSString *classNo=[classInfo objectForKey:@"编号"];
        dest.banjiName=banjiName;
        dest.classNo=classNo;
        dest.classIndex=[[NSNumber alloc] initWithInt:btn.tag];
        
        DDICourseInfo *dest1=[destController.childViewControllers objectAtIndex:1];
        dest1.className=[classInfo objectForKey:@"课程"];
        dest1.teacherUserName=[classInfo objectForKey:@"教师用户名"];
        dest1.classNo=classNo;
        dest1.classIndex=[[NSNumber alloc] initWithInt:btn.tag];
        
        DDIKeJianDownload *dest2=[destController.childViewControllers objectAtIndex:2];
        dest2.className=[classInfo objectForKey:@"课程"];
        dest2.teacherUserName=[classInfo objectForKey:@"教师用户名"];
        dest2.classNo=classNo;
        
        DDIKeTangExam *dest3=[destController.childViewControllers objectAtIndex:3];
        dest3.className=[classInfo objectForKey:@"课程"];
        dest3.classNo=classNo;
        dest3.classIndex=btn.tag;
        dest3.banjiName=banjiName;
        
        DDIKeTangPingJia *dest4=[destController.childViewControllers objectAtIndex:4];
        dest4.banjiName=banjiName;
        dest4.classNo=classNo;
        dest4.classIndex=[[NSNumber alloc] initWithInt:btn.tag];
        dest4.className=[classInfo objectForKey:@"课程"];
        dest4.teacherUserName=[classInfo objectForKey:@"教师用户名"];
        if(kUserType==1)
        {
            [dest1 removeFromParentViewController];
        }
        else
        {
            [dest removeFromParentViewController];
        }
        
        UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 100.0, 29.0, 29.0)];
        [backBtn setTitle:@"" forState:UIControlStateNormal];
        [backBtn setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        [backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
        destController.navigationItem.leftBarButtonItem = backButtonItem;
    }

}
-(void)backAction{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc
{
   
    for(ASIHTTPRequest *req in requestArray)
    {
        [req setDownloadProgressDelegate:nil];
        [req clearDelegatesAndCancel];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
