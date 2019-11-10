//
//  DDIMultiSelLinkMan.h
//  掌上校园
//
//  Created by yons on 14-2-19.
//  Copyright (c) 2014年 dandian. All rights reserved.
//

#import "DDILinkManGroup.h"

@interface DDIMultiSelLinkMan : DDILinkManGroup
{
       
    UIImage *selectImage;
    UIImage *unselectImage;
    NSMutableArray *selectedArray;
    UIScrollView *sv;
    UIButton *finishBtn;
    NSDictionary *duizhaoDic;
    NSArray *allLinkManArray;
}
@end
