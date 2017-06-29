//
//  WaterFCell.m
//  CollectionView
//
//  Created by d2space on 14-2-26.
//  Copyright (c) 2014年 D2space. All rights reserved.
//

#import "WaterFCell.h"

@implementation WaterFCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
//        self.contentView.layer.cornerRadius = 5.0;
//        self.contentView.layer.borderWidth = 1.0f;
//        self.contentView.layer.borderColor = [UIColor whiteColor].CGColor;
        [self setup];
    }
    return self;
}
#pragma mark - Setup
- (void)setup
{
    
    [self setupTextView];
    [self setupView];
}

- (void)setupView
{
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,0,0)];
    /*
    self.imageView.layer.cornerRadius = 5;
    self.imageView.layer.masksToBounds = YES;
    self.imageView.layer.borderColor = [UIColor brownColor].CGColor;
    self.imageView.layer.borderWidth = 2;
    self.imageView.backgroundColor = [UIColor greenColor];
     */
    [self addSubview:self.imageView];
    self.btnView=[[UIButton alloc] initWithFrame:CGRectZero];
    [self addSubview:self.btnView];
    
    
    
    self.lbPraiseBg=[[UILabel alloc]initWithFrame:CGRectZero];
    self.lbPraiseBg.layer.cornerRadius = 7;
    self.lbPraiseBg.layer.masksToBounds = YES;
    self.lbPraiseBg.backgroundColor=[UIColor colorWithRed:25/255.0 green:25/255.0 blue:25/255.0 alpha:0.6];
    //self.lbPraiseBg.backgroundColor=[UIColor darkGrayColor];
    //self.lbPraiseBg.alpha=0.7;
    [self addSubview:self.lbPraiseBg];
    
    self.lbPraiseCount=[[UILabel alloc]initWithFrame:CGRectZero];
    self.lbPraiseCount.textAlignment=NSTextAlignmentRight;
    self.lbPraiseCount.font=[UIFont systemFontOfSize:10];
    self.lbPraiseCount.textColor=[UIColor whiteColor];
    self.lbPraiseCount.backgroundColor=[UIColor clearColor];
    [self addSubview:self.lbPraiseCount];
    
    self.imageHeart=[[UIImageView alloc] initWithFrame:CGRectZero];
    self.imageHeart.image=[UIImage imageNamed:@"fill_heart_white"];
    [self addSubview:self.imageHeart];
}

- (void)setupTextView
{
    self.textView = [[UILabel alloc] initWithFrame:CGRectMake(0,0,0,0)];
    /*
    self.textView.layer.cornerRadius = 5;
    self.textView.layer.masksToBounds = YES;
     */
    self.textView.layer.borderColor = [UIColor blackColor].CGColor;
    self.textView.layer.borderWidth = 0.5f;
    self.textView.font=[UIFont systemFontOfSize:9];
    self.textView.backgroundColor=[UIColor whiteColor];
    /*
    self.textView.layer.shadowColor=[UIColor grayColor].CGColor;
    self.textView.layer.shadowOffset=CGSizeMake(2,2);
    self.textView.layer.shadowOpacity=0.8;
    self.textView.layer.shadowRadius=2.0;
    
     */
    [self addSubview:self.textView];
}

//#pragma mark - Configure
//- (void)configureCellWithIndexPath:(NSIndexPath *)indexPath
//{
//    self.textView.text = [NSString stringWithFormat:@"Cell %ld", (long)(indexPath.row + 1)];
//}

@end
