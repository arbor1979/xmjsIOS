//
//  DDIGifView.h
//  掌上校园
//
//  Created by Mac on 15/1/22.
//  Copyright (c) 2015年 dandian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImage+animatedGIF.h"
@interface DDIGifView : UIView
{
     NSArray *gifArray;
    CGPoint prePoint;
    CGFloat lineHeight;
}
@property (strong,nonatomic) UIFont *font;
@property (strong,nonatomic) NSString *msgContent;
@property (assign) NSInteger minWidth;
@property (assign) NSInteger gifWidth;
@end
