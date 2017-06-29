//
//  DDIStudentResults.m
//  老师助手
//
//  Created by yons on 13-12-6.
//  Copyright (c) 2013年 dandian. All rights reserved.
//

#import "DDIStudentResults.h"
extern Boolean kIOS7;
@interface DDIStudentResults ()

@end

@implementation DDIStudentResults



- (void)viewDidLoad
{
    [super viewDidLoad];
    /*
    int height=20;
    if(kIOS7)
        height=40;
    */
	UIView *bgView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.viewHeight.floatValue)];
    bgView.backgroundColor=[UIColor colorWithRed:237/255.0f green:249/255.0f blue:231/255.0f alpha:1.0];
    [self.view addSubview:bgView];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
