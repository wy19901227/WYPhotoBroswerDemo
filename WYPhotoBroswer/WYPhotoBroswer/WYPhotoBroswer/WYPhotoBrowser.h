//
//  WYPhotoBrowser.h
//  WYPhotoBrowser
//
//  Created by 王岩 on 16/4/12.
//  Copyright © 2016年 wangyan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WYPhotoTransitionAnimator.h"
#import "WYPhotoView.h"
@interface WYPhotoBrowser : UIViewController

@property(nonatomic,strong)WYPhotoTransitionAnimator* animator;

- (id)initWithPhotos:(NSArray *)photosArray animatedFromView:(UIView*)view;
@end
