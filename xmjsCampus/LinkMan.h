//
//  LinkMan.h
//  老师助手
//
//  Created by yons on 14-1-15.
//  Copyright (c) 2014年 dandian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LinkMan : NSObject

@property (nonatomic) int rowid;
@property (nonatomic, copy) NSString* groupName;
@property (nonatomic, copy) NSString* userId;
@property (nonatomic, copy) NSString* userName;
@property (nonatomic, copy) NSString* sex;
@property (nonatomic, copy) NSString* tel;
@property (nonatomic, copy) NSString* headImage;
@property (nonatomic, copy) NSString* pinyin;
@end
