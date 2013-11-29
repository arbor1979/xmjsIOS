//
//  DDIClassAttend.m
//  老师助手
//
//  Created by yons on 13-11-20.
//  Copyright (c) 2013年 dandian. All rights reserved.
//

#import "DDIClassAttend.h"
#import "ChineseString.h"
#import "pinyin.h"
#import "GTMBase64.h"

@implementation DDIClassAttend
extern NSMutableDictionary *userInfoDic;
extern Boolean kIOS7;
extern NSString *kServiceURL;
extern NSString *kUserIndentify;

NSMutableDictionary *studentDic;  //本班学生信息
NSArray *sectionArray;     //姓名第一个字母
NSDictionary *kaoqinData; //每个学生的出勤率
NSMutableDictionary *allqueqinDic; //所有学生缺勤记录
NSMutableDictionary *stuKaoQinDic; //本班学生本节课缺勤记录

-(void) viewDidLoad
{

    [super viewDidLoad];
    //设置标签栏背景
    id appearance = [UITabBar appearance];
    UIImage *tabBarBackGroungImg =[UIImage imageNamed:@"navBottom"];
    [appearance setBackgroundImage:tabBarBackGroungImg];
    
    UIBarButtonItem *rightBtn= [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleBordered target:self action:@selector(saveAttend)];
    if (kIOS7) {
        [rightBtn setTintColor:[UIColor whiteColor]];
    }
    self.parentViewController.navigationItem.rightBarButtonItem=nil;
    self.parentViewController.navigationItem.rightBarButtonItem =rightBtn;
    
    //本班学生数组
    NSDictionary *tmpDic=[userInfoDic objectForKey:self.banjiName];
    NSArray *tmpArray=nil;
    if ([tmpDic isKindOfClass:[NSArray class]]) {
        tmpArray=[[NSArray alloc] initWithArray:(NSArray *)tmpDic];
    }
    else
        tmpArray= [[NSArray alloc] initWithArray:tmpDic.allValues];
   
    //所有缺勤学生
    allqueqinDic=[[NSMutableDictionary alloc] initWithDictionary:[userInfoDic objectForKey:@"缺勤情况明细"]];
    //本班缺勤学生
    stuKaoQinDic=[[NSMutableDictionary alloc] initWithDictionary:[allqueqinDic objectForKey:self.classNo]];

   
    studentDic=[[NSMutableDictionary alloc] init];
    for(int i=0;i<[tmpArray count];i++)
    {
        NSMutableDictionary *student=[[NSMutableDictionary alloc] initWithDictionary:[tmpArray objectAtIndex:i]];
        NSString *studentName=[student objectForKey:@"姓名"];
        NSString *xuehao=[student objectForKey:@"学号"];
        NSString *pinYinResult=[NSString string];
        for(int j=0;j<studentName.length;j++){
            NSString *singlePinyinLetter=[[NSString stringWithFormat:@"%c",pinyinFirstLetter([studentName characterAtIndex:j])]uppercaseString];
            
            pinYinResult=[pinYinResult stringByAppendingString:singlePinyinLetter];
        }
        [student setObject:pinYinResult forKey:@"拼音"];
        if([stuKaoQinDic objectForKey:xuehao]!=nil)
            [student setObject:[stuKaoQinDic objectForKey:xuehao] forKey:@"考勤"];
        else
            [student setObject:[[NSNumber alloc] initWithInt:1] forKey:@"考勤"];
        
        NSString *firstLetter=[pinYinResult substringToIndex:1];
        NSMutableArray *groupArray=[studentDic objectForKey:firstLetter];
        if(groupArray==nil)
            groupArray=[[NSMutableArray alloc] init];
        [groupArray addObject:student];
        [studentDic setObject:groupArray forKey:firstLetter];
    }
    NSArray* tempList  = [studentDic allKeys];
    sectionArray = [tempList sortedArrayUsingSelector:@selector(compare:)];
    
    self.navigationItem.title=self.banjiName;
    NSDictionary *kaoqinTongji=[userInfoDic objectForKey:@"学生考勤统计"];
    kaoqinData=[kaoqinTongji objectForKey:@"出勤率"];
    

    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
#pragma tableview datasoucre
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return [sectionArray count];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *groupName = [sectionArray objectAtIndex:section];
    NSArray *listTeams = [studentDic objectForKey:groupName];
	return [listTeams count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"attendCell" forIndexPath:indexPath];

    NSUInteger section = [indexPath section];
	NSUInteger row = [indexPath row];
    NSString *groupName = [sectionArray objectAtIndex:section];

	NSMutableArray *listTeams = [studentDic objectForKey:groupName];
    
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"姓名" ascending:YES]];
    [listTeams sortUsingDescriptors:sortDescriptors];
    
    NSDictionary *student = [listTeams objectAtIndex:row];

    cell.textLabel.text=[student objectForKey:@"姓名"];
    NSString *xuehao=[student objectForKey:@"学号"];
    NSString *xingbie=[student objectForKey:@"性别"];
    NSNumber *kaoqin=[stuKaoQinDic objectForKey:xuehao];
    int tag=kaoqin.intValue;
    if(tag>1)
    {
        UIButton *btn1=(UIButton *)[cell viewWithTag:1];
        [btn1 setImage:[UIImage imageNamed:@"class_call_attend_nor"] forState:UIControlStateNormal];
        UIButton *btn=(UIButton *)[cell viewWithTag:tag];
        NSString *imagename=nil;
        if(tag==2)
            imagename=@"class_call_late_sel";
        else if(tag==3)
            imagename=@"class_call_leave_sel";
        else if(tag==4)
            imagename=@"class_call_absence_sel";
        [btn setImage:[UIImage imageNamed:imagename] forState:UIControlStateNormal];
    }
    if([xingbie isEqualToString:@"女"])
        cell.imageView.image=[UIImage imageNamed:@"defaultWoman"];
    cell.detailTextLabel.text=[kaoqinData objectForKey:xuehao];
    cell.tag=[xuehao intValue];
    return cell;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	NSString *groupName = [sectionArray objectAtIndex:section];
	return groupName;
}
-(NSArray *) sectionIndexTitlesForTableView: (UITableView *) tableView
{
    return sectionArray;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}

