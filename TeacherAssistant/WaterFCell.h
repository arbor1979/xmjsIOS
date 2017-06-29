//
//  WaterFCell.h
//  CollectionView
//
//  Created by d2space on 14-2-26.
//  Copyright (c) 2014年 D2space. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WaterFCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView* imageView;
@property (nonatomic, strong) UILabel* textView;
@property (nonatomic, strong) UIButton* btnView;

@property (nonatomic, strong) UIImageView* imageHeart;
@property (nonatomic, strong) UILabel* lbPraiseCount;
@property (nonatomic, strong) UILabel* lbPraiseBg;
//- (void)configureCellWithIndexPath:(NSIndexPath *)indexPath;

@end
