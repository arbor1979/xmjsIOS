//
//  DDIPraiseDetail.h
//  掌上校园
//
//  Created by Mac on 15/1/25.
//  Copyright (c) 2015年 dandian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonFunc.h"
#import "ASIHTTPRequest.h"
#import "UIImage+Scale.h"
#import "DDIMyInforView.h"
#import "DDIGifView.h"
@interface DDIPraiseDetail : UITableViewController
{
    NSMutableArray *requestArray;
    DDIGifView *tempview;
    NSString *savepath;
}
@property (strong,nonatomic) NSArray *praiseList;
@end
