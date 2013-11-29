//
//  DDIClassSchedule.m
//  TeacherAssistant
//
//  Created by yons on 13-11-13.
//  Copyright (c) 2013年 dandian. All rights reserved.
//

#import "DDIClassSchedule.h"
#import "DDIClassAttend.h"
@interface DDIClassSchedule ()

@end

CGRect orgRectLeftBar;
CGRect orgRectTopBar;
CGRect orgRectMainView;
extern NSMutableDictionary *userInfoDic;
NSArray *scheduleArray;
extern NSMutableArray *colorArray;
NSString *selBanji;

@implementation DDIClassSchedule


- (void)viewDidLoad
{
    [super viewDidLoad];
    //设置背景图
    self.bgImage.image=[UIImage imageNamed:@"ScheduleBg"];
    //设置导航栏
    
    [self.navigationController setNavigationBarHidden:NO];
    UINavigationBar *navBar = self.navigationController.navigationBar;
    [navBar setBackgroundColor:[UIColor blackColor]];
    [navBar setBackgroundImage:[UIImage imageNamed:@"navbar"] forBarMetrics:UIBarMetricsDefault];

    //设置导航栏菜单
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 100.0, 29.0, 29.0)];
    [backBtn setTitle:@"" forState:UIControlStateNormal];
    [backBtn setBackgroundImage:[UIImage imageNamed:@"mainMenu"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(mainMenuAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backBarBtn = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem=backBarBtn;
    
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
 
    for (int i=0;i<[scheduleArray count];i++)
    {
        NSDictionary *classInfo=[scheduleArray objectAtIndex:i];
        [self drawClassRect:classInfo index:i];
        for (id key in classInfo)
        {
            NSLog(@"key: %@ ,value: %@",key,[classInfo objectForKey:key]);
            
        }
    }
    
    
}
-(void) drawClassRect:(NSDictionary *)classInfo index:(NSInteger)index
{
    
    if(self.navigationItem.titleView==nil)
    {
        NSString *WeekNo=[classInfo objectForKey:@"周次"];
        UILabel *titleText = [[UILabel alloc] initWithFrame: CGRectMake(160, 0, 120, 44)];
        titleText.backgroundColor = [UIColor clearColor];
        titleText.textColor=[UIColor whiteColor];
        titleText.textAlignment=NSTextAlignmentCenter;
        [titleText setFont:[UIFont systemFontOfSize:18.0]];
        NSString *titleValue=[NSString stringWithFormat:@"第%@周",WeekNo];
        [titleText setText:titleValue];
        self.navigationItem.titleView=titleText;
    }
    NSString *sectionStr=[classInfo objectForKey:@"节次"];
    NSString *weekDay=[classInfo objectForKey:@"星期"];
    NSString *className=[classInfo objectForKey:@"课程"];
    NSString *classRoom=[classInfo objectForKey:@"教室"];
    NSString *banJi=[classInfo objectForKey:@"班级"];
    NSArray *sectionArray=[sectionStr componentsSeparatedByString:@"-"];
    CGFloat x=([weekDay intValue]-1)*60+1;
    CGFloat y=([[sectionArray objectAtIndex:0] intValue]-1)*45;
    CGFloat height=[[sectionArray objectAtIndex:[sectionArray count]-1] intValue]*45-y;
   
    
    int m=0;
    for(int i=0;i<[className length];i++)
    {
        char c=[className characterAtIndex:i];
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

-(void) mainMenuAction
{
    [self performSegueWithIdentifier:@"gotoMenu" sender:nil];
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
        UITabBarController *destController=segue.destinationViewController;
        DDIClassAttend *dest=[destController.childViewControllers objectAtIndex:0];
        UIButton *btn=(UIButton *)sender;
        NSDictionary *classInfo=[scheduleArray objectAtIndex:btn.tag];
        NSString *banjiName=[classInfo objectForKey:@"班级"];
        NSString *classNo=[classInfo objectForKey:@"编号"];
        dest.banjiName=banjiName;
        dest.classNo=classNo;
        dest.classIndex=[[NSNumber alloc] initWithInt:btn.tag];
        destController.navigationItem.title=banjiName;
        
        UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 100.0, 29.0, 29.0)];
        [backBtn setTitle:@"" forState:UIControlStateNormal];
        [backBtn setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        [backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
        destController.navigationItem.leftBarButtonItem = backButtonItem;
    }

   

}
-(IBAction)backAction{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
