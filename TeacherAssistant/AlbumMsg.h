//
//  AlbumMsg.h
//  掌上校园
//
//  Created by Mac on 15/1/27.
//  Copyright (c) 2015年 dandian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlbumMsg : NSObject
@property (assign)NSInteger rowid;
@property (nonatomic,copy)NSString *fromId;
@property (nonatomic,copy)NSString *fromHeadUrl;
@property (nonatomic,copy)NSString *fromName;
@property (nonatomic,copy)NSString *time;
@property (nonatomic,copy)NSString *msg;
@property (nonatomic,copy)NSString *toId;
@property (nonatomic,copy)NSString *toName;
@property (nonatomic,copy)NSString *type;
@property(nonatomic,copy)NSDictionary *imageDic;
@property(nonatomic,copy)NSString *imageJson;
-(id)initWithDic:(NSDictionary *)dict;
@end
