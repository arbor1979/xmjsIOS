//
//  News.h
//  掌上校园
//
//  Created by yons on 14-3-10.
//  Copyright (c) 2014年 dandian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface News : NSObject
@property (nonatomic) int rowid;
@property (nonatomic) int newsid;
@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* image;
@property (nonatomic, copy) NSString* time;
@property (nonatomic, copy) NSString* content;
@property (nonatomic, copy) NSString* url;
@property (nonatomic) int ifread;
@property (nonatomic,copy) NSArray *picArray;
@property (nonatomic,copy) NSArray *fujianArray;
@end
