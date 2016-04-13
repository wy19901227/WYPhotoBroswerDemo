//
//  WYPhotoTransitionAnimator.m
//  YYKitDemo
//
//  Created by 王岩 on 16/4/12.
//  Copyright © 2016年 ibireme. All rights reserved.
//

#import "WYPhotoTransitionAnimator.h"
#import "UIView+YYAdd.h"
#import "CALayer+YYAdd.h"

@interface WYPhotoTransitionAnimator()
@property(nonatomic,assign)BOOL isDismiss;
@property(nonatomic,assign)BOOL isInteractive;
@property(nonatomic,strong)UIViewController* modalVc;
@end
@implementation WYPhotoTransitionAnimator
-(instancetype)initWithModalVC:(UIViewController *)modalVc
{
    if (self=[super init]) {
        _modalVc=modalVc;
        _transitionDuration=.5;
        _behindViewAlpha=.6;
        _behindViewScale=.95;
    }
    return self;
}



#pragma mark - UIViewControllerTransitioningDelegate Methods

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    self.isDismiss = NO;
    return self;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    self.isDismiss = YES;
    return self;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator
{
    return nil;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator
{
    // Return nil if we are not interactive
    if (self.isInteractive && self.dragable) {
        self.isDismiss = YES;
        return self;
    }
    
    return nil;
}



-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return self.transitionDuration;
}
-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController* fromViewController=[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController* toViewController=[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView* containerView=[transitionContext containerView];
    
    if (!self.isDismiss) {
        [containerView addSubview:toViewController.view];
        
        
        CGRect originFrame= self.toView.frame;
        UIImageView* animatorFromView;
        if (self.fromeView.layer.contentsRect.size.height<1) {
            CGRect fromFrame = [self.fromeView convertRect:self.fromeView.bounds toView:self.toView.superview];
    
            CGFloat scale = fromFrame.size.width / self.toView.width;
                self.toView.centerX=CGRectGetMidX(fromFrame);
            self.toView.height=fromFrame.size.height/scale;
            //animateFromImageView.width=fromFrame.size.width
            self.toView.layer.transformScale=scale;
            self.toView.centerY=CGRectGetMidY(fromFrame);
            
            
        }
        
        else
        {
            animatorFromView=[[UIImageView alloc]initWithImage:self.scaleImage];
            
            self.toView.hidden=YES;
            [containerView addSubview:animatorFromView];
            animatorFromView.contentMode=UIViewContentModeScaleAspectFill;
            animatorFromView.clipsToBounds=YES;
            animatorFromView.frame=[toViewController.view convertRect:self.fromeView.frame fromView:self.fromeView.superview];
            

        }

        
        self.fromeView.hidden=YES;
        //self.toView.hidden=YES;
        toViewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        if (toViewController.modalPresentationStyle == UIModalPresentationCustom) {
            [fromViewController beginAppearanceTransition:NO animated:YES];
        }
        
       toViewController.view.backgroundColor=[UIColor colorWithWhite:0 alpha:0];
        
       [UIView animateWithDuration:[self transitionDuration:transitionContext]
                              delay:0
                                options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                            //animateFromImageView.contentMode = UIViewContentModeScaleToFill;
                             fromViewController.view.transform = CGAffineTransformScale(fromViewController.view.transform, self.behindViewScale, self.behindViewScale);
                             fromViewController.view.alpha = self.behindViewAlpha;

                             if (self.fromeView.layer.contentsRect.size.height<1) {
                                 
                                 self.toView.layer.transformScale=1;
                                 self.toView.frame=originFrame;

                             }
                            else
                            {
                                animatorFromView.frame=self.toView.frame;
                            }
            
                           toViewController.view.backgroundColor=[UIColor colorWithWhite:0 alpha:1];

                         } completion:^(BOOL finished) {
                             if (toViewController.modalPresentationStyle == UIModalPresentationCustom) {
                                 [fromViewController endAppearanceTransition];
                             }
                             self.toView.hidden=NO;
                             [animatorFromView removeFromSuperview];
                             [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                         }];
        
    }
    else {
        
        if (fromViewController.modalPresentationStyle == UIModalPresentationFullScreen) {
            [containerView addSubview:toViewController.view];
        }

        [containerView bringSubviewToFront:fromViewController.view];
        
        
        
        if (![self isPriorToIOS8]) {
            toViewController.view.layer.transform = CATransform3DScale(toViewController.view.layer.transform, self.behindViewScale, self.behindViewScale, 1);
        }
        
        toViewController.view.alpha = self.behindViewAlpha;
        CGRect animatorFromViewFrame=[toViewController.view convertRect:self.fromeView.frame fromView:self.fromeView.superview];


        fromViewController.view.backgroundColor=[UIColor colorWithWhite:0 alpha:0];
        
        if (fromViewController.modalPresentationStyle == UIModalPresentationCustom) {
            [toViewController beginAppearanceTransition:YES animated:YES];
        }
        UIImageView* animatorView;
         animatorView=[[UIImageView alloc]initWithImage:self.toView.snapshotImage];
        animatorView.frame=self.toView.frame;
        animatorView.contentMode=UIViewContentModeScaleAspectFill;
        animatorView.clipsToBounds=YES;
        [containerView addSubview:animatorView];
        self.toView.hidden=YES;
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             toViewController.view.alpha=1;
                             
                             if (self.fromeView.layer.contentsRect.size.height<1) {
                                 animatorView.contentMode=UIViewContentModeScaleToFill;
                                 animatorView.layer.contentsRect=CGRectMake(0, 0, 1,self.scaleImage.size.width/self.scaleImage.size.height);
                             }

                                 animatorView.frame=animatorFromViewFrame;
                             
                             CGFloat scaleBack = (1 / self.behindViewScale);
                             toViewController.view.layer.transform = CATransform3DScale(toViewController.view.layer.transform, scaleBack, scaleBack, 1);
                             
                         } completion:^(BOOL finished) {
                             self.fromeView.hidden=NO;
                             [animatorView removeFromSuperview];
                             toViewController.view.layer.transform = CATransform3DIdentity;
                             if (fromViewController.modalPresentationStyle == UIModalPresentationCustom) {
                                 [toViewController endAppearanceTransition];
                             }
                             
                             [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                         }];
    }
    
}


-(void)animationEnded:(BOOL)transitionCompleted
{
    
}

#pragma mark - Utils

- (BOOL)isPriorToIOS8
{
    NSComparisonResult order = [[UIDevice currentDevice].systemVersion compare: @"8.0" options: NSNumericSearch];
    if (order == NSOrderedSame || order == NSOrderedDescending) {
        // OS version >= 8.0
        return YES;
    }
    return NO;
}

@end
