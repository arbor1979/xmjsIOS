//
//  DDIShangkeTime.m
//  掌上校园
//
//  Created by yons on 14-9-5.
//  Copyright (c) 2014年 dandian. All rights reserved.
//

#import "DDIShangkeTime.h"
extern NSMutableDictionary *userInfoDic;
@interface DDIShangkeTime ()

@end

@implementation DDIShangkeTime



- (void)viewDidLoad
{
    [super viewDidLoad];

    shangkeTime=[[userInfoDic objectForKey:@"课表规则"] objectForKey:@"节次时间"];
    if(shangkeTime==nil)
    {
        shangkeTime=[[NSArray alloc]init];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return shangkeTime.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    UILabel *lblLeft=(UILabel *)[cell viewWithTag:101];
    UILabel *lblRight=(UILabel *)[cell viewWithTag:102];
    NSDictionary *dic=[shangkeTime objectAtIndex:indexPath.row];
    if(dic!=nil)
    {
        lblLeft.text=[NSString stringWithFormat:@"第%@节",[dic objectForKey:@"名称"]];
        lblRight.text=[dic objectForKey:@"时间"];
    }
    return cell;
}

@end
