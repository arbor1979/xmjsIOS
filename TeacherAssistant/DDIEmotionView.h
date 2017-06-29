//
//  DDIEmotionView.h
//  掌上校园
//
//  Created by Mac on 15/1/23.
//  Copyright (c) 2015年 dandian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImage+animatedGIF.h"

@protocol DDIEmotionViewDelegate;
@interface DDIEmotionView : UIView<UIScrollViewDelegate>

@property(strong,nonatomic) NSArray *imageNameArray;
@property(strong,readonly)UIScrollView *scroll;
@property(strong,readonly)UIPageControl *page;
@property(assign)CGFloat btnWidth; //按钮大小

@property(nonatomic,assign) id <DDIEmotionViewDelegate> delegate;

-(void)fillImageToView;
@end

@protocol DDIEmotionViewDelegate
- (void)emotionBtnOnClick:(NSString*)imageName;
@end