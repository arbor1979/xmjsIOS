//
//  DDINotifySetup.h
//  老师助手
//
//  Created by yons on 13-12-27.
//  Copyright (c) 2013年 dandian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDIClassSchedule.h"
@interface DDINotifySetup : UITableViewController<UIPickerViewDataSource,UIPickerViewDelegate>
{
    NSMutableArray *dayArray;
    NSMutableArray *hourArray;
    NSMutableArray *minuteArray;
    UIActionSheet *actionSheet;
    UIPickerView *pickerView;
    NSUserDefaults *defaults;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    UIAlertController *alertController;
#endif
}
- (IBAction)openAcSheet:(id)sender;
- (IBAction)ifPopDayClick:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *alertTimeBtn;
@property (weak, nonatomic) IBOutlet UISwitch *ifPopDayTip;

@end
