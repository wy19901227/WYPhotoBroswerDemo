//
//  WYPhotoView.h
//  WYPhotoBrowser
//
//  Created by 王岩 on 16/4/12.
//  Copyright © 2016年 wangyan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WYPhotoCell.h"
#import "WYPhotoItem.h"
@class WYPhotoView;

@protocol WYPhotoViewDelegate <NSObject>


-(void)WYPhotoViewDidLongPress:(WYPhotoView *)photoView;

-(void)WYphotoCellScrollToIndex:(NSInteger)index;
@end

@interface WYPhotoView : UIView
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithFrame:(CGRect)frame UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

-(instancetype)initWithItems:(NSArray*)items fromView:(UIView*)fromView;
@property(nonatomic,assign)id <WYPhotoViewDelegate>delegate;
@property (nonatomic, readonly) NSArray *items; ///< Array<WYPhotoItem>
@property (nonatomic, readonly) NSInteger currentPage;
@property (nonatomic, assign) BOOL blurEffectBackground; ///< Default is YES
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, assign) BOOL isPresented;
@property (nonatomic, strong) UIPageControl *pager;
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;

@property(nonatomic,strong)UIView* toImageView;
@end