- (IBAction)dingMingClick:(id)sender {
    
    UIView *parent=[(UIButton *)sender superview];
    NSArray *controls=[parent subviews];
    UITableViewCell *cell=(UITableViewCell *)[[parent superview] superview];
    NSIndexPath * indexPath=[self.tableView indexPathForCell:cell];
    NSUInteger section = [indexPath section];
	NSUInteger row = [indexPath row];
    NSString *groupName = [sectionArray objectAtIndex:section];
	NSMutableArray *listTeams = [studentDic objectForKey:groupName];
    NSMutableDictionary *student = [listTeams objectAtIndex:row];
    
    for(int i=0;i<controls.count;i++)
    {
        UIControl *ctl=[controls objectAtIndex:i];
        UIButton *btn=nil;
        if([ctl isKindOfClass:[UIButton class]])
            btn=(UIButton *)ctl;
        else
            continue;
        if(btn==sender)
        {
            if(btn.tag==1)
                [btn setImage:[UIImage imageNamed:@"class_call_attend_sel"] forState:UIControlStateNormal];
            else if(btn.tag==2)
                [btn setImage:[UIImage imageNamed:@"class_call_late_sel"] forState:UIControlStateNormal];
            else if(btn.tag==3)
                [btn setImage:[UIImage imageNamed:@"class_call_leave_sel"] forState:UIControlStateNormal];
            else if(btn.tag==4)
                [btn setImage:[UIImage imageNamed:@"class_call_absence_sel"] forState:UIControlStateNormal];
            NSNumber *tag=[[NSNumber alloc] initWithInt:btn.tag];
            [student setObject:tag forKey:@"考勤"];
        }
        else
        {
            if(btn.tag==1)
               [btn setImage:[UIImage imageNamed:@"class_call_attend_nor"] forState:UIControlStateNormal];
            else if(btn.tag==2)
               [btn setImage:[UIImage imageNamed:@"class_call_late_nor"] forState:UIControlStateNormal];
            else if(btn.tag==3)
                [btn setImage:[UIImage imageNamed:@"class_call_leave_nor"] forState:UIControlStateNormal];
            else if(btn.tag==4)
                [btn setImage:[UIImage imageNamed:@"class_call_absence_nor"] forState:UIControlStateNormal];
        }
    }
}

