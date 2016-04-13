//
//  WYPhotoItem.m
//  WYPhotoBrowser
//
//  Created by 王岩 on 16/4/11.
//  Copyright © 2016年 wangyan. All rights reserved.
//

#import "WYPhotoItem.h"


@implementation WYPhotoItem
-(UIImage *)thumbImage
{
    
    if ([self.thumbView respondsToSelector:@selector(image)]) {
        return ((UIImageView*)self.thumbView).image;
    }
    else
    {
        return nil;
    }
}
- (BOOL)thumbClippedToTop {
    if (_thumbView) {
        if (_thumbView.layer.contentsRect.size.height < 1) {
            return YES;
        }
    }
    return NO;
}

@end
