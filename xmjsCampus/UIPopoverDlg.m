//
//  UIPopoverListView.m
//  UIPopoverListViewDemo
//
//  Created by su xinde on 13-3-13.
//  Copyright (c) 2013年 su xinde. All rights reserved.
//

#import "UIPopoverDlg.h"
#import <QuartzCore/QuartzCore.h>

//#define FRAME_X_INSET 20.0f
//#define FRAME_Y_INSET 40.0f

@interface UIPopoverDlg ()

@end

@implementation UIPopoverDlg

-(void)initSubViews:(NSMutableArray *)filterArr1
{
    
    if(topView==nil)
    {
        topView = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
        //设置style
        [topView setBarStyle:UIBarStyleDefault];
        //定义两个flexibleSpace的button，放在toolBar上，这样完成按钮就会在最右边
        UIBarButtonItem * button1 =[[UIBarButtonItem  alloc]initWithBarButtonSystemItem:                                        UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        UIBarButtonItem * button2 = [[UIBarButtonItem  alloc]initWithBarButtonSystemItem:                                        UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        //定义完成按钮
        UIBarButtonItem * doneButton = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStyleDone  target:self action:@selector(resignKeyboard)];
        //在toolBar上加上这些按钮
        NSArray * buttonsArray = [NSArray arrayWithObjects:button1,button2,doneButton,nil];
        [topView setItems:buttonsArray];
    }
    
    CGFloat width=250;
    for(UIView *item in self.view.subviews)
    {
        if([item isKindOfClass:[UIDatePicker class]] || [item isKindOfClass:[UIPickerView class]] || [item isKindOfClass:[UITextField class]])
        {
            [item removeFromSuperview];
        }
    }
    filterArr=filterArr1;
    int height=50;
    for(int i=0;i<filterArr.count;i++)
    {
        NSDictionary *item=[filterArr objectAtIndex:i];
        NSString *itemtype=[item objectForKey:@"类型"];
        if([itemtype isEqualToString:@"文本框"])
        {
            UITextField *tv_item=[[UITextField alloc]initWithFrame:CGRectMake(10, height, width, 30)];
            tv_item.tag=100+i;
            tv_item.layer.borderWidth=1.0;
            tv_item.layer.borderColor=[UIColor grayColor].CGColor;
            tv_item.layer.cornerRadius=5.0;
            [tv_item setPlaceholder:[item objectForKey:@"标题"]];
            if([[item objectForKey:@"输入法"] isEqualToString:@"数字"])
                tv_item.keyboardType=UIKeyboardTypeNumberPad;
            if([item objectForKey:@"值"]!=nil)
                tv_item.text=[item objectForKey:@"值"];
            tv_item.delegate=self;
            tv_item.inputAccessoryView=topView;
            [self.view addSubview:tv_item];
            height+=30;
        }
        else if([itemtype isEqualToString:@"下拉框"])
        {
            UIPickerView *pickerView= [[UIPickerView alloc] initWithFrame:CGRectMake(10, height, width, 120)];
            pickerView.tag=100+i;
            pickerView.dataSource = self;
            pickerView.delegate=self;
            pickerView.showsSelectionIndicator = YES;
            [self.view addSubview:pickerView];
            NSArray *pickerArray=[item objectForKey:@"选项"];
            if(pickerArray==nil)
                pickerArray=[NSArray arrayWithObject:@""];
            [pickerView reloadAllComponents];
            NSInteger index=0;
            if([item objectForKey:@"值"]!=nil)
                index=[pickerArray indexOfObject:[item objectForKey:@"值"]];
            if(index>=pickerArray.count)
                index=0;
            [pickerView selectRow:index inComponent:0 animated:NO];
            height+=120;
        }
        
    }
   
}

- (void)resignKeyboard {
    if(activeView)
        [activeView resignFirstResponder];
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeView=textField;
}

#pragma mark 实现协议UIPickerViewDelegate方法
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSDictionary *item=[filterArr objectAtIndex:pickerView.tag-100];
    NSArray *pickerArray=[item objectForKey:@"选项"];
    if(row>pickerArray.count-1)
        return @"";
    else
        return [pickerArray objectAtIndex:row];

}

- (NSInteger)numberOfComponentsInPickerView:(nonnull UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(nonnull UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSDictionary *item=[filterArr objectAtIndex:pickerView.tag-100];
    NSArray *pickerArray=[item objectForKey:@"选项"];
    return pickerArray.count;
}

-(NSMutableArray *)saveFilterValue
{
    for(int i=0;i<filterArr.count;i++)
    {
        NSMutableDictionary *item=[[NSMutableDictionary alloc]initWithDictionary:[filterArr objectAtIndex:i]];
        NSString *itemtype=[item objectForKey:@"类型"];
        if([itemtype isEqualToString:@"文本框"])
        {
            UITextField *tf_item=[self.view viewWithTag:100+i];
            NSString *textvalue=tf_item.text;
            [item setObject:textvalue forKey:@"值"];
        }
        else if([itemtype isEqualToString:@"下拉框"])
        {
            UIPickerView *pv_item=[self.view viewWithTag:100+i];
            NSInteger index=[pv_item selectedRowInComponent:0];
            NSArray *options=[item objectForKey:@"选项"];
            NSString *textvalue=[options objectAtIndex:index];
            [item setObject:textvalue forKey:@"值"];
        }
        [filterArr replaceObjectAtIndex:i withObject:item];
    }
    return filterArr;
}

@end