-(void) saveAttend
{
    NSMutableArray *kaoQinArray=[[NSMutableArray alloc] init];
    int iChuqin=0;
    for(id key in studentDic)
    {
        NSArray *studArray=[studentDic objectForKey:key];
        for(int i=0;i<studArray.count;i++)
        {
            NSDictionary *student=[studArray objectAtIndex:i];
            [kaoQinArray addObject:student];
            NSNumber *chuqin=[student objectForKey:@"考勤"];
            if([chuqin intValue]==1)
                iChuqin++;
        }
    }
    
    NSURL *url = [NSURL URLWithString:[[kServiceURL stringByAppendingString:@"?action=changekaoqininfo"] URLEncodedString]];
    
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init];
    [dic setObject:kUserIndentify forKey:@"用户较验码"];
    [dic setObject:self.classNo forKey:@"编号"];
    [dic setObject:[[NSNumber alloc] initWithInt:kaoQinArray.count] forKey:@"班级人数"];
    [dic setObject:[[NSNumber alloc] initWithInt:iChuqin] forKey:@"实到人数"];
    /*
    NSDateFormatter *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString * dateStr=[dateformatter stringFromDate:[NSDate date]];
    [dic setObject:dateStr forKey:@"填写时间"];
     */
    [stuKaoQinDic removeAllObjects];
 
    for(id key in studentDic)
    {
        NSArray *stuArray=[studentDic objectForKey:key];
        for(int i=0;i<stuArray.count;i++)
        {
            NSDictionary *student=[stuArray objectAtIndex:i];
            NSNumber *j=[student objectForKey:@"考勤"];
            if(j.intValue>1)
            {
                NSString *xuehao=[student objectForKey:@"学号"];
                [stuKaoQinDic setObject:j forKey:xuehao];
            }
            
        }
    }
    [allqueqinDic setObject:stuKaoQinDic forKey:self.classNo];
    [userInfoDic setObject:allqueqinDic forKey:@"缺勤情况明细"];
    
    NSError *error;
    NSData *kaoqinData=[NSJSONSerialization dataWithJSONObject:stuKaoQinDic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *kaoqinStr = [[NSString alloc] initWithData:kaoqinData encoding:NSUTF8StringEncoding];
    [dic setObject:kaoqinStr forKey:@"缺勤情况登记JSON"];
    NSData *postData=[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
    
 
    //NSString *postStr = [NSString stringWithFormat:@"{\"用户较验码\":\"%@\",\"编号\":\"%@\",\"班级人数\":\"%d\",\"实到人数\":\"%d\"}",kUserIndentify,self.classNo,kaoQinArray.count,iChuqin];
    
    postStr=[GTMBase64 base64StringBystring:postStr];
    postStr=[NSString stringWithFormat:@"DATA=%@",postStr];
    postData = [postStr dataUsingEncoding:NSUTF8StringEncoding];
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:postData];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURLConnection *connection = [[NSURLConnection alloc]
                                   initWithRequest:request delegate:self];
	
    if (connection) {
        _datas = [NSMutableData new];
    }
    
}

#pragma mark- NSURLConnection 回调方法
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_datas appendData:data];
}


-(void) connection:(NSURLConnection *)connection didFailWithError: (NSError *)error {
    
    NSLog(@"%@",[error localizedDescription]);
}

- (void) connectionDidFinishLoading: (NSURLConnection*) connection {
    NSLog(@"请求完成...");
    NSString* dataStr = [[NSString alloc] initWithData:_datas encoding:NSUTF8StringEncoding];
    dataStr=[GTMBase64 stringByBase64String:dataStr];
    NSData *data = [dataStr dataUsingEncoding: NSUTF8StringEncoding];
    NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    
    
    NSString *result=[dict objectForKey:@"结果"];
    NSRange range=[result rangeOfString:@"成功"];
    NSLog(@"%@",result);
    if(range.location!= NSNotFound)
    {
        [self.parentViewController.navigationItem.rightBarButtonItem setTitle:@"已保存"];
    }
    else
    {
         NSLog(@"失败，原因：%@",dict);
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}
@end
