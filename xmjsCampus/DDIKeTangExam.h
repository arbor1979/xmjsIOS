//
//  DDIKeTangExam.h
//  老师助手
//
//  Created by yons on 13-12-7.
//  Copyright (c) 2013年 dandian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "GTMBase64.h"
#import "OLGhostAlertView.h"
#import "CommonFunc.h"
@interface DDIKeTangExam : UITableViewController<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,UIAlertViewDelegate>
{

    NSMutableArray *examArray; //本堂测验
    NSString *examName; //测验名称
    NSArray *abcArray;
    UIColor *clLightGray;
    UIColor *clGray;
    UIColor *clGreen;
    NSArray *ceYanShouJuan;;
    NSNumber *timeLim;
    NSTimer *aTimer;
    UIBarButtonItem *rightBtn;
    UILabel *timeTip;
    NSMutableArray *requestArray;
    OLGhostAlertView *alertTip;
    
}
@property (strong,nonatomic) NSString *banjiName;//班级名
@property (strong,nonatomic) NSString *className;//课程名
@property (strong,nonatomic) NSString *classNo;
@property  NSInteger classIndex;//在数组中的编号
@property (strong,nonatomic) NSString *examStatus;
@property  NSInteger leftSec;//剩余时间
@property  (strong,nonatomic) NSDate *endTime;//结束时间
-(void)loadExamList;
-(void)updateExamStatue;
@end
