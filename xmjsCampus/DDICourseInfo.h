//
//  DDICourseInfo.h
//  老师助手
//
//  Created by yons on 14-2-10.
//  Copyright (c) 2014年 dandian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonFunc.h"
#import "UIImage+Scale.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "GTMBase64.h"
#import "OLGhostAlertView.h"
#import "DDIPictureBrows.h"
@interface DDICourseInfo : UITableViewController
{
    UIImage *oldImage;
    UIImage *grayStar;
    UIImage *goldStar;
    NSMutableArray *requestArray;
    OLGhostAlertView *alertTip;
    NSString *savePath;
    NSArray *photosArray;
    NSArray *photosArray1;
    NSArray *photosArray2;
    UILabel *coursePingJiaNum;
}
@property (strong,nonatomic) NSString *className;
@property (strong,nonatomic) NSString *classNo;
@property (strong,nonatomic) NSString *teacherUserName;
@property (strong,nonatomic) NSNumber *classIndex;
@property (weak, nonatomic) IBOutlet UIButton *headBtn;
@property (weak, nonatomic) IBOutlet UILabel *teacherName;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *teacherGrade;
@property (weak, nonatomic) IBOutlet UILabel *chargeCourse;
@property (weak, nonatomic) IBOutlet UILabel *chargeClass;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *courseGrade;
@property (weak, nonatomic) IBOutlet UILabel *courseDate;
@property (weak, nonatomic) IBOutlet UILabel *classRoom;
@property (weak, nonatomic) IBOutlet UIView *photosView;
@property (weak, nonatomic) IBOutlet UIView *photosView1;
@property (weak, nonatomic) IBOutlet UIView *photosView2;

@property (weak, nonatomic) IBOutlet UILabel *courseJiLv;
@property (weak, nonatomic) IBOutlet UILabel *courseWeiSheng;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *cellsChangeHeight;
@property (weak, nonatomic) IBOutlet UILabel *chuqin;
@property (weak, nonatomic) IBOutlet UILabel *chuqinren;
@property (weak, nonatomic) IBOutlet UILabel *teacherPingjiaNum;

- (IBAction)showBigPic:(id)sender;
@end
