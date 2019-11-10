//
//  UIImage+Scale.m
//  老师助手
//
//  Created by yons on 13-12-16.
//  Copyright (c) 2013年 dandian. All rights reserved.
//

#import "UIImage+Scale.h"

@implementation UIImage(Scale)

-(UIImage*)scaleToSize:(CGSize)size
{

    int h = self.size.height;
    int w = self.size.width;
    
    if(h <= size.height && w <= size.width) {
        return self;
    } else {
        float destWith = 0.0f;
        float destHeight = 0.0f;
        
        float suoFang = (float)w/h;
        float suo = (float)h/w;
        if (w>h) {
            destWith = (float)size.width;
            destHeight = size.width * suo;
        }else {
            destHeight = (float)size.height;
            destWith = size.height * suoFang;
        }

        CGSize itemSize = CGSizeMake(destWith, destHeight);
        UIGraphicsBeginImageContext(itemSize);
        CGRect imageRect = CGRectMake(0, 0, destWith, destHeight);
        [self drawInRect:imageRect];
        UIImage *newImg = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return newImg;
    }

}
-(UIImage*)scaleToSize1:(CGSize)size
{

    int h = self.size.height;
    int w = self.size.width;
    
    
        float destWith = 0.0f;
        float destHeight = 0.0f;
        
        float suoFang = (float)w/h;
        float suo = (float)h/w;
        if (w<h) {
            destWith = (float)size.width;
            destHeight = size.width * suo;
        }else {
            destHeight = (float)size.height;
            destWith = size.height * suoFang;
        }

        CGSize itemSize = CGSizeMake(destWith, destHeight);
        UIGraphicsBeginImageContext(itemSize);
        CGRect imageRect = CGRectMake(0, 0, destWith, destHeight);
        [self drawInRect:imageRect];
        UIImage *newImg = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return newImg;
    
    
}
-(UIImage*)cutFromImage:(CGRect)rect
{

    CGImageRef sourceImageRef = self.CGImage;
    
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
    
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    CGImageRelease(newImageRef);
    return newImage;
    
}
@end
