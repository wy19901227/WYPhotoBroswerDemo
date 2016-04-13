//
//  WYPhotoTransitionAnimator.h
//  YYKitDemo
//
//  Created by 王岩 on 16/4/12.
//  Copyright © 2016年 ibireme. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WYPhotoTransitionAnimator : UIPercentDrivenInteractiveTransition
<UIViewControllerAnimatedTransitioning,UIViewControllerTransitioningDelegate>
-(instancetype)initWithModalVC:(UIViewController*)modalVc;

@property(nonatomic,assign)NSTimeInterval transitionDuration;
@property(nonatomic,assign)BOOL dragable;
@property(nonatomic,assign)CGFloat behindViewScale;
@property(nonatomic,assign)CGFloat behindViewAlpha;


@property(nonatomic,strong)UIView* fromeView;
@property(nonatomic,strong)UIImage* scaleImage;
@property(nonatomic,strong)UIView* toView;

@end
