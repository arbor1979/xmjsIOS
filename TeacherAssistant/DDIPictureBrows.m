//
//  DDIPictureBrows.m
//  掌上校园
//
//  Created by yons on 14-3-6.
//  Copyright (c) 2014年 dandian. All rights reserved.
//

#import "DDIPictureBrows.h"

@implementation DDIPictureBrows

- (id)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    src=[[UIScrollView alloc]initWithFrame:frame];
    src.pagingEnabled=YES;
    src.backgroundColor=[UIColor blackColor];
    src.delegate=self;
    [self addSubview:src];
    
    pageControl=[[UIPageControl alloc] initWithFrame:CGRectMake(src.frame.origin.x, src.frame.origin.y+src.frame.size.height-20, src.frame.size.width, 20)];
    pageControl.userInteractionEnabled = NO;
    [self addSubview:pageControl];
    
    
    return self;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    if(scrollView==src)
        return nil;
    else
    {
        for (UIView *v in scrollView.subviews){
            return v;
        }
    }
    return nil;

}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    if (scrollView == src)
    {
        CGFloat x = scrollView.contentOffset.x;
        if (x==offset){
            
        }
        else {
            offset = x;
            for (UIScrollView *s in scrollView.subviews){
                if ([s isKindOfClass:[UIScrollView class]]){
                    [s setZoomScale:1.0];
                }
            }
        }
    }
}
-(void)dealloc
{
    [[UIMenuController sharedMenuController] setMenuVisible:NO animated:NO];
}

-(void)closeView
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self removeFromSuperview];
}
-(void)showFromIndex:(int)index
{

    [src.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    src.contentSize=CGSizeMake(_picArray.count*src.frame.size.width, src.frame.size.height);
    pageControl.numberOfPages=_picArray.count;
    for(int i=0;i<_picArray.count;i++)
    {
        UIScrollView *subSrc=[[UIScrollView alloc] initWithFrame:CGRectMake(i*src.frame.size.width, 0, src.frame.size.width, src.frame.size.height)];
        subSrc.delegate=self;
        subSrc.userInteractionEnabled=YES;
        subSrc.multipleTouchEnabled=YES;
        subSrc.minimumZoomScale = 1.0;
        subSrc.maximumZoomScale = 4.0;
        [subSrc setZoomScale:1.0];
        
        UIImage *tempImg=[_picArray objectAtIndex:i];
        
        UIImageView *imgview=[[UIImageView alloc] initWithFrame:CGRectMake(10, 0, src.frame.size.width-20, src.frame.size.height)];
        imgview.contentMode=UIViewContentModeScaleAspectFit;
        imgview.clipsToBounds=YES;
        [imgview setImage:tempImg];
        [imgview setUserInteractionEnabled:YES];
        subSrc.contentSize=imgview.frame.size;
        //长按
        UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                                 action:@selector(handleLongPress:)];
        [recognizer setMinimumPressDuration:0.4];
        [imgview addGestureRecognizer:recognizer];
        
        //点击
        UITapGestureRecognizer *singleTapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(closeView)];
        [imgview addGestureRecognizer:singleTapGesture];
        UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
        doubleTapGesture.numberOfTapsRequired = 2;
        [imgview addGestureRecognizer:doubleTapGesture];
        
        [singleTapGesture requireGestureRecognizerToFail:doubleTapGesture];
        
        [subSrc addSubview:imgview];
        [src addSubview:subSrc];
    }
    pageControl.currentPage=index;
    src.contentOffset=CGPointMake(index*src.frame.size.width, 0);
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}
-(void)doubleTap:(UITapGestureRecognizer *)Recognizer
{
    UIScrollView *imgScrollView=(UIScrollView *)[Recognizer.view superview];
    if([imgScrollView isKindOfClass:[UIScrollView class]])
    {
        if (imgScrollView.zoomScale > 1.0)
        {
            [imgScrollView setZoomScale:1.0 animated:YES];
        }
        else
        {
            [imgScrollView setZoomScale:2.0f animated:YES];
        }
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(scrollView==src)
        pageControl.currentPage=floor(scrollView.contentOffset.x/scrollView.frame.size.width);
    [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)longPress
{
    ;
    if(longPress.state != UIGestureRecognizerStateBegan || ![self becomeFirstResponder])
        return;
    
    UIMenuController *menu = [UIMenuController sharedMenuController];
    UIMenuItem *saveItem = [[UIMenuItem alloc] initWithTitle:@"保存到相册" action:@selector(saveImage:)];
   
    [menu setMenuItems:[NSArray arrayWithObjects:saveItem, nil]];
    
    [menu setTargetRect:CGRectInset(self.frame, 0.0f, 4.0f) inView:self];
    
    [menu setMenuVisible:YES animated:YES];
    
    [menu update];
}
-(BOOL)canBecomeFirstResponder
{
    return true;
}
-(BOOL) canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(saveImage:))
        return YES;
    else
        return NO; //隐藏系统默认的菜单项
}
#pragma mark - Save Image
-(void)saveImage:(id)sender{
    
    UIImageWriteToSavedPhotosAlbum([_picArray objectAtIndex:pageControl.currentPage], self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    
    UIAlertView *alertView;
    
    if (error != NULL){
        alertView = [[UIAlertView alloc] initWithTitle:@"保存失败" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
        
    }
    
}

@end
