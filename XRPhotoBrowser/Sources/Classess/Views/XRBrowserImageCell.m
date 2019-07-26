//
//  Copyright (c) 2019-2024 Ran Xu
//
//  XRPhotoBrowser is A Powerful, low memory usage, efficient and smooth photo browsing framework that supports image transit effect.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#import "XRBrowserImageCell.h"
#import "XRPhotoBrowserModel.h"
#import "XRBrowserImageView.h"
#import "XRPhotoBrowserLoadingView.h"
#import "XRPhotoBrowserMarcos.h"
#import "UIImage+XRPhotoBrowser.h"

@interface XRBrowserImageCell ()<UIScrollViewDelegate, XRBrowserImageViewDelegate, UIGestureRecognizerDelegate>
{
    BOOL _isPanHandled;
}

@property (nonatomic, strong) XRPhotoBrowserModel * photoModel;
@property (nonatomic, strong) UIImageView * errorImageView;
@property (nonatomic, strong) UIScrollView * mainScrollView;

@property (nonatomic, strong) XRPhotoBrowserLoadingView * loadingIndicator;

@end

@implementation XRBrowserImageCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        
        [self setup];
        return self;
    }
    
    return nil;
}

- (void)setup {
    
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    
    self.imageViewZoomMaxScale = 2.0;
    self->_isPanHandled = NO;
    
    self.mainScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    self.mainScrollView.delegate = self;
    self.mainScrollView.showsVerticalScrollIndicator = NO;
    self.mainScrollView.showsHorizontalScrollIndicator = NO;
    self.mainScrollView.zoomScale = 1.0; // default
    self.mainScrollView.minimumZoomScale = 1.0;
    self.mainScrollView.maximumZoomScale = 1.0;
    self.mainScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.contentView addSubview:self.mainScrollView];
    
    if (@available(iOS 11.0, *)) {
        self.mainScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    self.imageView = [[XRBrowserImageView alloc] init];
    self.imageView.frame = self.bounds;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.delegate = self;
    [self.mainScrollView addSubview:self.imageView];
    self.imageView.hidden = YES;
    
    // error Image
    self.errorImageView = [[UIImageView alloc] init];
    self.errorImageView.frame = self.bounds;
    self.errorImageView.contentMode = UIViewContentModeCenter;
    [self.contentView addSubview:self.errorImageView];
    self.errorImageView.userInteractionEnabled = NO;
    self.errorImageView.hidden = YES;
    self.errorImageView.image = [UIImage xrBrowser_imageForResourceName:@"icon_img_loading_fail" selfClass:self.class];
    
    // loading Indicator
    self.loadingIndicator = [[XRPhotoBrowserLoadingView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    [self.contentView addSubview:self.loadingIndicator];
    self.loadingIndicator.userInteractionEnabled = NO;
    self.loadingIndicator.hidden = YES;
    
    UIPanGestureRecognizer * panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestureAction:)];
    panGesture.delegate = self;
    [self.contentView addGestureRecognizer:panGesture];
}

#pragma mark - Methods
- (void)setPhotoModel:(XRPhotoBrowserModel *)photoModel isShouldScaleToBounds:(BOOL)scaleToBounds {
    
    if (_photoModel && photoModel == nil) {
        // 取消之前旧图片的加载
        [_photoModel cancelAllLoading];
    }
    
    _photoModel = photoModel;
    
    // 除了当前放大的图片不还原，其他可见的图片都恢复原来的缩放比例
    if (self.mainScrollView.zoomScale > self.mainScrollView.minimumZoomScale && scaleToBounds) {
        
        self.mainScrollView.maximumZoomScale = 1;
        self.mainScrollView.minimumZoomScale = 1;
        self.mainScrollView.zoomScale = 1;
        self.mainScrollView.contentSize = CGSizeMake(0.0, 0.0);
        
        if (_photoModel.loadState == XRPhotoBrowserImageLoadStateSuccess) {
            
            self.imageView.hidden = NO;
            self.errorImageView.hidden = YES;
            self.loadingIndicator.hidden = YES;
            
            self.imageView.image = nil;
            
            UIImage * finalImage = [_photoModel imageForPhotoModel];
            if (finalImage) {
                
                self.imageView.image = finalImage;
                CGSize imageSize = finalImage.size;
                
                CGRect imgViewFrame = CGRectMake(0, 0, imageSize.width, imageSize.height);
                self.imageView.frame = imgViewFrame;
                
                self.mainScrollView.contentSize = imgViewFrame.size;
                
                [self setInitalizationScaleForBounds];
            }
        }
    }
}

