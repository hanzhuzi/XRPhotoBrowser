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

/**
 * 基于`UIKit`自定制图片，视频浏览框架
 *
 * @author   Ran Xu
 * @version  1.0
 */

#import <UIKit/UIKit.h>
#import "XRPhotoBrowserModel.h"

NS_ASSUME_NONNULL_BEGIN

@class XRPhotoBrowserModel;
@interface XRPhotoBrowser : UIViewController

/// 数据源 <url, url string, data, image, phAsset>
/// 请在`showPhotoBrowser:`方法调用之前设置
@property (nonatomic, strong) NSArray <XRPhotoBrowserModel *>* dataArray;

/// 开始显示图片的位置下标，Default is 0.
/// 请在`showPhotoBrowser:`方法调用之前设置
@property (nonatomic, assign) NSUInteger displayAtIndex;

/// 是否隐藏状态栏，Default is YES.
@property (nonatomic, assign) BOOL isHideStatusBarForPhotoBrowser;

/// 当presenting页面设置了preferredStatusBarStyle，则无需设置此参数，若没有设置，且presenting页面导航条(系统)没有隐藏，
/// 则可能需要设置此参数以保证页面之间转场的流畅性，非必须设置参数，若发生转场效果不佳时可以试着设置此参数调整到流畅效果。
/// Default is UIStatusBarStyleLightContent.
@property (nonatomic, assign) UIStatusBarStyle presentingStatusBarStyle;

/// 转场动画相关 (设置以下两个参数可以实现页面图片转场效果，若页面图片显示内容和内容显示方式相差很大时不建议使用)
/// 需要转场动画的image
@property (nonatomic, strong) UIImage * animateImage;
/// 转场动画imageView的显示模式
@property (nonatomic, assign) UIViewContentMode fromImageContentMode;
/// 转场时image开始的rect
@property (nonatomic, assign) CGRect fromRect;
/// 返回时是否需要动画弹回animateImage，Default is YES.
@property (nonatomic, assign) BOOL isReboundAnimateImageForBack;

// reload data
- (void)reloadData;

/// 设置转场动画相关参数，请在showPhotoBrowser前设置，否则无效
- (void)setTransitionAnimateWithImage:(UIImage *)fromImage
                          contentMode:(UIViewContentMode)fromContentMode
                             fromRect:(CGRect)fromRect
                reboundAnimateForBack:(BOOL)isReboundAnimateForBack;

// 显示图片浏览
- (void)showPhotoBrowser:(UIViewController *)presentViewController;

// 显示图片浏览，指定显示图片的下标
- (void)showPhotoBrowser:(UIViewController *)presentViewController displayAtIndex:(NSUInteger)atIndex;

/// 获取需要动画转场的imageView的开始frame
+ (CGRect)getTransitionAnimateImageViewFromRectWithImageView:(UIImageView *)imageView targetView:(UIView *)targetView;

@end

NS_ASSUME_NONNULL_END
