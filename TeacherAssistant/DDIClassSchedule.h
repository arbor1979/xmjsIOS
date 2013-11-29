//
//  DDIClassSchedule.h
//  TeacherAssistant
//
//  Created by yons on 13-11-13.
//  Copyright (c) 2013年 dandian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DDIClassSchedule : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *bgImage;

@property (weak, nonatomic) IBOutlet UIView *topBarView;
@property (weak, nonatomic) IBOutlet UIView *leftBarView;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (strong,nonatomic) UIPanGestureRecognizer *panGestureRecognizer;

-(void) moveView:(UIView *)view direct:(UISwipeGestureRecognizerDirection)direction rect:(CGRect) orgRect;
-(void) mainMenuAction;
-(void) drawClassRect:(NSDictionary *)classInfo index:(NSInteger)i;
@end
