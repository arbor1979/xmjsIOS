//
//  DDIPictureBrows.h
//  掌上校园
//
//  Created by yons on 14-3-6.
//  Copyright (c) 2014年 dandian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DDIPictureBrows : UIView<UIScrollViewDelegate>
{
    UIScrollView *src;
    UIPageControl *pageControl;
    CGFloat offset;
}
@property (nonatomic,strong) NSArray *picArray;
-(void)showFromIndex:(int)index;
@end
