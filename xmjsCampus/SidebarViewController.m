//
//  ViewController.m
//  SideBarNavDemo
//
//  Created by JianYe on 12-12-11.
//  Copyright (c) 2012年 JianYe. All rights reserved.
//

#import "SidebarViewController.h"
#import <QuartzCore/QuartzCore.h>

extern Boolean kIOS7;

@interface SidebarViewController ()
{
    UIViewController  *_currentMainController;
    UITapGestureRecognizer *_tapGestureRecognizer;
    UIPanGestureRecognizer *_panGestureReconginzer;
    BOOL sideBarShowing;
    CGFloat currentTranslate;
}
@property (strong,nonatomic)DDIMainMenu *leftSideBarViewController;

@end

@implementation SidebarViewController
@synthesize leftSideBarViewController,contentView,navBackView;

static SidebarViewController *rootViewCon;
const int ContentOffset=460;
const int ContentMinOffset=60;
const float MoveAnimationDuration = 0.3;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

+ (id)share
{
    return rootViewCon;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (rootViewCon) {
        rootViewCon = nil;
    }
	rootViewCon = self;
    
    sideBarShowing = NO;
    currentTranslate = 0;
    if(kIOS7)
        self.edgesForExtendedLayout=UIRectEdgeNone;
    self.contentView.layer.shadowOffset = CGSizeMake(0, 0);
    self.contentView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.contentView.layer.shadowOpacity = 1;

    DDIMainMenu *_leftCon = [self.storyboard instantiateViewControllerWithIdentifier:@"leftMenu"];
    
    self.leftSideBarViewController = _leftCon;

    [self addChildViewController:self.leftSideBarViewController];
   
    [self.navBackView addSubview:self.leftSideBarViewController.view];
    
    mainTabBar=[self.storyboard instantiateViewControllerWithIdentifier:@"mainView"];
    [self addChildViewController:mainTabBar];
    
    [self.contentView addSubview:mainTabBar.view];
    
    _panGestureReconginzer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panInContentView:)];
    _tapGestureRecognizer = [[UITapGestureRecognizer  alloc] initWithTarget:self action:@selector(tapOnContentView:)];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navBackView.frame=self.view.bounds;
    self.leftSideBarViewController.view.frame=self.navBackView.bounds;
    self.contentView.frame=self.view.frame;
    self.contentView.backgroundColor=[UIColor redColor];
    mainTabBar.view.frame=self.contentView.frame;
    [self.view bringSubviewToFront:self.contentView];
    
    if(sideBarShowing)
    {
        //[self moveAnimationWithDirection:SideBarShowDirectionLeft duration:MoveAnimationDuration];
    }
}
-(void) mainMenuAction
{
    //[self performSegueWithIdentifier:@"gotoMenu" sender:nil];
    if(sideBarShowing)
        [self moveAnimationWithDirection:SideBarShowDirectionNone duration:MoveAnimationDuration];
    else
        [self moveAnimationWithDirection:SideBarShowDirectionLeft duration:MoveAnimationDuration];
}
- (void)contentViewAddTapGestures
{
    if (_tapGestureRecognizer) {
        [self.contentView removeGestureRecognizer:_tapGestureRecognizer];
        [self.contentView addGestureRecognizer:_tapGestureRecognizer];
    }
    
    if(_panGestureReconginzer)
    {
       [self.contentView removeGestureRecognizer:_panGestureReconginzer];
       [self.contentView addGestureRecognizer:_panGestureReconginzer];
    }
}

- (void)tapOnContentView:(UITapGestureRecognizer *)tapGestureRecognizer
{
    [self moveAnimationWithDirection:SideBarShowDirectionNone duration:MoveAnimationDuration];
}