// 加载并显示图片
- (void)startLoadingAndDisplayImage {
    
    if (_photoModel) {
        
        if (self.mainScrollView.zoomScale <= self.mainScrollView.minimumZoomScale) {
            self.mainScrollView.maximumZoomScale = 1;
            self.mainScrollView.minimumZoomScale = 1;
            self.mainScrollView.zoomScale = 1;
            self.mainScrollView.contentSize = CGSizeMake(0.0, 0.0);
        }
        
        if (_photoModel.loadState == XRPhotoBrowserImageLoadStateLoading) {
            // 加载中
            self.imageView.hidden = YES;
            self.errorImageView.hidden = YES;
            self.loadingIndicator.hidden = NO;
            self.imageView.image = nil;
            
            [_photoModel startLoadingImage];
            
            self.loadingIndicator.progress = _photoModel.progressInLoading;
        }
        else if (_photoModel.loadState == XRPhotoBrowserImageLoadStateSuccess) {
            // 加载成功
            self.imageView.hidden = NO;
            self.errorImageView.hidden = YES;
            self.loadingIndicator.hidden = YES;
            
            self.imageView.image = nil;
            
            UIImage * finalImage = [_photoModel imageForPhotoModel];
            if (finalImage) {
                
                self.imageView.image = finalImage;
                
                if (self.mainScrollView.zoomScale <= self.mainScrollView.minimumZoomScale) {
                    CGSize imageSize = finalImage.size;
                    
                    CGRect imgViewFrame = CGRectMake(0, 0, imageSize.width, imageSize.height);
                    self.imageView.frame = imgViewFrame;
                    
                    self.mainScrollView.contentSize = imgViewFrame.size;
                    
                    [self setInitalizationScaleForBounds];
                }
            }
        }
        else {
            // 加载失败了
            self.imageView.hidden = YES;
            self.loadingIndicator.hidden = YES;
            self.errorImageView.hidden = NO;
        }
        
    }
}

// 返回初始的缩放比例
- (CGFloat)zoomScaleForInitalzation {
    
    CGFloat zoomScale = self.mainScrollView.minimumZoomScale;
    
    return zoomScale;
}

