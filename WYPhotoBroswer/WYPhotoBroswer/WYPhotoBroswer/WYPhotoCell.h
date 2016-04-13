//
//  WYPhotoCell.h
//  WYPhotoBrowser
//
//  Created by 王岩 on 16/4/11.
//  Copyright © 2016年 wangyan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WYPhotoItem.h"
#import "YYKit.h"
@interface WYPhotoCell : UIScrollView
@property(nonatomic,strong)WYPhotoItem* item;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, strong) YYAnimatedImageView *imageView;
@property (nonatomic, strong) UIView *imageContainerView;
-(void)resizeSubviewSize;
@end
