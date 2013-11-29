//
//  DDIClassAttend.h
//  老师助手
//
//  Created by yons on 13-11-20.
//  Copyright (c) 2013年 dandian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSString+URLEncoding.h"
@interface DDIClassAttend : UIViewController <UITableViewDataSource,UITableViewDelegate>

@property (strong,nonatomic) NSString *banjiName;
@property (strong,nonatomic) NSString *classNo;
@property (strong,nonatomic) NSNumber *classIndex;

@property (strong,nonatomic) NSMutableData *datas;

- (IBAction)dingMingClick:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tableView;


@end
