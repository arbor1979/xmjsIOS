//
//  DDIMyInforView.h
//  老师助手
//
//  Created by yons on 13-12-20.
//  Copyright (c) 2013年 dandian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImage+Scale.h"
#import "ASIHTTPRequest.h"
#import "CommonFunc.h"

@interface DDIMyInforView : UITableViewController
{
    NSDictionary *theTeacherDic;
    NSMutableArray *requestArray;
    
}
@property (strong,nonatomic) NSMutableArray *enableChangeArray;
@property (strong,nonatomic) NSMutableArray *disableChangeArray;

@property (strong,nonatomic) UIImage *oldImage;
@property (strong,nonatomic) UIImage *headImage;

@property(strong,nonatomic) NSString *userWeiYi;

- (IBAction)showBigPic:(id)sender;
@end
