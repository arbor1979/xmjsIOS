//
//  DDINotifySetup.h
//  老师助手
//
//  Created by yons on 13-12-27.
//  Copyright (c) 2013年 dandian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDIClassSchedule.h"
#import "OLGhostAlertView.h"

@interface DDINotifySetup : UITableViewController<UIPickerViewDataSource,UIPickerViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    OLGhostAlertView *alertTip;
    NSMutableArray *dayArray;
    NSMutableArray *hourArray;
    NSMutableArray *minuteArray;
    UIActionSheet *actionSheet;
    UIPickerView *pickerView;
    NSUserDefaults *defaults;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    UIAlertController *alertController;
#else
    UIViewController *alertController;
#endif
}
- (IBAction)openAcSheet:(id)sender;
- (IBAction)ifPopDayClick:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *alertTimeBtn;
@property (weak, nonatomic) IBOutlet UISwitch *ifPopDayTip;
@property (weak, nonatomic) IBOutlet UISegmentedControl *weekBegin;
@property (weak, nonatomic) IBOutlet UIButton *bgDefault;
@property (weak, nonatomic) IBOutlet UIButton *bgSelect;

@end
