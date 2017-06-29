//
//  DDIKaoQinTitle.h
//  掌上校园
//
//  Created by yons on 14-3-12.
//  Copyright (c) 2014年 dandian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIFormDataRequest.h"
#import "GTMBase64.h"
#import "OLGhostAlertView.h"
#import "CommonFunc.h"
#import "DDIKaoQinDetail.h"
@interface DDIKaoQinTitle : UIViewController<UIPickerViewDataSource,UIPickerViewDelegate>
{
    NSDictionary *titleArray;
    NSString *savePath;
    NSMutableArray *requestArray;
    OLGhostAlertView *alertTip;
    UIActionSheet *actionSheet;
    UIPickerView *pickerView;
    NSMutableArray *weekArray;
    NSString *segUrl0;
    NSString *segUrl1;
    #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
        UIAlertController *alertController;
    #else
        UIViewController *alertController;
    #endif
}

@property (nonatomic,strong) NSString *interfaceUrl;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *thirdviewheight;

@property (weak, nonatomic) IBOutlet UIButton *headImage;
@property (strong, nonatomic) IBOutletCollection (UIButton) NSArray *btnChuqins;
@property (strong, nonatomic) IBOutletCollection (UIImageView) NSArray *imgChuqins;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *lblValue;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *lblItemName;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segWeekOrMonth;
@property (weak, nonatomic) IBOutlet UIButton *pickWeeks;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblXuehao;
@property (weak, nonatomic) IBOutlet UILabel *lblBanji;

@property (weak, nonatomic) IBOutlet UIView *searchView;
@property (weak, nonatomic) IBOutlet UIView *thirdView;
- (IBAction)showBigPic:(id)sender;
- (IBAction)showDetail:(id)sender;
- (IBAction)openAcSheet:(id)sender;
-(IBAction)segmentAction:(UISegmentedControl *)Seg;
@end
