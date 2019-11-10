//
//  WaterF.m
//  CollectionView
//
//  Created by d2space on 14-2-21.
//  Copyright (c) 2014年 D2space. All rights reserved.
//

#import "WaterF.h"
//#import "WaterFLayout.h"
#import "WaterFCell.h"
#import "WaterFallHeader.h"
#import "WaterFallFooter.h"
extern Boolean kIOS7;
@interface WaterF ()

@property (nonatomic, strong) WaterFCell* cell;
@end

@implementation WaterF

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithCollectionViewLayout:layout];
    if (self)
    {
        [self.collectionView registerClass:[WaterFCell class] forCellWithReuseIdentifier:@"cell"];
        /*
        [self.collectionView registerClass:[WaterFallFooter class]  forSupplementaryViewOfKind:WaterFallSectionFooter withReuseIdentifier:@"WaterFallSectionfooter"];
        [self.collectionView registerClass:[WaterFallHeader class]  forSupplementaryViewOfKind:WaterFallSectionHeader withReuseIdentifier:@"WaterFallSectionHeader"];
         */
    }
    savepath=[CommonFunc createPath:@"/utils/"];
    if (_refreshHeaderView == nil) {
        
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.collectionView.bounds.size.height, self.view.frame.size.width, self.collectionView.bounds.size.height)];
        view.delegate = self;
        [self.collectionView addSubview:view];
        _refreshHeaderView = view;
        
    }
    self.collectionView.backgroundColor=[UIColor colorWithRed:228/255.0 green:244/255.0 blue:234/255.0 alpha:1];
    return self;
}

- (void)loadImagetData:(NSString *)URLPath filename:(NSString *)filename indexPath:(NSIndexPath *)indexPath
{
    // Request
    
    NSURL *URL = [NSURL URLWithString:URLPath];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        NSInteger responseCode = [(NSHTTPURLResponse *)response statusCode];
        
        if (!error && responseCode == 200)
        {
            UIImage *headImage=[[UIImage alloc]initWithData:data];
            if(headImage!=nil)
            {
                [data writeToFile:filename atomically:YES];
                [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
                //NSLog(@"图片下载成功,%@",[CommonFunc getFileRealName:filename]);
            }
        }
        else
            NSLog(@"图片下载失败");
    }];
}
#pragma mark UICollectionViewDataSource
//required
-(NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.sectionNum;
}

/* For now, we won't return any sections */
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{

    return self.imagesArr.count;;
   
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* identifier = @"cell";
    self.cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    CGFloat aFloat = 0;
    NSDictionary *data = [self.imagesArr objectAtIndex:indexPath.item];
    UIImage* image;
    NSString *iconName=[data objectForKey:@"文件名"];
    NSString *filename=[savepath stringByAppendingString:iconName];
    if([CommonFunc fileIfExist:filename])
    {
        image=[UIImage imageWithContentsOfFile:filename];
    }
    else
    {
        NSString *urlStr=[data objectForKey:@"文件地址"];
        [self loadImagetData:urlStr filename:filename indexPath:indexPath];
        image=[UIImage imageNamed:@"empty_photo"];
    }
    aFloat = self.imagewidth/image.size.width;
    self.cell.imageView.frame = CGRectMake(0, 0, self.imagewidth,  image.size.height*aFloat) ;
    self.cell.btnView.frame=self.cell.imageView.frame;
    self.cell.btnView.tag=indexPath.row;
    [self.cell.btnView addTarget:self action:@selector(gotoScrollPage:) forControlEvents:UIControlEventTouchUpInside];
    //[self getTextViewHeight:indexPath];
    self.cell.textView.frame = CGRectMake(0, image.size.height*aFloat-1, self.imagewidth, self.textViewHeight);
    
    self.cell.imageView.image = image;
    NSString *showText=[NSString stringWithFormat:@" %@ %@",[data objectForKey:@"发布人"],[data objectForKey:@"班级"]];
    self.cell.textView.text = showText;
    NSNumber *praiseCount=[data objectForKey:@"被赞次数"];
    if(praiseCount!=nil && praiseCount.intValue>0)
    {
        self.cell.lbPraiseCount.text=[NSString stringWithFormat:@"%d ",praiseCount.intValue];
        [self.cell.lbPraiseCount sizeToFit];
        CGFloat imageWidth=9;
        CGFloat imageHeight=8.5;
        CGFloat lbwidth=self.cell.lbPraiseCount.frame.size.width+imageWidth+3;
        CGFloat lbheight=14;
        CGFloat lbleft=(int)self.imagewidth-10-lbwidth;
        CGFloat lbtop=5;
        CGFloat imagetop=5+(lbheight-imageHeight)/2;
        CGFloat imageleft=lbleft+3;
        if(kIOS7)
            self.cell.lbPraiseCount.frame=CGRectMake(lbleft, lbtop, lbwidth, lbheight);
        else
            self.cell.lbPraiseCount.frame=CGRectMake(lbleft+2.5, lbtop-0.5, lbwidth, lbheight);
        self.cell.lbPraiseBg.frame=CGRectMake(lbleft, lbtop, lbwidth+3, lbheight);
        self.cell.imageHeart.frame=CGRectMake(imageleft, imagetop, imageWidth, imageHeight);
    }
    else
    {
        self.cell.lbPraiseCount.frame=CGRectZero;
        self.cell.imageHeart.frame=CGRectZero;
        self.cell.lbPraiseBg.frame=CGRectZero;
    }
    return self.cell;
}
-(void)gotoScrollPage:(UIButton *)sender
{
    int row=(int)sender.tag;
    if ([self.delegate respondsToSelector:@selector(cellOnClick:)])
    {
        [self.delegate cellOnClick:row];
    }
    
}
/*
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}
 */
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
#pragma mark - UICollectionView Delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //select Item
    
}
#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat aFloat = 0;
    NSDictionary *data = [self.imagesArr objectAtIndex:indexPath.item];
    UIImage* image;
    NSString *iconName=[data objectForKey:@"文件名"];
    NSString *filename=[savepath stringByAppendingString:iconName];
    if([CommonFunc fileIfExist:filename])
    {
        image=[UIImage imageWithContentsOfFile:filename];
    }
    else
    {
        image=[UIImage imageNamed:@"empty_photo"];
    }
    aFloat = self.imagewidth/image.size.width;
     //CGSize size = CGSizeMake(0,0);
    //[self getTextViewHeight:indexPath];
     CGSize size = CGSizeMake(self.imagewidth, image.size.height*aFloat+self.textViewHeight-1);
    return size;
}

