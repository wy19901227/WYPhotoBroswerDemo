//
//  WYPhotoView.m
//  WYPhotoBrowser
//
//  Created by 王岩 on 16/4/12.
//  Copyright © 2016年 wangyan. All rights reserved.
//

#import "WYPhotoView.h"
#import "YYKit.h"
#import "WYPhotoBrowser.h"

#define kPadding 20
#define kHiColor [UIColor colorWithRGBHex:0x2dd6b8]

@interface WYPhotoView()<UIGestureRecognizerDelegate,UIScrollViewDelegate>

@property (nonatomic, weak) UIView *fromView;


@property (nonatomic, strong) UIImage *snapshotImage;
@property (nonatomic, strong) UIImage *snapshorImageHideFromView;

@property (nonatomic, strong) UIImageView *background;
@property (nonatomic, strong) UIImageView *blurBackground;

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) NSMutableArray *cells;

@property (nonatomic, assign) CGFloat pagerCurrentPage;
@property (nonatomic, assign) BOOL fromNavigationBarHidden;

@property (nonatomic, assign) NSInteger fromItemIndex;


@end

@implementation WYPhotoView

-(instancetype)initWithItems:(NSArray *)items fromView:(UIView*)fromView
{
    if (self=[super init]) {
        
        if (items.count == 0) return nil;

        _items = items.copy;
        _blurEffectBackground = YES;
        
        NSString *model = [UIDevice currentDevice].machineModel;
        static NSMutableSet *oldDevices;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            oldDevices = [NSMutableSet new];
            [oldDevices addObject:@"iPod1,1"];
            [oldDevices addObject:@"iPod2,1"];
            [oldDevices addObject:@"iPod3,1"];
            [oldDevices addObject:@"iPod4,1"];
            [oldDevices addObject:@"iPod5,1"];
            
            [oldDevices addObject:@"iPhone1,1"];
            [oldDevices addObject:@"iPhone1,1"];
            [oldDevices addObject:@"iPhone1,2"];
            [oldDevices addObject:@"iPhone2,1"];
            [oldDevices addObject:@"iPhone3,1"];
            [oldDevices addObject:@"iPhone3,2"];
            [oldDevices addObject:@"iPhone3,3"];
            [oldDevices addObject:@"iPhone4,1"];
            
            [oldDevices addObject:@"iPad1,1"];
            [oldDevices addObject:@"iPad2,1"];
            [oldDevices addObject:@"iPad2,2"];
            [oldDevices addObject:@"iPad2,3"];
            [oldDevices addObject:@"iPad2,4"];
            [oldDevices addObject:@"iPad2,5"];
            [oldDevices addObject:@"iPad2,6"];
            [oldDevices addObject:@"iPad2,7"];
            [oldDevices addObject:@"iPad3,1"];
            [oldDevices addObject:@"iPad3,2"];
            [oldDevices addObject:@"iPad3,3"];
        });
        if ([oldDevices containsObject:model]) {
            _blurEffectBackground = NO;
        }
        
        self.backgroundColor = [UIColor clearColor];
        self.frame = [UIScreen mainScreen].bounds;
        self.clipsToBounds = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
        tap.delegate = self;
        [self addGestureRecognizer:tap];
        
        UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
        tap2.delegate = self;
        tap2.numberOfTapsRequired = 2;
        [tap requireGestureRecognizerToFail: tap2];
        [self addGestureRecognizer:tap2];
        
        UILongPressGestureRecognizer *press = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress)];
        press.delegate = self;
        [self addGestureRecognizer:press];
        
        
        
        _cells = @[].mutableCopy;
        
        _background = UIImageView.new;
        _background.frame = self.bounds;
        _background.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        _blurBackground = UIImageView.new;
        _blurBackground.frame = self.bounds;
        _blurBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        _contentView = UIView.new;
        _contentView.frame = self.bounds;
        _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        _scrollView = UIScrollView.new;
        _scrollView.frame = CGRectMake(-kPadding / 2, 0, self.width + kPadding, self.height);
        _scrollView.contentSize=CGSizeMake(_scrollView.width*_items.count, _scrollView.height);
        _scrollView.delegate = self;
        _scrollView.scrollsToTop = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.alwaysBounceHorizontal = items.count > 1;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scrollView.delaysContentTouches = NO;
        _scrollView.canCancelContentTouches = YES;
        

        
        _pager = [[UIPageControl alloc] init];
        _pager.hidesForSinglePage = YES;
        _pager.userInteractionEnabled = NO;
        _pager.width = self.width - 36;
        _pager.height = 10;
        _pager.center = CGPointMake(self.width / 2, self.height - 18);
        _pager.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;

        
        [self addSubview:_background];
        [self addSubview:_blurBackground];
        [self addSubview:_contentView];
        [_contentView addSubview:_scrollView];
        [_contentView addSubview:_pager];

        
        NSInteger page = -1;
        for (NSUInteger i = 0; i < self.items.count; i++) {
            if (fromView == ((WYPhotoItem*)self.items[i]).thumbView) {
                page = (int)i;
                break;
            }
        }
        if (page == -1) page = 0;
        _fromItemIndex = page;
        _pager.numberOfPages=_items.count;
        _pager.currentPage=page;
        

        [_scrollView scrollRectToVisible:CGRectMake(_scrollView.width * _pager.currentPage, 0, _scrollView.width, _scrollView.height) animated:NO];
        [self scrollViewDidScroll:_scrollView];
        
        
        WYPhotoCell *cell = [self cellForPage:self.currentPage];
        WYPhotoItem *item = _items[self.currentPage];
        
        NSString *imageKey = [[YYWebImageManager sharedManager] cacheKeyForURL:item.orignalImageUrl];
        if ([[YYWebImageManager sharedManager].cache getImageForKey:imageKey withType:YYImageCacheTypeMemory]) {
                cell.item = item;
            }
        
        if (!cell.item) {
            cell.imageView.image = item.thumbImage;
            [cell resizeSubviewSize];
        }
