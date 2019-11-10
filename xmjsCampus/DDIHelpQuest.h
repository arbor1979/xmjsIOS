//
//  DDIHelpQuest.h
//  老师助手
//
//  Created by yons on 13-12-20.
//  Copyright (c) 2013年 dandian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIFormDataRequest.h"
#import "GTMBase64.h"
#import "OLGhostAlertView.h"
@interface DDIHelpQuest : UIViewController
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton  *sendBtn;
@property (weak, nonatomic) IBOutlet UIView *view1;
- (IBAction)submitClick:(id)sender;

@end
