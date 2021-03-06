//
//  AKTViewController.m
//  Pursue
//
//  Created by YaHaoo on 16/4/6.
//  Copyright © 2016年 YaHaoo. All rights reserved.
//

#import "AKTViewController.h"
#import "AKTPublic.h"
#import "AKTDismissVCAnimation.h"
#import "AKTPresentVCAnimation.h"
#import "AKTInteractiveDismiss.h"
#import "UIView+AKTLayout.h"
#import "objc/runtime.h"

//--------------------Structs statement, globle variables...--------------------
static const char *observer = "observer";
//-------------------- E.n.d -------------------->Structs statement, globle variables...
@interface AKTViewController ()
@property (strong, nonatomic) AKTPresentVCAnimation *pAnimation;
@property (strong, nonatomic) AKTDismissVCAnimation *dAnimation;
@property (strong, nonatomic) AKTInteractiveDismiss *interactiveDismiss;
@end
@implementation AKTViewController
#pragma mark - life cycle
//|---------------------------------------------------------
- (void)viewDidLoad {
    [super viewDidLoad];
    // Don't adjust scrollView inset automatically.
    // 不自动调整scrollview插入值
    self.automaticallyAdjustsScrollViewInsets = NO;
    // Add observer for layout event.

    self.transitioningDelegate = self;
    _interactiveDismiss = self.interactiveDismiss;
    // Setup naviBar
    _naviBar = self.naviBar;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.navigationController && ![self.navigationController.viewControllers containsObject:self]) {
        [self viewControllerPoped];
    }
}

- (void)dealloc
{
    if (objc_getAssociatedObject(self, observer)) {
        [self.view removeObserver:self forKeyPath:@"frame"];
    }
}
#pragma mark - property settings
//|---------------------------------------------------------
- (void)setInteractiveGestureEnable:(BOOL)interactiveGestureEnable {
    _interactiveGestureEnable = interactiveGestureEnable;
    self.interactiveDismiss.userInterfaceInteractive = interactiveGestureEnable;
}

#pragma mark - view methods
//|---------------------------------------------------------
/*
 * Subviews need layout.
 */
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.naviBar.width = self.view.width;
    if (self.view.width>self.view.height) {
        self.naviBar.height = 44;
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }else{
        self.naviBar.height = 64;
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }
    [self.naviBar aktLayoutUpdate];
}


/*
 * Current view controller was poped
 */
- (void)viewControllerPoped {
    
}
#pragma mark - view settings
//|---------------------------------------------------------
/*
 * 旋转屏幕之后返回上一个界面时需要手动设置一下界面，有可能进入前和退出时方向时不一致的
 */
- (void)orientation:(UIInterfaceOrientation)toInterfaceOrientation {
    CGFloat width = mAKT_Device_Width;
    CGFloat height = mAKT_Device_Height;
    switch (toInterfaceOrientation) {
        case UIInterfaceOrientationPortrait:
            self.view.frame = CGRectMake(0, 0, width, height);
            break;
        case UIInterfaceOrientationLandscapeLeft: case UIInterfaceOrientationLandscapeRight:
            self.view.frame = CGRectMake(0, 0, height, width);
            break;
        default:
            break;
    }
}
#pragma mark - property settings
//|---------------------------------------------------------
- (AKTPresentVCAnimation *)pAnimation {
    if (_pAnimation == nil) {
        _pAnimation = [AKTPresentVCAnimation new];
    }
    return _pAnimation;
}

- (AKTDismissVCAnimation *)dAnimation {
    if (_dAnimation == nil) {
        _dAnimation = [AKTDismissVCAnimation new];
    }
    return _dAnimation;
}

- (AKTInteractiveDismiss *)interactiveDismiss {
    if (_interactiveDismiss == nil) {
        _interactiveDismiss = [[AKTInteractiveDismiss alloc]initWithViewController:self];
    }
    return _interactiveDismiss;
}

- (AKTNavigationBar *)naviBar {
    if (_naviBar == nil) {
        _naviBar = [AKTNavigationBar new];
        [self.view addSubview:_naviBar];
    }
    return _naviBar;
}
#pragma mark - delegate
//|---------------------------------------------------------
- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return self.pAnimation;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return self.dAnimation;
}

- (nullable id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator {
    return self.interactiveDismiss.isInteracting? self.interactiveDismiss:nil;
}
@end
