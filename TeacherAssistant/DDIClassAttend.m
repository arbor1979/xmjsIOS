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
#import "DDIStudentInfo.h"

@implementation DDIClassAttend
extern NSMutableDictionary *userInfoDic;
extern Boolean kIOS7;
extern NSString *kServiceURL;
extern NSString *kUserIndentify;


-(void) viewDidLoad
{

    [super viewDidLoad];
    
    rightBtn= [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleBordered target:self action:@selector(saveAttend)];
    
    //本班学生数组
    NSDictionary *tmpDic=[userInfoDic objectForKey:self.banjiName];
    NSArray *tmpArray=nil;
    if ([tmpDic isKindOfClass:[NSArray class]]) {
        tmpArray=[[NSArray alloc] initWithArray:(NSArray *)tmpDic];
    }
    else
        tmpArray= [[NSArray alloc] initWithArray:tmpDic.allValues];
   
    //本节课学生考勤情况
    _scheduleArray=[[NSMutableArray alloc] initWithArray:[userInfoDic objectForKey:@"教师上课记录"]];
    _classInfoDic=[[NSMutableDictionary alloc] initWithDictionary:[_scheduleArray objectAtIndex:self.classIndex.intValue]];
    
    if([[_classInfoDic objectForKey:@"缺勤情况登记JSON"] isKindOfClass:[NSArray class]])
        _stuKaoQinArray=[[NSMutableArray alloc] initWithArray:[_classInfoDic objectForKey:@"缺勤情况登记JSON"]];
    else
        _stuKaoQinArray=[[NSMutableArray alloc] init];
    
    //考勤名称
    NSString *kaoqinStr=[userInfoDic objectForKey:@"考勤名称"];
    _kaoqinNameArray=[kaoqinStr componentsSeparatedByString:@","];
 
   
    
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,  NSUserDomainMask,YES);
    _savePath=[[documentPaths objectAtIndex:0] stringByAppendingString:@"/students/"];
    BOOL fileExists = [fileManager fileExistsAtPath:_savePath];
    if(!fileExists)
        [fileManager createDirectoryAtPath:_savePath withIntermediateDirectories:NO attributes:nil error:nil];
    
    _studentDic=[[NSMutableDictionary alloc] init];
    _headImageDic=[[NSMutableDictionary alloc] init];
    _requestArray=[[NSMutableArray alloc]init];
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
        [student setObject:[[NSNumber alloc] initWithInt:1] forKey:@"考勤"];
        
        //判断是否存在学生头像，如果没有则下载
        
        NSString *fileName=[NSString stringWithFormat:@"%@%@.jpg",_savePath,xuehao];
        if([fileManager fileExistsAtPath:fileName])
        {
            UIImage *img=[UIImage imageWithContentsOfFile:fileName];
            img=[img scaleToSize1:CGSizeMake(32, 32)];
            CGRect newSize=CGRectMake(0, 0,32,32);
            img=[img cutFromImage:newSize];
            [_headImageDic setObject:img forKey:xuehao];
        }
        else
        {
            NSString *urlStr=[student objectForKey:@"头像"];
            NSURL *url = [NSURL URLWithString:[urlStr URLEncodedString]];
            ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
            [_requestArray addObject:request];
            request.username=xuehao;
            [request setDelegate:self];
            [request startAsynchronous];
            
        }
        
        for(int j=0;j<_stuKaoQinArray.count;j++)
        {
            NSDictionary *kaoqinItem=[_stuKaoQinArray objectAtIndex:j];
            NSString *keyName=[kaoqinItem objectForKey:@"学号"];
            if([keyName isEqualToString:xuehao])
            {
                NSString *kaoqinName=[kaoqinItem objectForKey:@"考勤类型"];
                NSUInteger index=[_kaoqinNameArray indexOfObject:kaoqinName];
                if(index==NSNotFound)
                    index=1;
                else
                    index=index+1;
                
                [student setObject:[[NSNumber alloc] initWithInt:(int)index] forKey:@"考勤"];
                break;
            }
        }
       
        NSString *firstLetter=[pinYinResult substringToIndex:1];
        NSMutableArray *groupArray=[_studentDic objectForKey:firstLetter];
        if(groupArray==nil)
            groupArray=[[NSMutableArray alloc] init];
        [groupArray addObject:student];
        [_studentDic setObject:groupArray forKey:firstLetter];
    }
    if(_studentDic.count==0)
    {
        OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"本班没有学生"];
        [tipView show];
        return;
    }
    
    NSArray* tempList  = [_studentDic allKeys];
    _sectionArray = [tempList sortedArrayUsingSelector:@selector(compare:)];
    
    _imageSel=[[NSMutableArray alloc] init];
    [_imageSel addObject:[UIImage imageNamed:@"class_call_attend_sel"]];
    [_imageSel addObject:[UIImage imageNamed:@"class_call_late_sel"]];
    [_imageSel addObject:[UIImage imageNamed:@"class_call_leave_sel"]];
    [_imageSel addObject:[UIImage imageNamed:@"class_call_absence_sel"]];
    _imageDes=[[NSMutableArray alloc] init];
    [_imageDes addObject:[UIImage imageNamed:@"class_call_attend_nor"]];
    [_imageDes addObject:[UIImage imageNamed:@"class_call_late_nor"]];
    [_imageDes addObject:[UIImage imageNamed:@"class_call_leave_nor"]];
    [_imageDes addObject:[UIImage imageNamed:@"class_call_absence_nor"]];
    
    _imageMan=[UIImage imageNamed:@"defaultPerson"];
    _imageWoman=[UIImage imageNamed:@"defaultWoman"];
    

    
}
- (void)dealloc
{
    
    for(ASIHTTPRequest *req in _requestArray)
    {
        [req setDownloadProgressDelegate:nil];
        [req clearDelegatesAndCancel];
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [NSThread cancelPreviousPerformRequestsWithTarget:self];
}
- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSData *datas = [request responseData];
    UIImage *img=[[UIImage alloc]initWithData:datas];
    if(img!=nil)
    {
        NSString *path=[NSString stringWithFormat:@"%@%@.jpg",_savePath,request.username];
        [datas writeToFile:path atomically:YES];
        img=[img scaleToSize1:CGSizeMake(32, 32)];
        CGRect newSize=CGRectMake(0, 0,32,32);
        img=[img cutFromImage:newSize];
        [_headImageDic setObject:img forKey:request.username];
        [self.tableView reloadData];
        
    }
    if([_requestArray containsObject:request])
        [_requestArray removeObjectIdenticalTo:request];
    request=nil;
}
-(void)viewDidAppear:(BOOL)animated
{
    self.parentViewController.navigationItem.title=self.banjiName;
    self.parentViewController.navigationItem.rightBarButtonItem =rightBtn;
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
    
    return [_sectionArray count];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *groupName = [_sectionArray objectAtIndex:section];
    NSArray *listTeams = [_studentDic objectForKey:groupName];
	return [listTeams count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"attendCell" forIndexPath:indexPath];

    for(int i=0;i<_kaoqinNameArray.count;i++)
    {
        if(i>3) break;
        UILabel *lable=(UILabel *)[cell viewWithTag:2001+i];
        [lable setText:[_kaoqinNameArray objectAtIndex:i]];
        
    }
    
    NSUInteger section = [indexPath section];
	NSUInteger row = [indexPath row];
    NSString *groupName = [_sectionArray objectAtIndex:section];

	NSMutableArray *listTeams = [_studentDic objectForKey:groupName];
    
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"姓名" ascending:YES]];
    [listTeams sortUsingDescriptors:sortDescriptors];
    
    NSDictionary *student = [listTeams objectAtIndex:row];

    NSString *stuName=[student objectForKey:@"姓名"];
    NSString *xuehao=[student objectForKey:@"学号"];
    NSString *xingbie=[student objectForKey:@"性别"];
    NSNumber *kaoqin=[student objectForKey:@"考勤"];;
    int tag=kaoqin.intValue;
    if(tag==0) tag=1;
    UIButton *btn1=(UIButton *)[cell viewWithTag:1001];
    UIButton *btn2=(UIButton *)[cell viewWithTag:1002];
    UIButton *btn3=(UIButton *)[cell viewWithTag:1003];
    UIButton *btn4=(UIButton *)[cell viewWithTag:1004];
    
    [btn1 setImage:[_imageDes objectAtIndex:0]  forState:UIControlStateNormal];
    [btn2 setImage:[_imageDes objectAtIndex:1]  forState:UIControlStateNormal];
    [btn3 setImage:[_imageDes objectAtIndex:2]  forState:UIControlStateNormal];
    [btn4 setImage:[_imageDes objectAtIndex:3]  forState:UIControlStateNormal];
    
    UIButton *btnSel=(UIButton *)[cell viewWithTag:1000+tag];
    [btnSel setImage:[_imageSel objectAtIndex:tag-1]  forState:UIControlStateNormal];
    
    UIButton *headBtn=(UIButton *)[cell viewWithTag:11];
    UILabel *lblname=(UILabel *)[cell viewWithTag:12];
    lblname.text=stuName;
    if([xingbie isEqualToString:@"女"])
        [headBtn setImage:_imageWoman forState:UIControlStateNormal];
    else
        [headBtn setImage:_imageMan forState:UIControlStateNormal];
    UIImage *headImage=[_headImageDic objectForKey:xuehao];
    if(headImage!=Nil)
    {
        
        [headBtn setImage:headImage forState:UIControlStateNormal];
        //NSLog(@"%f,%f",headImage.size.width,headImage.size.height);
        headBtn.imageView.layer.cornerRadius = headImage.size.width / 2;
        headBtn.imageView.layer.masksToBounds = YES;
    }
    cell.tag=[xuehao intValue];
    return cell;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	NSString *groupName = [_sectionArray objectAtIndex:section];
	return groupName;
}
-(NSArray *) sectionIndexTitlesForTableView: (UITableView *) tableView
{
    return _sectionArray;
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
    
    
    while(![parent isKindOfClass:[UITableViewCell class]])
        parent=[parent superview];
    UITableViewCell *cell=(UITableViewCell *)parent;
    
    NSIndexPath * indexPath=[self.tableView indexPathForCell:cell];
    NSUInteger section = [indexPath section];
	NSUInteger row = [indexPath row];
    NSString *groupName = [_sectionArray objectAtIndex:section];
	NSMutableArray *listTeams = [_studentDic objectForKey:groupName];
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
            [btn setImage:[_imageSel objectAtIndex:btn.tag-1001]  forState:UIControlStateNormal];
            NSNumber *tag=[[NSNumber alloc] initWithInt:(int)btn.tag-1000];
            [student setObject:tag forKey:@"考勤"];
        }
        else
        {
            if(btn.tag>1000)
                [btn setImage:[_imageDes objectAtIndex:btn.tag-1001]  forState:UIControlStateNormal];
        }
    }
}

