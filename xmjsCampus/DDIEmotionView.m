//
//  DDIEmotionView.m
//  掌上校园
//
//  Created by Mac on 15/1/23.
//  Copyright (c) 2015年 dandian. All rights reserved.
//

#import "DDIEmotionView.h"

@implementation DDIEmotionView
-(id)initWithFrame:(CGRect)frame
{
    _scroll=[[UIScrollView alloc]initWithFrame:CGRectZero];
    _page = [[UIPageControl alloc]initWithFrame:CGRectZero];
    self=[super initWithFrame:frame];
    if(self)
    {
        
        [self addSubview:_scroll];
        [self addSubview:_page];
        _scroll.pagingEnabled=YES;
        _scroll.delegate=self;
        _scroll.showsHorizontalScrollIndicator=NO;
        _page.currentPageIndicatorTintColor = [UIColor blackColor];
        _page.pageIndicatorTintColor = [UIColor grayColor];
        if(_btnWidth==0)
            _btnWidth=28;
  
    }
    return self;
}
-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    _scroll.frame=CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    _page.frame=CGRectMake(0, self.frame.size.height-20, self.frame.size.width, 20);
    
}
-(void)fillImageToView
{
    int left=_btnWidth/3;
    int top=_btnWidth/3;
    int page=1;
    for(UIView *view in _scroll.subviews)
    {
        [view removeFromSuperview];
    }
    if(self.frame.size.width<_btnWidth/3*2+_btnWidth)
        return;
    if(self.frame.size.height<_btnWidth/3*2+_btnWidth)
        return;
    if(_imageNameArray==nil)
        return;
    for(int i=0;i<_imageNameArray.count;i++)
    {
        NSString *imageName=[_imageNameArray objectAtIndex:i];
        NSURL *url = [[NSBundle mainBundle] URLForResource:imageName withExtension:@"gif"];
        UIImage *img= [UIImage animatedImageWithAnimatedGIFURL:url];
        
        if(img)
        {
            UIImageView *iv=[[UIImageView alloc]initWithFrame:CGRectMake(left, top, _btnWidth, _btnWidth)];
            //[btn setImage:img forState:UIControlStateNormal];
            iv.image=img;
            [_scroll addSubview:iv];
            UIButton *btn=[[UIButton alloc]initWithFrame:iv.frame];
            [_scroll addSubview:btn];
            [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag=i;
            
            left+=_btnWidth+_btnWidth/3;
            if(left>self.frame.size.width*page-_btnWidth/3-_btnWidth)
            {
                left=self.frame.size.width*(page-1)+_btnWidth/3;
                top+=_btnWidth+_btnWidth/3;
            }
            if(top>self.frame.size.height-_btnWidth/3-_btnWidth)
            {
                page++;
                left=self.frame.size.width*(page-1)+_btnWidth/3;
                top=_btnWidth/3;
                if(i==_imageNameArray.count-1)
                    page--;
                
            }
        }
    }
    _page.numberOfPages = page;
    _page.currentPage = 0;
    _scroll.contentSize=CGSizeMake(self.frame.size.width*page, self.frame.size.height);
    
}
-(void)btnClick:(UIButton *)sender
{
    if([(NSObject *)_delegate respondsToSelector:@selector(emotionBtnOnClick:)])
    {
        NSString *imageName=[_imageNameArray objectAtIndex:sender.tag];
        [_delegate emotionBtnOnClick:imageName];
    }
}
- (void)scrollViewDidScroll:(UIScrollView *)sender

{
    
    int page = _scroll.contentOffset.x/self.frame.size.width;
    
    _page.currentPage = page;
    
}
@end
