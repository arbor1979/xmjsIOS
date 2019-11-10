//
//  DDScrollViewController.m
//  
//
//  Created by Hirat on 13-11-8.
//
//

#import "DDScrollViewController.h"
extern NSString *kIOS7;
@interface DDScrollViewController () <UIScrollViewDelegate>
@property UIScrollView *scrollView;
@property NSMutableArray *contents;
@property (nonatomic) CGFloat offsetRadio;
@property (nonatomic) CGFloat margin;

@end

@implementation DDScrollViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initControl];
    
    [self reloadData];
}

- (void)initControl
{
    self.contents = [[NSMutableArray alloc] init];

    _margin=10;
    if(kIOS7)
        selfFrame=CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-self.navigationController.navigationBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height);
    else
        selfFrame=CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-self.navigationController.navigationBar.frame.size.height);
    
    self.scrollView = [[UIScrollView alloc] initWithFrame: CGRectMake(0,0,selfFrame.size.width+_margin,selfFrame.size.height)];
    
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.bounces=YES;
    self.scrollView.alwaysBounceHorizontal=YES;
    self.scrollView.alwaysBounceVertical=NO;
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview: self.scrollView];
}

#pragma mark -

- (void)reloadData
{
    NSArray *subViews = [self.scrollView subviews];
    if([subViews count] != 0)
    {
        [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    [self.contents removeAllObjects];
    
    for (int i = 0; i < 3; i ++)
    {
        if(self.activeIndex==0 && i==0)
            continue;
        else if(self.activeIndex==self.numberOfControllers-1 && i==2)
            continue;
        else
        {
            NSInteger thisPage = [self validIndexValue: self.activeIndex - 1 + i];
            [self.contents addObject:[self.dataSource ddScrollView:self contentViewControllerAtIndex:thisPage]];
            
        }
    }

    
    for (int i = 0; i < self.contents.count; i++)
    {
        UIViewController* viewController = [self.contents objectAtIndex:i];
        UIView* view = viewController.view;
        view.userInteractionEnabled = YES;
        view.frame = selfFrame;
        view.frame = CGRectOffset(selfFrame, (self.scrollView.frame.size.width) * i, 0);
        [self.scrollView addSubview: view];
    }
    
    if(self.activeIndex==0)
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width * self.offsetRadio, 0)];
    
    else
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width+ self.scrollView.frame.size.width * self.offsetRadio, 0)];
    
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.frame) * self.contents.count, 0);
}

- (NSInteger)validIndexValue:(NSInteger)value
{
    if(value == -1)
    {
        value = self.numberOfControllers - 1;
    }
    
    if(value == self.numberOfControllers)
    {
        value = 0;
    }
    
    return value;
}

- (void)setActiveIndex:(NSInteger)activeIndex
{
    if (_activeIndex != activeIndex)
    {
        _activeIndex = activeIndex;
        if ([self.dataSource respondsToSelector:@selector(didscrollToNewPage:)])
            [self.dataSource didscrollToNewPage:_activeIndex];
        [self reloadData];
    }
}

- (NSInteger)numberOfControllers
{
    return [self.dataSource numberOfViewControllerInDDScrollView:self];
}

- (void)setOffsetRadio:(CGFloat)offsetRadio
{
    if (_offsetRadio != offsetRadio)
    {
        _offsetRadio = offsetRadio;
        
        //[self.scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width + self.scrollView.frame.size.width * offsetRadio, 0)];
        if (offsetRadio > 0.5)
        {
            if(self.activeIndex==self.numberOfControllers-1)
                return;
            _offsetRadio = offsetRadio - 1;
           
            self.activeIndex = [self validIndexValue: self.activeIndex + 1];
        }
        
        if (offsetRadio < -0.5)
        {
            if(self.activeIndex==0)
                return;
            _offsetRadio = offsetRadio + 1;
            self.activeIndex = [self validIndexValue: self.activeIndex - 1];
        }
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(self.activeIndex==0)
        self.offsetRadio = (scrollView.contentOffset.x)/CGRectGetWidth(scrollView.frame);
    else
        self.offsetRadio = (scrollView.contentOffset.x)/CGRectGetWidth(scrollView.frame) - 1;
        
}

@end