// 设置初始的缩放状态
- (void)setInitalizationScaleForBounds {
    
    self.mainScrollView.maximumZoomScale = 1;
    self.mainScrollView.minimumZoomScale = 1;
    self.mainScrollView.zoomScale = 1;
    
    if (self.imageView.image == nil) {
        return;
    }
    
    CGRect imgViewFrame = self.imageView.frame;
    imgViewFrame.origin = CGPointZero;
    self.imageView.frame = imgViewFrame;
    
    CGSize boundsSize = self.bounds.size;
    CGSize imageSize = self.imageView.image.size;
    
    CGFloat wScale = boundsSize.width / imageSize.width;
    CGFloat hScale = boundsSize.height / imageSize.height;
    
    CGFloat minScale = MIN(wScale, hScale);
    
    CGFloat maxScale = self.imageViewZoomMaxScale <= 1.2 ? 2.0 : self.imageViewZoomMaxScale;
    
    if (wScale >= 1 && hScale >= 1) {
        minScale = 1.0;
    }
    
    self.mainScrollView.maximumZoomScale = maxScale;
    self.mainScrollView.minimumZoomScale = minScale;
    
    self.mainScrollView.zoomScale = [self zoomScaleForInitalzation];
    
    if (self.mainScrollView.zoomScale != minScale) {
        // 当图片显示设置为`Fill`的时候需要计算图片居中时ScrollView的offset
        self.mainScrollView.contentOffset = CGPointMake((imageSize.width * self.mainScrollView.zoomScale - boundsSize.width) * 0.5, (imageSize.height * self.mainScrollView.zoomScale - boundsSize.height) * 0.5);
    }
    
    // 先禁止ScrollView滑动
    self.mainScrollView.scrollEnabled = NO;
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

#pragma mark - 图片缩放
// 还原图片缩放
- (void)setImageToInitalizationScaleAnimated {
    
    // 先重置ScrollView的缩放比例
    self.mainScrollView.maximumZoomScale = 1;
    self.mainScrollView.minimumZoomScale = 1;
    
    if (self.imageView.image == nil) {
        return;
    }
    
    CGSize boundsSize = self.bounds.size;
    CGSize imageSize = self.imageView.image.size;
    
    CGFloat wScale = boundsSize.width / imageSize.width;
    CGFloat hScale = boundsSize.height / imageSize.height;
    
    CGFloat minScale = MIN(wScale, hScale);
    
    CGFloat maxScale = self.imageViewZoomMaxScale <= 1.2 ? 2.0 : self.imageViewZoomMaxScale;
    
    if (wScale >= 1 && hScale >= 1) {
        minScale = 1.0;
    }
    
    self.mainScrollView.maximumZoomScale = maxScale;
    self.mainScrollView.minimumZoomScale = minScale;
    
    [self.mainScrollView setZoomScale:minScale animated:YES];
    
    if (self.mainScrollView.zoomScale != minScale) {
        // 当图片显示设置为`Fill`的时候需要计算图片居中时ScrollView的offset
        CGPoint offSet = CGPointMake((imageSize.width * self.mainScrollView.zoomScale - boundsSize.width) * 0.5, (imageSize.height * self.mainScrollView.zoomScale - boundsSize.height) * 0.5);
        self.mainScrollView.contentOffset = offSet;
    }
    
    self.mainScrollView.scrollEnabled = NO;
}

// 设置图片为最大缩放比例
- (void)setImageToMaxScaleAnimated:(CGPoint)touchPoint {
    
    // 先重置ScrollView的缩放比例
    self.mainScrollView.maximumZoomScale = 1;
    self.mainScrollView.minimumZoomScale = 1;
    
    if (self.imageView.image == nil) {
        return;
    }
    
    CGSize boundsSize = self.bounds.size;
    CGSize imageSize = self.imageView.image.size;
    
    CGFloat wScale = boundsSize.width / imageSize.width;
    CGFloat hScale = boundsSize.height / imageSize.height;
    
    CGFloat minScale = MIN(wScale, hScale);
    
    CGFloat maxScale = self.imageViewZoomMaxScale <= 1.0 ? 3.0 : self.imageViewZoomMaxScale;
    
    if (wScale >= 1 && hScale >= 1) {
        minScale = 1.0;
    }
    
    self.mainScrollView.maximumZoomScale = maxScale;
    self.mainScrollView.minimumZoomScale = minScale;
    
    // zooming (maxScale + minScale) / 2
    CGFloat newZoomScale = (maxScale + minScale) * 0.5;
    // zoomToRect width，height
    CGFloat scaleWidth = boundsSize.width / newZoomScale;
    CGFloat scaleHeight = boundsSize.height / newZoomScale;
    CGFloat x = touchPoint.x - scaleWidth * 0.5;
    CGFloat y = touchPoint.y - scaleHeight * 0.5;
    
    [self.mainScrollView zoomToRect:CGRectMake(x, y, boundsSize.width / newZoomScale, boundsSize.height / newZoomScale) animated:YES];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.loadingIndicator.center = CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height * 0.5);
    self.errorImageView.frame = self.bounds;
    
    // 使图片居中显示
    CGSize boundSize = self.bounds.size;
    CGRect imgViewFrame = self.imageView.frame;
    CGSize imgViewSize = self.imageView.frame.size;
    
    CGFloat x = 0, y = 0;
    
    if (imgViewSize.width < boundSize.width) {
        x = ((boundSize.width - imgViewSize.width) * 0.5);
    }
    
    if (imgViewSize.height < boundSize.height) {
        y = ((boundSize.height - imgViewSize.height) * 0.5);
    }
    
    imgViewFrame.origin = CGPointMake(x, y);
    
    if (!CGRectEqualToRect(imgViewFrame, self.imageView.frame)) {
        self.imageView.frame = imgViewFrame;
    }
    
    if (self.imageViewDidFinishLayoutFrameBlock
        && self.imageView.image
        && self.photoModel.loadState == XRPhotoBrowserImageLoadStateSuccess) {
        self.imageViewDidFinishLayoutFrameBlock(self.imageView, self.imageView.frame);
    }
}