-(void) saveAttend
{
    if(_studentDic.count==0)
    {
        OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"本班没有学生"];
        [tipView show];
        return;
    }
    if(![rightBtn.title isEqualToString:@"保存"])
        return;
    NSMutableArray *kaoQinArray=[[NSMutableArray alloc] init];
    int iChuqin=0;
    for(id key in _studentDic)
    {
        NSArray *studArray=[_studentDic objectForKey:key];
        for(int i=0;i<studArray.count;i++)
        {
            NSDictionary *student=[studArray objectAtIndex:i];
            [kaoQinArray addObject:student];
            NSNumber *chuqin=[student objectForKey:@"考勤"];
            if([chuqin intValue]==1)
                iChuqin++;
        }
    }
    
    NSURL *url = [NSURL URLWithString:[[kServiceURL stringByAppendingString:@"appserver.php?action=changekaoqininfo&APP=IOS"] URLEncodedString]];
    
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init];
    [dic setObject:kUserIndentify forKey:@"用户较验码"];
    [dic setObject:self.classNo forKey:@"编号"];
    [dic setObject:[[NSNumber alloc] initWithInt:(int)kaoQinArray.count] forKey:@"班级人数"];
    [dic setObject:[[NSNumber alloc] initWithInt:iChuqin] forKey:@"实到人数"];
    
    [_stuKaoQinArray removeAllObjects];
 
    for(id key in _studentDic)
    {
        NSArray *stuArray=[_studentDic objectForKey:key];
        for(int i=0;i<stuArray.count;i++)
        {
            NSDictionary *student=[stuArray objectAtIndex:i];
            NSNumber *j=[student objectForKey:@"考勤"];
            if(j.intValue>1)
            {
                NSString *xuehao=[student objectForKey:@"学号"];
                NSMutableDictionary *kaoqinItem=[[NSMutableDictionary alloc]init];
                [kaoqinItem setObject:xuehao forKey:@"学号"];
                [kaoqinItem setObject:[_kaoqinNameArray objectAtIndex:j.intValue-1] forKey:@"考勤类型"];
                [_stuKaoQinArray addObject:kaoqinItem];
            }
            
        }
    }
    [_classInfoDic setObject:_stuKaoQinArray forKey:@"缺勤情况登记JSON"];
    [_scheduleArray setObject:_classInfoDic atIndexedSubscript:self.classIndex.intValue];
    [userInfoDic setObject:_scheduleArray forKey:@"教师上课记录"];
    
    NSError *error;
    NSMutableDictionary *stuKaoQinDic=[[NSMutableDictionary alloc]init];
    for(int i=0;i<_stuKaoQinArray.count;i++)
    {
        NSDictionary *kaoqinItem=[_stuKaoQinArray objectAtIndex:i];
        [stuKaoQinDic setObject:[kaoqinItem objectForKey:@"考勤类型"]  forKey:[kaoqinItem objectForKey:@"学号"]];
    }
    [dic setObject:stuKaoQinDic forKey:@"缺勤情况登记JSON"];
    NSMutableArray *dicArray=[[NSMutableArray alloc] init ];
    [dicArray addObject:dic];
    NSData *postData=[NSJSONSerialization dataWithJSONObject:dicArray options:NSJSONWritingPrettyPrinted error:&error];
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
    [rightBtn setTitle:@"保存中"];
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
        result=@"已保存";
        [rightBtn setTitle:@"保存"];
    }
    else
    {
        
         NSLog(@"失败，原因：%@",dict);
    }
    OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:result];
    [tipView show];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"studentInfo"])
    {
        UIView *parent=[(UIButton *)sender superview];
        while(![parent isKindOfClass:[UITableViewCell class]])
            parent=[parent superview];
        UITableViewCell *cell=(UITableViewCell *)parent;
       
        NSIndexPath * indexPath=[self.tableView indexPathForCell:cell];
        NSUInteger section = [indexPath section];
        NSUInteger row = [indexPath row];
        NSString *groupName = [_sectionArray objectAtIndex:section];
        NSArray *listTeams = [_studentDic objectForKey:groupName];
        NSDictionary *student = [listTeams objectAtIndex:row];

        DDIStudentInfo *destController=segue.destinationViewController;
        destController.student=student;
        
    }
    
}

@end
