//
//  DDIGifView.m
//  掌上校园
//
//  Created by Mac on 15/1/22.
//  Copyright (c) 2015年 dandian. All rights reserved.
//

#import "DDIGifView.h"

@implementation DDIGifView


-(NSArray *) emojiStringArray
{
    NSMutableArray *array=[NSMutableArray array];
    for(int i=0;i<=106;i++)
    {
        NSString *imageName;
        if(i<10)
            imageName=[NSString stringWithFormat:@"[f00%d]",i];
        else if(i<100)
            imageName=[NSString stringWithFormat:@"[f0%d]",i];
        else
            imageName=[NSString stringWithFormat:@"[f%d]",i];
        [array addObject:imageName];
    }
    [array addObject:@"[附件]"];
    return array;
    
}

-(BOOL)isEmojiExist:(NSString *)content
{
    BOOL flag=false;
    for(NSString *item in gifArray)
    {
        NSRange range=[content rangeOfString:item];
        if(range.location!=NSNotFound)
        {
            flag=true;
            break;
        }
        
    }
    return flag;
}

- (void)setMsgContent:(NSString *)msgContent
{
    if(gifArray==nil)
        gifArray=[self emojiStringArray];
    if(_font==nil)
        _font=[UIFont systemFontOfSize:14];
    if(_gifWidth==0)
        _gifWidth=24;
    for(UIView *sub in self.subviews)
    {
        if(sub)
            [sub removeFromSuperview];
    }
    _msgContent=msgContent;
    //聊天底部视图
    prePoint=CGPointMake(0, 0);
    lineHeight=0;
    BOOL existEmotion = [self isEmojiExist:msgContent];
    //判断是否存在表情
    if(self.frame.size.width<_minWidth)
    {
        CGRect newFrame=self.frame;
        newFrame.size.width=_minWidth;
        self.frame=newFrame;
    }
    if (!existEmotion) {
        
        CGSize size=CGSizeMake(self.frame.size.width, 1000.0f);
        CGSize newSize=[msgContent sizeWithFont:_font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
        CGRect newframe=self.frame;
        newframe.size=newSize;
        self.frame=newframe;
        UILabel *mesgLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0,newSize.width,newSize.height)];
        mesgLabel.backgroundColor = [UIColor clearColor];
        mesgLabel.font = _font;
        mesgLabel.numberOfLines = 0;
        mesgLabel.text = msgContent;
        mesgLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self addSubview:mesgLabel];
    }
    else {
        
        while(msgContent.length>0)
        {
            NSRange range1=[msgContent rangeOfString:@"["];
            NSRange range2=[msgContent rangeOfString:@"]"];
            if(range1.location!=NSNotFound && range2.location!=NSNotFound && range2.location>range1.location)
            {
                NSRange range=NSMakeRange(range1.location, range2.location-range1.location+1);
                NSString *gifName=[msgContent substringWithRange:range];
                NSString *leftStr=[msgContent substringToIndex:range1.location];
                NSString *rightStr=[msgContent substringFromIndex:range2.location+1];
                if([gifArray containsObject:gifName])
                {
                    [self addLabels:leftStr];
                    [self addImageView:gifName];
                }
                else
                    [self addLabels:[leftStr stringByAppendingString:gifName]];
                msgContent=rightStr;
                    
            }
            else
            {
                [self addLabels:msgContent];
                msgContent=@"";
            }
        
        }
        CGRect newframe=self.frame;
        newframe.size.height=prePoint.y+lineHeight;
        self.frame=newframe;
    }
}
-(void)addLabels:(NSString *)content
{
    BOOL flag=true;
    while (content.length>0 && flag)
    {
        flag=false;
        for (int i=1;i<=content.length;i++)
        {
            NSString *tempStr=[content substringToIndex:i];
            CGSize size=[tempStr sizeWithFont:_font];
            if(lineHeight<size.height)
                lineHeight=size.height;
            if(size.width>=self.frame.size.width-prePoint.x-5)
            {
                UILabel *mesgLabel = [[UILabel alloc]initWithFrame:CGRectMake(prePoint.x, prePoint.y,size.width,size.height)];
                mesgLabel.backgroundColor = [UIColor clearColor];
                mesgLabel.font = _font;
                mesgLabel.text = tempStr;
                [self addSubview:mesgLabel];
                content=[content substringFromIndex:i];
                prePoint.y+=lineHeight;
                prePoint.x=0;
                flag=true;
                break;
            }
        }
    }
    if(content.length>0)
    {
        CGSize size=[content sizeWithFont:_font];
        if(lineHeight<size.height)
            lineHeight=size.height;
        UILabel *mesgLabel = [[UILabel alloc]initWithFrame:CGRectMake(prePoint.x, prePoint.y,size.width,size.height)];
        mesgLabel.backgroundColor = [UIColor clearColor];
        mesgLabel.font = _font;
        mesgLabel.text = content;
        [self addSubview:mesgLabel];
        //prePoint.y+=lineHeight;
        prePoint.x+=size.width;
    }
    
}
-(void)addImageView:(NSString *)gifName
{
    if(prePoint.x+_gifWidth>self.frame.size.width)
    {
        prePoint.x=0;
        prePoint.y+=lineHeight;
    }

    NSString *realGifName=[gifName substringWithRange:NSMakeRange(1, gifName.length-2)];
    UIImageView *tempImageView = [[UIImageView alloc] initWithFrame:CGRectMake(prePoint.x, prePoint.y, _gifWidth, _gifWidth)];
    NSURL *url = [[NSBundle mainBundle] URLForResource:realGifName withExtension:@"gif"];
    if(url==nil)
        url = [[NSBundle mainBundle] URLForResource:realGifName withExtension:@"png"];
    if(url!=nil)
    {
    tempImageView.image = [UIImage animatedImageWithAnimatedGIFURL:url];
    [self addSubview:tempImageView];
    prePoint.x+=_gifWidth;
    lineHeight=_gifWidth;
    }

}
@end
