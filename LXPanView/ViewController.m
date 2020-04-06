//
//  ViewController.m
//  LXPanView
//
//  Created by Kevin on 2020/4/6.
//  Copyright © 2020 SXDC. All rights reserved.
//

#import "ViewController.h"
#import "OtherViewController.h"


static const CGFloat kBottomViewHeight = 240;
static const CGFloat kPreviewViewHeight = 210;
#define WSCREENHEIGHT  [UIScreen mainScreen].bounds.size.height //屏幕高度
#define WSCREENWIDTH   [UIScreen mainScreen].bounds.size.width  //屏幕宽度
#define WisXPhone ((WSCREENHEIGHT == 812.0f || WSCREENHEIGHT == 896.0f) ? 1 : 0)
#define WNavBarHeight (WisXPhone ? 88.0 : 64.0)//nav高度
#define WTabBarHeight (WisXPhone ? 83.0 : 49.0)//tabBar高度
@interface ViewController ()<UIGestureRecognizerDelegate>
@property (nonatomic, strong) OtherViewController *detailController;
@property (nonatomic, strong) UIView *container;
@property (nonatomic, strong) UIPanGestureRecognizer *pan;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupContainer];

}

//创建底部的容器
- (void)setupContainer {
    
    //初始化容器
    self.container = [[UIView alloc] initWithFrame:CGRectMake(0, [self containerOrginY], WSCREENWIDTH, WSCREENHEIGHT-WNavBarHeight-WTabBarHeight+30)];
    self.container.backgroundColor = [UIColor systemPinkColor];
    //创建手势
    self.pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    self.pan.delegate = self;
    [self.container addGestureRecognizer:self.pan];
    
    [self.view addSubview:self.container];
    
    
    CGRect tmprect = CGRectMake(0, 0, WSCREENWIDTH, self.container.bounds.size.height);
    UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:tmprect byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight cornerRadii:CGSizeMake(10, 10)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = tmprect;
    maskLayer.path = path.CGPath;
    self.container.layer.mask = maskLayer;
    self.container.clipsToBounds = YES;
    
    //创建指示器
    UIView *slideView = [[UIView alloc] initWithFrame:CGRectMake((WSCREENWIDTH-35)/2, 10, 35, 6)];
    slideView.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1.0];
    slideView.layer.cornerRadius = 3;
    slideView.layer.masksToBounds = YES;
    [self.container addSubview:slideView];
    
    
    //创建另外一个VC
    self.detailController = [[OtherViewController alloc] init];
    self.detailController.view.alpha = 0;
    [self addChildViewController:self.detailController];
    self.detailController.view.frame = CGRectMake(0, kBottomViewHeight - kPreviewViewHeight, WSCREENWIDTH, self.container.frame.size.height - (kBottomViewHeight - kPreviewViewHeight));
    [self.container addSubview:self.detailController.view];

    
}
//底部s容器的Y坐标
- (CGFloat)containerOrginY {
    
    CGFloat orginY = WSCREENHEIGHT-kBottomViewHeight-WTabBarHeight-WNavBarHeight;
    return orginY;
}

//手势代理事件
- (void)panAction:(UIPanGestureRecognizer *)recognizer {
    
    UIGestureRecognizerState state = [recognizer state];//拿到手势的当前的状态
    //获取手势当前位置，translationInView方法返回的点是手指在坐标系中相对于开始点的偏移量。
    CGPoint translation = [recognizer translationInView:recognizer.view];
    if (state == UIGestureRecognizerStateBegan || state == UIGestureRecognizerStateChanged) {
            [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                if (self.container.frame.origin.y + translation.y <= 0) {
                    return;
                }
                [recognizer.view setTransform:CGAffineTransformTranslate(recognizer.view.transform, 0, translation.y)];
                [self updateAlpha];
            } completion:^(BOOL finished) {
                
            }];
    }else if (state == UIGestureRecognizerStateEnded) {
        CGFloat y;
        if (self.container.frame.origin.y > [self containerOrginY] / 2) {
            y = [self containerOrginY];
        } else {
            y = -30+WNavBarHeight;
//            self.pan.enabled = NO;
        }
        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.container.frame = CGRectMake(0, y, self.container.frame.size.width, self.container.frame.size.height+WNavBarHeight);
            CGRect tmprect = CGRectMake(0, 0, WSCREENWIDTH, self.container.bounds.size.height);
            UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:tmprect byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight cornerRadii:CGSizeMake(10, 10)];
            CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
            maskLayer.frame = tmprect;
            maskLayer.path = path.CGPath;
            self.container.layer.mask = maskLayer;
            self.container.clipsToBounds = YES;
            [self updateAlpha];
        } completion:^(BOOL finished) {
            
        }];
    }
    [recognizer setTranslation:CGPointZero inView:recognizer.view];
}
- (void)updateAlpha {
    CGFloat y = self.container.frame.origin.y;
    CGFloat max = [self containerOrginY] - 100;
    CGFloat min = [self containerOrginY];
    CGFloat alpha = (min - y) / (min - max);
//    self.previewView.alpha = 1 - alpha;
    self.detailController.view.alpha = alpha;
}
- (UIView *)container {
    if (!_container) {
        _container = [[UIView alloc] init];
        _container.backgroundColor = [UIColor whiteColor];
    }
    return _container;
}

@end
