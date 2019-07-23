//
//  XRPhotoBrowserLoadingView.h
//  XRPhotoBrowser
//
//  Created by 徐冉 on 2019/7/17.
//  Copyright © 2019 QK. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface XRPhotoBrowserLoadingView : UIView

// 进度 0 ~ 1.0
@property (nonatomic, assign) double progress;
// 进度条宽度 Default is 7.0.
@property (nonatomic, assign) CGFloat progressLineWidth;

@end

NS_ASSUME_NONNULL_END
