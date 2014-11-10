//
//  UIImage+Scale.h
//  老师助手
//
//  Created by yons on 13-12-16.
//  Copyright (c) 2013年 dandian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIImage(scale)
-(UIImage*)scaleToSize:(CGSize)size;
-(UIImage*)scaleToSize1:(CGSize)size;
-(UIImage*)cutFromImage:(CGRect)rect;
@end
