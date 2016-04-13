
//
//  WYPhotoBrowser.m
//  WYPhotoBrowser
//
//  Created by 王岩 on 16/4/12.
//  Copyright © 2016年 wangyan. All rights reserved.
//

#import "WYPhotoBrowser.h"
#import "WYPhotoView.h"


@interface WYPhotoBrowser ()<WYPhotoViewDelegate,UIGestureRecognizerDelegate>
@property(nonatomic,strong)WYPhotoView* photoView;
@property(nonatomic,strong)NSArray* photoArray;
@property(nonatomic,strong)UIView* fromView;

@property(nonatomic,strong)UIPanGestureRecognizer* panGesture;

@end

@implementation WYPhotoBrowser
-(id)initWithPhotos:(NSArray *)photosArray animatedFromView:(UIView *)view
{
    if (self=[super init]) {
        _photoArray=[NSArray arrayWithArray:photosArray];
        _fromView=view;
        _photoView=[[WYPhotoView alloc]initWithItems:_photoArray fromView:_fromView];
        
        _photoView.delegate=self;
        
        self.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
        self.modalPresentationStyle=UIModalPresentationCustom;
        _animator=[[WYPhotoTransitionAnimator alloc]initWithModalVC:self];

        _animator.fromeView=view;
        _animator.scaleImage=((UIImageView*)view).image;
        _animator.toView=_photoView.toImageView;
        self.transitioningDelegate=_animator;
        
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:_photoView];

    
    //panGesture
    _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
    _panGesture.delegate=self;
    [_panGesture setMinimumNumberOfTouches:1];
    [_panGesture setMaximumNumberOfTouches:1];
    [self.photoView addGestureRecognizer:_panGesture];

    
    
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _photoView.isPresented=YES;
    [_photoView scrollViewDidScroll:_photoView.scrollView];
    
    
}


- (void)panGestureRecognized:(UIPanGestureRecognizer*)sender {
    // Initial Setup
    UIView *scrollView = self.photoView.toImageView;
    
   // scrollView.pager.hidden=YES;
    static float firstX, firstY;
    
    float viewHeight = [UIScreen mainScreen].bounds.size.height;
    float viewHalfHeight = viewHeight/2;
    
    CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender  translationInView:self.view];
    // Gesture Began
    if ([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {

        
        firstX = [scrollView center].x;
        firstY = [scrollView center].y;
        

        
        [self setNeedsStatusBarAppearanceUpdate];
    }
    
    translatedPoint = CGPointMake(firstX+ translatedPoint.x, firstY+translatedPoint.y);
    [scrollView setCenter:translatedPoint];
    
    float newY = scrollView.center.y - viewHalfHeight;
    float newAlpha = 1 - fabsf(newY)/viewHeight*1.8; //abs(newY)/viewHeight * 1.8;
    
    self.view.opaque = YES;
    
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:newAlpha];
            //    NSLog(@"%f--%f",scrollView.center.y,viewHalfHeight+80);
    // Gesture Ended
    if ([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
        if(scrollView.center.y > viewHalfHeight+80 || scrollView.center.y < viewHalfHeight-80) // Automatic Dismiss View
        {


            self.animator.behindViewAlpha=newAlpha;
            [self dismissViewControllerAnimated:YES completion:nil];
            
        }
        else // Continue Showing View
        {
            
            [self setNeedsStatusBarAppearanceUpdate];
            
            self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
            
            CGFloat velocityY = (.35*[(UIPanGestureRecognizer*)sender velocityInView:self.view].y);
            
            CGFloat finalX = firstX;
            CGFloat finalY = viewHalfHeight;
            
            CGFloat animationDuration = (ABS(velocityY)*.0002)+.2;
            
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:animationDuration];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
            [UIView setAnimationDelegate:self];
            [scrollView setCenter:CGPointMake(finalX, finalY)];
           // scrollView.pager.hidden=NO;
            [UIView commitAnimations];
        }
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)WYPhotoViewDidLongPress:(WYPhotoView *)photoView
{
    NSLog(@"longTap");
    
}
-(void)WYphotoCellScrollToIndex:(NSInteger)index
{
    WYPhotoItem* item=(WYPhotoItem*)self.photoView.items[index];
    
    self.animator.fromeView.hidden=NO;
    self.animator.fromeView=item.thumbView;
    self.animator.toView=self.photoView.toImageView;
    self.animator.fromeView.hidden=YES;

}


#pragma mark gestureDelegate
-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint translatedPoint = [(UIPanGestureRecognizer*)gestureRecognizer  translationInView:self.view];
    if (translatedPoint.y==0) {
        return NO;
    }
    return YES;
}
@end
