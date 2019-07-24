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
