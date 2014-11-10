//
//  DDINotifySetup.m
//  老师助手
//
//  Created by yons on 13-12-27.
//  Copyright (c) 2013年 dandian. All rights reserved.
//

#import "DDINotifySetup.h"

@interface DDINotifySetup ()

@end

@implementation DDINotifySetup

- (void)viewDidLoad
{
    [super viewDidLoad];
    dayArray=[[NSMutableArray alloc]init];
    hourArray=[[NSMutableArray alloc]init];
    minuteArray=[[NSMutableArray alloc]init];
    defaults =[NSUserDefaults standardUserDefaults];
    
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
    
    [dayArray addObject:@"前一天"];
    [dayArray addObject:@"当天"];
    for(int i=0;i<24;i++)
    {
        NSString *sHour;
        if(i<10)
            sHour=[NSString stringWithFormat:@"0%d",i];
        else
            sHour=[NSString stringWithFormat:@"%d",i];
        [hourArray addObject:sHour];
    }
    for(int i=0;i<60;i++)
    {
        NSString *sMinute;
        if(i<10)
            sMinute=[NSString stringWithFormat:@"0%d",i];
        else
            sMinute=[NSString stringWithFormat:@"%d",i];
        [minuteArray addObject:sMinute];
    }
    NSString *ifPopDay=[defaults objectForKey:@"ifPopDay"];
    if(ifPopDay==Nil)
    {
        ifPopDay=@"on";
        [defaults setObject:ifPopDay forKey:@"ifPopDay"];
    }
    if([ifPopDay isEqualToString:@"on"])
        [_ifPopDayTip setOn:YES];
    else
        [_ifPopDayTip setOn:NO];
    NSString *theTime=[defaults objectForKey:@"alertTime"];
    if(!theTime)
    {
        theTime=@"前一天 20:00";
        [defaults setObject:theTime forKey:@"alertTime"];
    }
    [_alertTimeBtn setTitle:theTime forState:UIControlStateNormal];

}

- (void) done{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    [alertController dismissViewControllerAnimated:YES completion:nil];
#else
    [actionSheet dismissWithClickedButtonIndex:0 animated:YES];
#endif
    NSInteger row1 = [pickerView selectedRowInComponent:0];
	NSInteger row2 = [pickerView selectedRowInComponent:1];
    NSInteger row3 = [pickerView selectedRowInComponent:2];
	NSString *selected1 = [dayArray objectAtIndex:row1];
	NSString *selected2 = [hourArray objectAtIndex:row2];
    NSString *selected3 = [minuteArray objectAtIndex:row3];
    
    NSString *theTime=[NSString stringWithFormat:@"%@ %@:%@",selected1,selected2,selected3];
    [_alertTimeBtn setTitle:theTime forState:UIControlStateNormal];
    
    [defaults setObject:theTime forKey:@"alertTime"];
    
    DDIClassSchedule *cs=[[DDIClassSchedule alloc]init];
    [cs reSetLocalNotification];
}

- (void) docancel{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    [alertController dismissViewControllerAnimated:YES completion:nil];
#else
    [actionSheet dismissWithClickedButtonIndex:1 animated:YES];
#endif

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark 实现协议UIPickerViewDataSource方法
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 3;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component {
	if (component == 0)
		return dayArray.count;
	else if(component==1)
        return hourArray.count;
	else
        return minuteArray.count;
	
}
#pragma mark 实现协议UIPickerViewDelegate方法
-(NSString *)pickerView:(UIPickerView *)pickerView
			titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	if (component == 0)
		return [dayArray objectAtIndex:row];
	else if(component==1)
		return [[hourArray objectAtIndex:row] stringByAppendingString:@" 点"];
    else
		return [[minuteArray objectAtIndex:row] stringByAppendingString:@" 分"];
}


- (IBAction)openAcSheet:(id)sender {
    NSArray *strArray=[_alertTimeBtn.titleLabel.text componentsSeparatedByString:@" "];
    NSString *day=[strArray objectAtIndex:0];
    NSString *str=[strArray objectAtIndex:1];
    strArray=[str componentsSeparatedByString:@":"];
    NSString *hour=[strArray objectAtIndex:0];
    NSString *minute=[strArray objectAtIndex:1];
    NSInteger row1=[dayArray indexOfObject:day];
    NSInteger row2=[hourArray indexOfObject:hour];
    NSInteger row3=[minuteArray indexOfObject:minute];
    [pickerView selectRow:row1 inComponent:0 animated:NO];
    [pickerView selectRow:row2 inComponent:1 animated:NO];
    [pickerView selectRow:row3 inComponent:2 animated:NO];

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    [self presentViewController:alertController animated:YES completion:nil];
#else
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
#endif
}

- (IBAction)ifPopDayClick:(id)sender {
    if(_ifPopDayTip.on)
    {
        [defaults setObject:@"on" forKey:@"ifPopDay"];
    }
    else
        [defaults setObject:@"off" forKey:@"ifPopDay"];
}

@end