#pragma mark - Action
/// 拖动手势，当用户向下拖动时关闭页面，使用UISwipeGestureRecognizer手势时返回上个页面状态栏有闪跳问题。
- (void)handlePanGestureAction:(UIPanGestureRecognizer *)panGesture {
    
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            self->_isPanHandled = NO;
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint transPoint = [panGesture translationInView:self.contentView];
            CGFloat absX = ABS(transPoint.x);
            CGFloat absY = ABS(transPoint.y);
            
            CGFloat maxValue = MAX(absX, absY);
            if (maxValue < 10) {
                return;
            }
            
            if (absX > absY) {
                // 左右滑动
                return;
            }
            else {
                // 上下滑动
                if (transPoint.y < 0) {
                    // 向上滑动
                    return;
                }
                else {
                    if (absX <= 25) { // 向下拖动时水平方向x的距离小于25pt时视为关闭操作
                        // 垂直向下拖
                        if (self.mainScrollView.zoomScale - 0.001 <= self.mainScrollView.minimumZoomScale) {
                            self->_isPanHandled = YES;
                        }
                    }
                    else {
                        self->_isPanHandled = NO;
                    }
                }
            }
            
        }
            break;
        case UIGestureRecognizerStateEnded:
            if (self->_isPanHandled) {
                self->_isPanHandled = NO;
                BOOL isScaling = self.mainScrollView.zoomScale > self.mainScrollView.minimumZoomScale;
                
                if (self.imageViewHandlePanBlock) {
                    self.imageViewHandlePanBlock(isScaling);
                }
            }
            break;
        case UIGestureRecognizerStateCancelled:
        {
            self->_isPanHandled = NO;
        }
            break;
        default:
            break;
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    self->_isPanHandled = NO;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    
    self.mainScrollView.scrollEnabled = YES;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    // 更新imageView的frame，使其居中
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    // 当拖动手势和UIScrollView的缩放手势一起时，只响应缩放手势。
    if ([otherGestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]]) {
        return NO;
    }
    return YES;
}

#pragma mark - XRBrowserImageViewDelegate

// 单击显示，隐藏toolBars
- (void)imageViewSingleTapAction {
    
    BOOL isScaling = self.mainScrollView.zoomScale - 0.001 > self.mainScrollView.minimumZoomScale;
    if (self.singleTapBlock) {
        self.singleTapBlock(isScaling);
    }
}

// 双击，放大\还原
- (void)imageViewDoubleTapAction:(UITouch *)touch {
    
    if (self.mainScrollView.zoomScale - 0.001 > self.mainScrollView.minimumZoomScale) {
        [self setImageToInitalizationScaleAnimated];
    }
    else {
        CGPoint touchPoint = [touch locationInView:self.imageView];
        [self setImageToMaxScaleAnimated:touchPoint];
    }
}

@end
