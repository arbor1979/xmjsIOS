//
//  DDIMultiSelLinkMan.h
//  掌上校园
//
//  Created by yons on 14-2-19.
//  Copyright (c) 2014年 dandian. All rights reserved.
//

#import "DDILinkManGroup.h"

@protocol SelectMutiDataDelegate<NSObject>
-(void) setListValue:(NSArray *)selectedList;
@end

@interface DDIMultiSelStudent : DDILinkManGroup
{
       
    UIImage *selectImage;
    UIImage *unselectImage;
    NSMutableArray *selectedArray;
    UIScrollView *sv;
    UIButton *finishBtn;
    NSMutableDictionary *duizhaoDic;
    CGPoint lastPoint;
}
@property (weak) id<SelectMutiDataDelegate>delegate;
- (void)setGroupArray:(NSArray *)grouparray;
- (void)setSelectedArray:(NSArray *)selectedarray;
- (void)setAllStudentArray:(NSDictionary *)allStudent;
@end