- (CGFloat)getTextViewHeight:(NSIndexPath*)indexPath
{
    NSDictionary *data = [self.imagesArr objectAtIndex:indexPath.item];
    NSString *showText=[NSString stringWithFormat:@"%@ %@",[data objectForKey:@"发布人"],[data objectForKey:@"班级"]];
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:showText];
    UITextView* textViewTemple = [[UITextView alloc]init];
    textViewTemple.attributedText = attrStr;
    textViewTemple.text = showText;
    NSRange range = NSMakeRange(0, attrStr.length);
    NSDictionary *dic = [attrStr attributesAtIndex:0 effectiveRange:&range];   // 获取该段attributedString的属性字典
    // 计算文本的大小  ios7.0
    CGSize textSize = [textViewTemple.text boundingRectWithSize:CGSizeMake(self.imagewidth, MAXFLOAT) // 用于计算文本绘制时占据的矩形块
                                                        options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading // 文本绘制时的附加选项
                                                     attributes:dic        // 文字的属性
                                                        context:nil].size;
    self.textViewHeight = textSize.height;
    return self.textViewHeight;
}

#pragma mark ADD Header AND Footer
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout heightForFooterInSection:(NSInteger)section
{
    return 0;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout heightForHeaderInSection:(NSInteger)section
{
    return 0;
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableView = nil;
    NSString *text = nil;
    if ([kind isEqualToString:WaterFallSectionHeader])
    {
        reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                          withReuseIdentifier:@"WaterFallSectionHeader"
                                                                 forIndexPath:indexPath];
        WaterFallHeader* header = [[WaterFallHeader alloc]init];
        header.label.text = [NSString stringWithFormat:@"Header %ld",(long)indexPath.section];
        header.imageView.backgroundColor = [UIColor grayColor];
        [reusableView addSubview:header];
        
    }
    else if ([kind isEqualToString:WaterFallSectionFooter])
    {
        reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                          withReuseIdentifier:@"WaterFallSectionfooter"
                                                                 forIndexPath:indexPath];
        UIView* backgroundView = [[UIView alloc]init];
        backgroundView.backgroundColor = [UIColor cyanColor];
        backgroundView.frame = CGRectMake(0, 0, 320, 40);
        [reusableView addSubview:backgroundView];
        
        text = [NSString stringWithFormat:@"Footer %ld",(long)indexPath.section];
        reusableView.backgroundColor = [UIColor darkGrayColor];
        UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 320, 40)];
        label.text = text;
        [reusableView addSubview:label];
    }
    
    return reusableView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    
}
#pragma mark EGORefreshTableHeaderDelegate Methods
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    _reloading = YES;
    if ([self.delegate respondsToSelector:@selector(reloadNewAlbumData)])
    {
        [self.delegate reloadNewAlbumData];
    }
    
}
- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
    
    return _reloading; // should return if data source model is reloading
    
}

- (void)doneLoadingTableViewData:(NSNumber *)newcount
{
    
    //  model should call this when its done loading
    _reloading = NO;
    if(newcount>0)
    {
        [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.collectionView];
        [self.collectionView reloadData];
    }
    
}
@end
