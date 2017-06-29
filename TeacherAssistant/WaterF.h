//
//  WaterF.h
//  CollectionView
//
//  Created by d2space on 14-2-21.
//  Copyright (c) 2014年 D2space. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WaterFLayout.h"
#import "CommonFunc.h"
#import "EGORefreshTableHeaderView.h"


@protocol WaterFPullDownDelegate
@required
- (void)reloadNewAlbumData;
@optional
-(void)cellOnClick:(NSInteger)index;
@end

@interface WaterF : UICollectionViewController <EGORefreshTableHeaderDelegate>
{
    NSString *savepath;
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
}
@property (nonatomic,strong) NSMutableArray* imagesArr;

@property (nonatomic,assign) NSInteger sectionNum;
@property (nonatomic) NSInteger imagewidth;
@property (nonatomic) CGFloat textViewHeight;
@property (nonatomic, weak) id delegate;
- (void)doneLoadingTableViewData:(NSNumber *)newcount;

@end
