//
//  DDINewsDetail.h
//  掌上校园
//
//  Created by yons on 14-3-10.
//  Copyright (c) 2014年 dandian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "News.h"
#import "CommonFunc.h"
#import "ASIFormDataRequest.h"
#import "OLGhostAlertView.h"
#import "GTMBase64.h"
#import "DDIDataModel.h"
#import "DDIPictureBrows.h"

@interface DDINewsDetail : UIViewController
{
    UIScrollView *scrollView;
    UIActivityIndicatorView *aiv;
    NSMutableArray *requestArray;
    NSString *savePath;
    OLGhostAlertView *tip;
    NSMutableArray *picArray;
}
@property (nonatomic,strong) News *news;
@end
