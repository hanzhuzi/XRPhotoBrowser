//
//  XRBrowserImageCell.h
//  XRPhotoBrowser
//
//  Created by 徐冉 on 2019/7/15.
//  Copyright © 2019 QK. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^ImageViewSingleTapBlock) (BOOL isScaling);

@class XRPhotoBrowserModel;
@class XRBrowserImageView;

@interface XRBrowserImageCell : UICollectionViewCell

@property (nonatomic, strong) XRBrowserImageView * imageView;
@property (nonatomic, assign) CGFloat imageViewZoomMaxScale; // default is 2.0

@property (nonatomic, copy) ImageViewSingleTapBlock singleTapBlock;
@property (nonatomic, copy) void (^imageViewHandlePanBlock) (BOOL isScaling);
@property (nonatomic, copy) void (^imageViewDidFinishLayoutFrameBlock) (UIImageView * imageView, CGRect imageViewFrame);

- (void)setPhotoModel:(XRPhotoBrowserModel * _Nonnull)photoModel isShouldScaleToBounds:(BOOL)scaleToBounds;

/// 开始加载并显示图片
- (void)startLoadingAndDisplayImage;

@end

NS_ASSUME_NONNULL_END
