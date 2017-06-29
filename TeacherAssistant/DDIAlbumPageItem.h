//
//  DDIAlbumPageItem.h
//  掌上校园
//
//  Created by Mac on 15/1/13.
//  Copyright (c) 2015年 dandian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonFunc.h"
#import "UIImage+Scale.h"
#import "ASIHTTPRequest.h"
#import "DDIMyInforView.h"
#import "DDIGifView.h"
#import "CommonFunc.h"
#import "JSMessageInputView.h"
#import "UIButton+JSMessagesView.h"
#import "NSString+JSMessagesView.h"
#import "UIView+AnimationOptionsForCurve.h"
#import "DDIEmotionView.h"
#import "DDIPraiseDetail.h"
#import "AlbumMsg.h"

@interface DDIAlbumPageItem : UIViewController<UITableViewDelegate,UITableViewDataSource,JSMessageInputViewDelegate,UITextViewDelegate,JSDismissiveTextViewDelegate,DDIEmotionViewDelegate,UIActionSheetDelegate>
{
    NSString *savepath;
    NSMutableArray *requestArray;
    DDIGifView *tempview;
    NSMutableDictionary *indexPathDic;
    JSMessageInputView *inputToolBarView;
    CGPoint oldPoint;
    UIToolbar *topView;
    BOOL ifkeyshow;
    bool ificonshow;
    NSInteger minGifViewWidth;
    CGFloat curKeyboardHeight;
    UILabel *lbCount;
    UIView *replyTip;
    UILabel *lbTiptitle;
    NSString *replyId;
}
@property (nonatomic, strong) NSMutableDictionary* imageItem;
@property (nonatomic) UINavigationController* myNav;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (assign, nonatomic) CGFloat previousTextViewContentHeight;
@property (nonatomic, strong) DDIEmotionView *emtionV;
@end
