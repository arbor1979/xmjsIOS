//
//  DDIAlbumSend.h
//  掌上校园
//
//  Created by Mac on 15/1/9.
//  Copyright (c) 2015年 dandian. All rights reserved.
//

#import "DDIAppDelegate.h"
#import "CommonFunc.h"
#import "UIImage+Scale.h"
#import "CommonFunc.h"
#import "OLGhostAlertView.h"

@interface DDIAlbumSend : UITableViewController<UITextViewDelegate>
{
    UIToolbar * topView;
    NSData *fileData;
    NSMutableArray *requestArray;
    OLGhostAlertView *progressView;
    UIView *lockView;
    UIBarButtonItem *saveBtn;
}
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *lbAddress;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sgFanwei;
@property (weak, nonatomic) IBOutlet UILabel *lbDevice;
@property (strong, nonatomic) UIImage *image;
@property (weak, nonatomic) IBOutlet UILabel *lbholderText;
@property (weak, nonatomic) IBOutlet UILabel *lbTxtCount;

@end