- (void)panInContentView:(UIPanGestureRecognizer *)panGestureReconginzer
{

	if (panGestureReconginzer.state == UIGestureRecognizerStateChanged)
    {
        CGFloat translation = [panGestureReconginzer translationInView:self.contentView].x;
        if(translation+currentTranslate>0)
            self.contentView.transform = CGAffineTransformMakeTranslation(translation+currentTranslate, 0);
       
   
        
	} else if (panGestureReconginzer.state == UIGestureRecognizerStateEnded)
    {
		currentTranslate = self.contentView.transform.tx;
        if (!sideBarShowing) {
            if (fabs(currentTranslate)<ContentMinOffset) {
                [self moveAnimationWithDirection:SideBarShowDirectionNone duration:MoveAnimationDuration];
            }else if(currentTranslate>ContentMinOffset)
            {
                [self moveAnimationWithDirection:SideBarShowDirectionLeft duration:MoveAnimationDuration];
            }else
            {
                [self moveAnimationWithDirection:SideBarShowDirectionRight duration:MoveAnimationDuration];
            }
        }else
        {
            if (fabs(currentTranslate)<ContentOffset-ContentMinOffset) {
                [self moveAnimationWithDirection:SideBarShowDirectionNone duration:MoveAnimationDuration];
            
            }else if(currentTranslate>ContentOffset-ContentMinOffset)
            {
                
                [self moveAnimationWithDirection:SideBarShowDirectionLeft duration:MoveAnimationDuration];
                            
            }else
            {
                [self moveAnimationWithDirection:SideBarShowDirectionRight duration:MoveAnimationDuration];
            }
        }
        
        
	}
    
   
}

#pragma mark - tabbar con delegate
-(void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    if([viewController isKindOfClass:[DDIClassSchedule class]])
        [self removepanGestureReconginzerWhileNavConPushed:YES];
    else
        [self removepanGestureReconginzerWhileNavConPushed:NO];
}


- (void)removepanGestureReconginzerWhileNavConPushed:(BOOL)push
{
    if (push) {
        if (_panGestureReconginzer) {
            [self.contentView removeGestureRecognizer:_panGestureReconginzer];
            _panGestureReconginzer = nil;
        }
    }else
    {
        if (!_panGestureReconginzer) {
            _panGestureReconginzer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panInContentView:)];
            [self.contentView addGestureRecognizer:_panGestureReconginzer];
        }
    }
}


- (void)showSideBarControllerWithDirection:(SideBarShowDirection)direction
{
    
    [self moveAnimationWithDirection:direction duration:MoveAnimationDuration];
}



#pragma animation

- (void)moveAnimationWithDirection:(SideBarShowDirection)direction duration:(float)duration
{
    void (^animations)(void) = ^{
        
		switch (direction) {
            case SideBarShowDirectionNone:
            {
                self.contentView.transform  = CGAffineTransformMakeTranslation(0, 0);
            }
                break;
            case SideBarShowDirectionLeft:
            {
                
                self.contentView.transform  = CGAffineTransformMakeTranslation(ContentOffset, 0);
            }
                break;
            
            default:
                break;
        }
	};
    void (^complete)(BOOL) = ^(BOOL finished) {
        self.contentView.userInteractionEnabled = YES;
        self.navBackView.userInteractionEnabled = YES;
        
        if (direction == SideBarShowDirectionNone) {
           
            if (_tapGestureRecognizer) {
                [self.contentView removeGestureRecognizer:_tapGestureRecognizer];
                [self.contentView removeGestureRecognizer:_panGestureReconginzer];
            }
            sideBarShowing = NO;
            
            
        }else
        {
            [self contentViewAddTapGestures];
             sideBarShowing = YES;
        }
        currentTranslate = self.contentView.transform.tx;
	};
    self.contentView.userInteractionEnabled = NO;
    self.navBackView.userInteractionEnabled = NO;
    if(direction==SideBarShowDirectionNone)
        self.contentView.transform = CGAffineTransformMakeTranslation(0, 0);
    else
        self.contentView.transform = CGAffineTransformMakeTranslation(ContentOffset, 0);
    [UIView animateWithDuration:duration animations:animations completion:complete];
    
}

@end
