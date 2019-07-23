//
//  XRPhotoBrowser.h
//  XRPhotoBrowser
//
//  Created by 徐冉 on 2019/7/15.
//  Copyright © 2019 QK. All rights reserved.
//

/**
 * 基于`UIKit`自定制图片浏览器框架
 *
 * @author   Ran Xu
 * @version  1.0
 */

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class XRPhotoBrowserModel;
@interface XRPhotoBrowser : UIViewController

/// 开始显示图片的位置下标，Default is 0.
/// 请在`showPhotoBrowser:`方法调用之前设置
@property (nonatomic, assign) NSUInteger displayAtIndex;

/// 数据源 <url, url string, data, image, phAsset>
/// 请在`showPhotoBrowser:`方法调用之前设置
@property (nonatomic, strong) NSArray <XRPhotoBrowserModel *>* dataArray;

/// 是否隐藏状态栏，Default is NO.
@property (nonatomic, assign) BOOL isHideStatusBarForPhotoBrowser;

/// 转场动画相关 (设置以下两个参数可以实现页面图片转场效果，若页面图片显示内容和内容显示方式相差很大时不建议使用)
@property (nonatomic, strong) UIImage * animateImage;
@property (nonatomic, assign) CGRect fromRect;

/// 返回时是否需要动画弹回animateImage，Default is YES.
@property (nonatomic, assign) BOOL isReboundAnimateImageForBack;

// reload data
- (void)reloadData;

// 显示图片浏览
- (void)showPhotoBrowser:(UIViewController *)presentViewController;

// 显示图片浏览，指定显示图片的下标
- (void)showPhotoBrowser:(UIViewController *)presentViewController displayAtIndex:(NSUInteger)atIndex;

@end

NS_ASSUME_NONNULL_END
