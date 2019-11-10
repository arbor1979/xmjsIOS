//
//  DDIStudentInfo.h
//  老师助手
//
//  Created by yons on 13-11-29.
//  Copyright (c) 2013年 dandian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImage+Scale.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "NSString+URLEncoding.h"
#import "GTMBase64.h"
#import "PCPieChart.h"
#import "OLGhostAlertView.h"

@interface DDIStudentInfo : UIViewController <UIScrollViewDelegate,UIActionSheetDelegate>
{
    NSMutableArray *requestArray;
    float navbarHeight;
    NSString *selTel;
    UIImageView *headImage;
    OLGhostAlertView *alertTip;
    OLGhostAlertView *alertTip1;
    NSString *headImageName;
}
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) NSString *userWeiYi;
@property (strong, nonatomic) NSDictionary *student;
@property (strong, nonatomic) UIView *page1;
@property (strong, nonatomic) UIView *page2;
@property (strong, nonatomic) UIView *page3;

- (IBAction)pageChange:(id)sender;


@end
