//
//  DDIStudentResults.m
//  老师助手
//
//  Created by yons on 13-12-6.
//  Copyright (c) 2013年 dandian. All rights reserved.
//

#import "DDIStudentResults.h"

@interface DDIStudentResults ()

@end

@implementation DDIStudentResults



- (void)viewDidLoad
{
    [super viewDidLoad];
	UIView *bgView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.viewHeight.floatValue-20)];
    bgView.backgroundColor=[UIColor colorWithRed:237/255.0f green:249/255.0f blue:231/255.0f alpha:1.0];
    [self.view addSubview:bgView];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
