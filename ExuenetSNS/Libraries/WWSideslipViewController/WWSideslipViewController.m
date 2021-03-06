//
//  WWSideslipViewController.m
//  ExuenetSNS
//
//  Created by Cao JianRong on 15-1-28.
//  Copyright (c) 2015年 Cao JianRong. All rights reserved.
//
//  版权属于原作者

#import "WWSideslipViewController.h"

@interface WWSideslipViewController ()

@end

@implementation WWSideslipViewController
@synthesize speedf,sideslipTapGes;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(instancetype)initWithLeftView:(UIViewController *)LeftView
                    andMainView:(UIViewController *)MainView
                   andRightView:(UIViewController *)RighView
                        andBackgroundImage:(UIImage *)image;
{
    if(self)
    {
        speedf = 0.5;
        
        mainControl = MainView;
        leftControl = LeftView;
        righControl = RighView;
        leftControl.view.hidden = YES;
        righControl.view.hidden = YES;
        
        UIImageView * imgview = [[UIImageView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        [imgview setImage:image];
        [self.view addSubview:imgview];
        
        [self.view addSubview:leftControl.view];
        [self.view addSubview:righControl.view];
        [self.view addSubview:mainControl.view];
        
    
        //滑动手势
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
        [mainControl.view addGestureRecognizer:pan];
        
        //单击手势
        sideslipTapGes= [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handeTap:)];
        [sideslipTapGes setNumberOfTapsRequired:1];
        sideslipTapGes.delegate = self;
        
        status = WWMenuStatusCenterOpen;
    }
    return self;
}

#pragma mark - 滑动手势
- (void) handlePan: (UIPanGestureRecognizer *)rec{
    
    CGPoint point = [rec translationInView:self.view];
    
    scalef = (point.x*speedf+scalef);

    //根据视图位置判断是左滑还是右边滑动
    if (rec.view.frame.origin.x > 0) {
        rec.view.center = CGPointMake(rec.view.center.x + point.x*speedf,rec.view.center.y);
        rec.view.transform = CGAffineTransformScale(CGAffineTransformIdentity,1-scalef/1000,1-scalef/1000);
        [rec setTranslation:CGPointMake(0, 0) inView:self.view];
        
        righControl.view.hidden = YES;
        leftControl.view.hidden = NO;
    } else {
//        NSLog(@"右划");
//        rec.view.center = CGPointMake(rec.view.center.x + point.x*speedf,rec.view.center.y);
//        rec.view.transform = CGAffineTransformScale(CGAffineTransformIdentity,1+scalef/1000,1+scalef/1000);
//        [rec setTranslation:CGPointMake(0, 0) inView:self.view];
//    
//        righControl.view.hidden = NO;
//        leftControl.view.hidden = YES;
    }

    //手势结束后修正位置
    if (rec.state == UIGestureRecognizerStateEnded) {
        if (scalef > 140*speedf){
            [self showLeftView];
        } else if (scalef < -140*speedf) {
//            [self showRighView];
        } else {
            [self showMainView];
            scalef = 0;
        }
    }
}

#pragma mark - 单击手势，手离开屏幕，中间视图回复正常状态
-(void)handeTap:(UITapGestureRecognizer *)tap
{
    if (tap.state == UIGestureRecognizerStateEnded) {
        [UIView beginAnimations:nil context:nil];
        tap.view.transform = CGAffineTransformScale(CGAffineTransformIdentity,1.0,1.0);
        tap.view.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2,[UIScreen mainScreen].bounds.size.height/2);
        [UIView commitAnimations];
        scalef = 0;
        status = WWMenuStatusCenterOpen;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (status == WWMenuStatusCenterOpen) {
        return NO;
    }
    if ( [touch.view isKindOfClass:[UINavigationBar class]] ||
          [touch.view isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
        //防止截获导航栏返回按钮的返回事件
        return NO;
    }
    return YES;
}

#pragma mark - 修改视图位置
//恢复位置
-(void)showMainView
{
    status = WWMenuStatusCenterOpen;
    [UIView beginAnimations:nil context:nil];
    mainControl.view.transform = CGAffineTransformScale(CGAffineTransformIdentity,1.0,1.0);
    mainControl.view.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2,[UIScreen mainScreen].bounds.size.height/2);
    [mainControl.view removeGestureRecognizer:sideslipTapGes];
    [UIView commitAnimations];
}

//显示左视图
-(void)showLeftView
{
    status = WWMenuStatusLeftOpen;
    [UIView beginAnimations:nil context:nil];
    mainControl.view.transform = CGAffineTransformScale(CGAffineTransformIdentity,0.8,0.8);
    mainControl.view.center = CGPointMake(340,[UIScreen mainScreen].bounds.size.height/2);
    [mainControl.view addGestureRecognizer:sideslipTapGes];
    NSLog(@"%@",NSStringFromCGRect(mainControl.view.frame));
    [UIView commitAnimations];
}

//显示右视图
-(void)showRighView
{
    status = WWMenuStatusRightOpen;
    [UIView beginAnimations:nil context:nil];
    mainControl.view.transform = CGAffineTransformScale(CGAffineTransformIdentity,0.8,0.8);
    mainControl.view.center = CGPointMake(-60,[UIScreen mainScreen].bounds.size.height/2);
    [UIView commitAnimations];
}

#pragma mark - 为了界面美观，所以隐藏了状态栏。如果需要显示则去掉此代码
- (BOOL)prefersStatusBarHidden
{
    return YES; //返回NO表示要显示，返回YES将hiden
}

@end
