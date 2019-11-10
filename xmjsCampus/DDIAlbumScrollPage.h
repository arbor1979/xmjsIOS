//
//  HomeViewController.h
//  DDScrollViewController Example
//
//  Created by Hirat on 13-11-8.
//  Copyright (c) 2013年 Hirat. All rights reserved.
//

#import "DDScrollViewController.h"
#import "DDIAlbumPageItem.h"
#import "ASIFormDataRequest.h"
#import "GTMBase64.h"
#import "LFCGzipUtillity.h"
#import "OLGhostAlertView.h"
#import "DDIEmotionView.h"

@protocol ReloadNewImageDelegate <NSObject>

-(NSMutableArray *)getNewImageArray:(NSString *)lastImageName;

@end
@interface DDIAlbumScrollPage : DDScrollViewController <DDScrollViewDataSource,UIAlertViewDelegate>
{
    NSMutableArray *pageCacheArray;
    NSMutableArray *requestArray;
    NSMutableArray *browsedArray;
    NSMutableArray *praisedArray;
    NSMutableArray *deleteArray;
    UIButton *rightBtn;
    UIButton *exportBtn;
    DDIEmotionView *emtionV;
    OLGhostAlertView *alertTip;
}
@property (nonatomic,strong)id<ReloadNewImageDelegate>delegate;
@property (nonatomic, strong) NSMutableArray* imageArray;
@end
