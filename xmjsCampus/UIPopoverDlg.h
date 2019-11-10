//
//  UIPopoverListView.h
//  UIPopoverListViewDemo
//
//  Created by su xinde on 13-3-13.
//  Copyright (c) 2013年 su xinde. All rights reserved.
//

@class UIPopoverDlg;

@interface UIPopoverDlg : UIAlertController<UIPickerViewDataSource,UIPickerViewDelegate,UITextFieldDelegate>
{
    NSMutableArray *filterArr;
    UIPickerView *pickerView;
    UIView *activeView;
    UINavigationBar *navBar;
    UIToolbar *topView;
}
-(void)initSubViews:(NSMutableArray *)filterArr1;
-(NSMutableArray *)saveFilterValue;
@end
