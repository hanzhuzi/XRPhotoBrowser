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


#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@protocol XRPhotoBrowserModelProtocol <NSObject>

@required

/// final loaded image
@property (nonatomic, strong, nullable) UIImage * finalImage;


+ (id <XRPhotoBrowserModelProtocol>)photoBrowserModelWithImage:(UIImage *)image;
+ (id <XRPhotoBrowserModelProtocol>)photoBrowserModelWithURL:(NSURL *)url;
+ (id <XRPhotoBrowserModelProtocol>)photoBrowserModelWithURLString:(NSString *)urlString;
+ (id <XRPhotoBrowserModelProtocol>)photoBrowserModelWithData:(NSData *)fileData;
+ (id <XRPhotoBrowserModelProtocol>)photoBrowserModelWithAsset:(PHAsset *)asset;

// get final image
- (UIImage *)imageForPhotoModel;

@end

// 图片加载状态
typedef enum {
    
    XRPhotoBrowserImageLoadStateLoading = 1 << 0,  // 加载中
    XRPhotoBrowserImageLoadStateSuccess = 1 << 1,  // 加载成功
    XRPhotoBrowserImageLoadStateFaild   = 1 << 2   // 加载失败
} XRPhotoBrowserImageLoadState;

@interface XRPhotoBrowserModel : NSObject<XRPhotoBrowserModelProtocol>

// 加载成功的图片
@property (nonatomic, strong, nullable) UIImage * finalImage;
// 图片加载状态
@property (nonatomic, assign) XRPhotoBrowserImageLoadState loadState;
// 图片加载进度 0 ~ 1.0
@property (nonatomic, assign) double progressInLoading;
// 是否是正在加载中
@property (nonatomic, assign) BOOL isLoadingInProgress;


// 返回加载好的图片
- (UIImage *)imageForPhotoModel;

// 开始加载图片
- (void)startLoadingImage;

// 取消所有加载
- (void)cancelAllLoading;

// 重试加载失败的图片
- (void)retryReloadingFailtureImage;

- (void)releaseFinalImage;

/**
 * @brief 根据给定的url生成`XRPhotoBrowserModel`
 *
 * @param  url 图片，视频的url
 * @return `XRPhotoBrowserModel`
 */
+ (id<XRPhotoBrowserModelProtocol>)photoBrowserModelWithURL:(NSURL *)url;

/**
 * @brief 根据给定的urlString生成`XRPhotoBrowserModel`
 *
 * @param  urlString 图片，视频的url地址
 * @return `XRPhotoBrowserModel`
 */
+ (id<XRPhotoBrowserModelProtocol>)photoBrowserModelWithURLString:(NSString *)urlString;

/**
 * @brief 根据给定的fileData生成`XRPhotoBrowserModel`
 *
 * @param  fileData 文件二进制data
 * @return `XRPhotoBrowserModel`
 */
+ (id<XRPhotoBrowserModelProtocol>)photoBrowserModelWithData:(NSData *)fileData;

/**
 * @brief 根据给定的asset生成`XRPhotoBrowserModel`
 *
 * @param  asset 本地相册资源
 * @return `XRPhotoBrowserModel`
 */
+ (id<XRPhotoBrowserModelProtocol>)photoBrowserModelWithAsset:(PHAsset *)asset;

/**
 * @brief 根据给定的image生成`XRPhotoBrowserModel`
 *
 * @param  image UIImage对象
 * @return `XRPhotoBrowserModel`
 */
+ (id<XRPhotoBrowserModelProtocol>)photoBrowserModelWithImage:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
