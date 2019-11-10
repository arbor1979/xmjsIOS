//
//  DDScrollViewController.h
//  
//
//  Created by Hirat on 13-11-8.
//
//

#import <UIKit/UIKit.h>

@protocol DDScrollViewDataSource;

@interface DDScrollViewController : UIViewController
{
    CGRect selfFrame;
}
@property (nonatomic, weak) id <DDScrollViewDataSource> dataSource;
@property (nonatomic) NSInteger activeIndex;
- (void)reloadData;
@end


#pragma mark - dataSource
@protocol DDScrollViewDataSource <NSObject>

- (NSUInteger)numberOfViewControllerInDDScrollView:(DDScrollViewController*)DDScrollView;
- (UIViewController *)ddScrollView:(DDScrollViewController*)ddScrollView contentViewControllerAtIndex:(NSUInteger)index;
@optional
-(void)didscrollToNewPage:(NSInteger)pageIndex;
@end
