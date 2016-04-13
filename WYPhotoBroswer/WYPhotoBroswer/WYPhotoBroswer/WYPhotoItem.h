//
//  WYPhotoItem.h
//  WYPhotoBrowser
//
//  Created by 王岩 on 16/4/11.
//  Copyright © 2016年 wangyan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface WYPhotoItem : NSObject
@property(nonatomic,strong)UIView* thumbView;
@property(nonatomic,strong)NSURL* orignalImageUrl;
@property(nonatomic,strong)UIImage* thumbImage;

@end