//        if (item.thumbClippedToTop) {
//            CGRect fromFrame = [_fromView convertRect:_fromView.bounds toView:cell];
//            CGRect originFrame = cell.imageContainerView.frame;
//            CGFloat scale = fromFrame.size.width / cell.imageContainerView.width;
//            
//            cell.imageContainerView.centerX = CGRectGetMidX(fromFrame);
//            cell.imageContainerView.height = fromFrame.size.height / scale;
//            cell.imageContainerView.layer.transformScale = scale;
//            cell.imageContainerView.centerY = CGRectGetMidY(fromFrame);
//        }


    }
    return self;
}
-(UIView *)toImageView
{
    return [self cellForPage:self.currentPage].imageContainerView;
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    
}
-(void)dismiss
{
    ( (WYPhotoBrowser*)self.viewController).animator.behindViewAlpha=0;
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
}
-(void)doubleTap:(UITapGestureRecognizer*)ges
{
   WYPhotoCell* cell= [self cellForPage:self.currentPage];
    [cell setZoomScale:2 animated:YES];
}
-(void)longPress
{
    if ([self.delegate respondsToSelector:@selector(WYPhotoViewDidLongPress:)]) {
        [self.delegate WYPhotoViewDidLongPress:self];
    }
}



/// enqueue invisible cells for reuse
- (void)updateCellsForReuse {
    for (WYPhotoCell *cell in _cells) {
        if (cell.superview) {
            if (cell.left > _scrollView.contentOffset.x + _scrollView.width * 2||
                cell.right < _scrollView.contentOffset.x - _scrollView.width) {
                [cell removeFromSuperview];
                cell.page = -1;
                cell.item = nil;
            }
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateCellsForReuse];
    
    CGFloat floatPage = _scrollView.contentOffset.x / _scrollView.width;
    NSInteger page = _scrollView.contentOffset.x / _scrollView.width + 0.5;
    
    for (NSInteger i = page - 1; i <= page + 1; i++) { // preload left and right cell
        if (i >= 0 && i < self.items.count) {
            WYPhotoCell *cell = [self cellForPage:i];
            if (!cell) {
                WYPhotoCell *cell = [self dequeueReusableCell];
                cell.page = i;
                cell.left = (self.width + kPadding) * i + kPadding / 2;
                
                if (_isPresented) {
                    cell.item = self.items[i];
                }
                [self.scrollView addSubview:cell];
            } else {
                if (_isPresented && !cell.item) {
                    cell.item = self.items[i];
                }
            }
        }
    }
    
    NSInteger intPage = floatPage + 0.5;
    intPage = intPage < 0 ? 0 : intPage >= _items.count ? (int)_items.count - 1 : intPage;
    _pager.currentPage = intPage;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
        _pager.alpha = 1;
    }completion:^(BOOL finish) {
    }];
}

/// dequeue a reusable cell
- (WYPhotoCell *)dequeueReusableCell {
    WYPhotoCell *cell = nil;
    for (cell in _cells) {
        if (!cell.superview) {
            return cell;
        }
    }
    
    cell = [WYPhotoCell new];
    cell.frame = self.bounds;
    cell.imageView.frame = self.bounds;
    cell.imageView.frame = cell.bounds;
    cell.page = -1;
    cell.item = nil;
    [_cells addObject:cell];
    return cell;
}

/// get the cell for specified page, nil if the cell is invisible
- (WYPhotoCell *)cellForPage:(NSInteger)page {
    for (WYPhotoCell *cell in _cells) {
        if (cell.page == page) {
            return cell;
        }
    }
    return nil;
}

- (NSInteger)currentPage {
    NSInteger page = _scrollView.contentOffset.x / _scrollView.width + 0.5;
    if (page >= _items.count) page = (NSInteger)_items.count - 1;
    if (page < 0) page = 0;
    return page;
}



-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger currentIndex=scrollView.contentOffset.x/scrollView.width;
    NSLog(@"%d",(int)currentIndex);
    if ([self.delegate respondsToSelector:@selector(WYphotoCellScrollToIndex:)]   ) {
        [self.delegate WYphotoCellScrollToIndex:currentIndex];
    }
}












@end
