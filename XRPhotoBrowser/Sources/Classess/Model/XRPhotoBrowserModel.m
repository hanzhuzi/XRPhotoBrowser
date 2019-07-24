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

#import "XRPhotoBrowserModel.h"
#import "XRPhotoBrowserMarcos.h"
#import "UIImage+XRPhotoBrowser.h"

#import <SDWebImage/SDWebImageManager.h>
#import <Photos/Photos.h>

#define XR_SDWebImageDownloadImageOptions (SDWebImageLowPriority | SDWebImageRetryFailed | SDWebImageAllowInvalidSSLCertificates)

@interface XRPhotoBrowserModel ()

@property (nonatomic, copy, nullable)   NSString * urlString;
@property (nonatomic, strong, nullable) NSURL * url;
@property (nonatomic, strong, nullable) UIImage * image;
@property (nonatomic, strong, nullable) NSData * fileData;
@property (nonatomic, strong, nullable) PHAsset * asset;

// SDImageOperation
@property (nonatomic, strong, nullable) SDWebImageCombinedOperation * webImageOperation;

@property (nonatomic, strong) PHImageManager * imageManager;
@property (nonatomic, strong) NSOperationQueue * requestQueue;
@property (nonatomic, assign) PHImageRequestID imageRequestID;

@end

@implementation XRPhotoBrowserModel

- (void)dealloc {
    
    [self cancelAllLoading];
}

#pragma mark - Initilaztion

- (instancetype)init {
    self = [super init];
    
    if (self) {
        [self _setup];
        return self;
    }
    
    return nil;
}

/// Custom Initalization
- (instancetype)initWithURL:(NSURL *)url {
    self = [super init];
    
    [self _setup];
    self.url = url;
    return self;
}

- (instancetype)initWithURLString:(NSString *)urlString {
    self = [super init];
    
    [self _setup];
    self.urlString = urlString;
    return self;
}

- (instancetype)initWithImage:(UIImage *)image {
    self = [super init];
    
    [self _setup];
    self.image = image;
    return self;
}

- (instancetype)initWithFileData:(NSData *)fileData {
    self = [super init];
    
    [self _setup];
    self.fileData = fileData;
    return self;
}

- (instancetype)initWithPhAsset:(PHAsset *)phasset {
    self = [super init];
    
    [self _setup];
    self.imageManager = [PHCachingImageManager defaultManager];
    self.asset = phasset;
    return self;
}

+ (id<XRPhotoBrowserModelProtocol>)photoBrowserModelWithURLString:(NSString *)urlString {
    return [[XRPhotoBrowserModel alloc] initWithURLString:urlString];;
}

+ (id<XRPhotoBrowserModelProtocol>)photoBrowserModelWithURL:(NSURL *)url {
    return [[XRPhotoBrowserModel alloc] initWithURL:url];
}

+ (id<XRPhotoBrowserModelProtocol>)photoBrowserModelWithData:(NSData *)fileData {
    return [[XRPhotoBrowserModel alloc] initWithFileData:fileData];
}

+ (id<XRPhotoBrowserModelProtocol>)photoBrowserModelWithAsset:(PHAsset *)asset {
    return [[XRPhotoBrowserModel alloc] initWithPhAsset:asset];
}

+ (id<XRPhotoBrowserModelProtocol>)photoBrowserModelWithImage:(UIImage *)image {
    return [[XRPhotoBrowserModel alloc] initWithImage:image];
}

/// set up
- (void)_setup {
    
    self.requestQueue = [[NSOperationQueue alloc] init];
    self.requestQueue.maxConcurrentOperationCount = 10;
    
    // 开始默认为loading
    self.loadState = XRPhotoBrowserImageLoadStateLoading;
    self.isLoadingInProgress = NO;
    self.progressInLoading = 0.0;
}

#pragma mark - Loading image

- (void)_loadingImage {
    
    if (_finalImage || _isLoadingInProgress) {
        return;
    }
    
    // 设置为loading状态
    self.loadState = XRPhotoBrowserImageLoadStateLoading;
    
    if (self.urlString) {
        // loading image with `SDWebImage`
        [self _loadImageWitWebUrl:[NSURL URLWithString:self.urlString]];
    }
    else if (self.url) {
        if ([self.url isFileURL]) {
            // url for local image
            [self _loadImageWithLocalFileUrl:self.url];
        }
        else {
            // loading image with `SDWebImage`
            [self _loadImageWitWebUrl:self.url];
        }
    }
    else if (self.image) {
        self.finalImage = self.image;
        [self imageLoadingComplete];
    }
    else if (self.fileData) {
        [self _loadImageWithFileData:self.fileData];
    }
    else if (self.asset) {
        // load image with 'PHAsset'
        [self _loadImageWithPHAsset:self.asset];
    }
}

/// loadinng image with `SDWebImage`
- (void)_loadImageWitWebUrl:(NSURL *)url {
    
    if (!url) {
        return;
    }
    
    self.isLoadingInProgress = YES;
    
    __weak typeof(self) weakSelf = self;
    
    self.webImageOperation = [[SDWebImageManager sharedManager] loadImageWithURL:url options:XR_SDWebImageDownloadImageOptions  progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        // progress notify
        if ([targetURL.absoluteString isEqualToString:weakSelf.urlString] || [targetURL.absoluteString isEqualToString:weakSelf.url.absoluteString]) {
            double progress = (double)receivedSize / (double)expectedSize;
            progress = progress <= 0 ? 0 : progress;
            progress = progress >= 0.999 ? 1.0 : progress;
            
            weakSelf.progressInLoading = progress;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:XRPHOTOBROWSER_IMAGE_LOAD_PROGRESS_CHANGED_NNKEY object:weakSelf userInfo:nil];
            });
            
            XRBrowserLog(@"url->%@\nprogress-> %lf", targetURL.absoluteString, progress);
        }
        
    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        if (image) {
            if ([imageURL.absoluteString isEqualToString:weakSelf.urlString] || [imageURL.absoluteString isEqualToString:weakSelf.url.absoluteString]) {
                weakSelf.finalImage = image;
                weakSelf.progressInLoading = 1.0;
                [weakSelf imageLoadingComplete];
            }
        }
        else {
            // image load failture
            [self imageLoadingFailture];
        }
    }];
}

- (void)_loadImageWithLocalFileUrl:(NSURL *)url {
    
    if (!url) {
        return;
    }
    
    self.isLoadingInProgress = YES;
    
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0l), ^{
        
        @try {
            NSData * data = [[NSData alloc] initWithContentsOfURL:url];
            UIImage * image = [UIImage imageWithData:data];
            weakSelf.finalImage = image;
            weakSelf.progressInLoading = 1.0;
            
            if (weakSelf.finalImage) {
                [weakSelf imageLoadingComplete];
            }
            else {
                [weakSelf imageLoadingFailture];
            }
        } @catch (NSException *exception) {
            XRBrowserLog(@"local url to load image error->%@", exception);
            [weakSelf imageLoadingFailture];
        } @finally {
            // no things
        }
    });
}

- (void)_loadImageWithFileData:(NSData *)data {
    
    if (!data) {
        return;
    }
    
    self.isLoadingInProgress = YES;
    
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0l), ^{
        
        @try {
            UIImage * image = [UIImage imageWithData:data];
            weakSelf.finalImage = image;
            weakSelf.progressInLoading = 1.0;
            
            if (weakSelf.finalImage) {
                [weakSelf imageLoadingComplete];
            }
            else {
                [weakSelf imageLoadingFailture];
            }
        } @catch (NSException *exception) {
            XRBrowserLog(@"data convert to image error->%@", exception);
            [weakSelf imageLoadingFailture];
        } @finally {
            // no things
        }
        
    });
}

/// load image with PHAsset
- (void)_loadImageWithPHAsset:(PHAsset *)asset {
    
    if (!asset) {
        return;
    }
    
    [self getFitsBigImageWithAsset:asset];
}

/// 获取合适的大图
- (void)getFitsBigImageWithAsset:(PHAsset *)phAsset {
    
    self.isLoadingInProgress = YES;
    
    __weak __typeof(self) weakSelf = self;
    
    [self.requestQueue addOperationWithBlock:^{
        
        // 获取图片
        PHImageRequestOptions * reqOptions = [[PHImageRequestOptions alloc] init];
        reqOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        reqOptions.resizeMode = PHImageRequestOptionsResizeModeFast;
        reqOptions.synchronous = NO; // 异步请求
        reqOptions.networkAccessAllowed = YES;
        reqOptions.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
            
            progress = progress <= 0 ? 0 : progress;
            progress = progress >= 0.999 ? 1.0 : progress;
            
            weakSelf.progressInLoading = progress;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:XRPHOTOBROWSER_IMAGE_LOAD_PROGRESS_CHANGED_NNKEY object:weakSelf userInfo:nil];
            });
        };
        
        CGFloat scale = [UIScreen mainScreen].scale;
        CGFloat imageSize = MAX(XR_Main_Screen_Width, XR_Main_Screen_Height) * 1.5;
        CGSize imageTargetSize = CGSizeMake(imageSize * scale, imageSize * scale); // 大图
        
        self.imageRequestID = [self.imageManager requestImageForAsset:phAsset targetSize:imageTargetSize contentMode:PHImageContentModeAspectFit options:reqOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            if (info && info[PHImageResultRequestIDKey]) {
                
                PHImageRequestID requestID = [info[PHImageResultRequestIDKey] intValue];
                if (requestID == weakSelf.imageRequestID) {
                    if (![info[PHImageCancelledKey] boolValue] && ![info[PHImageErrorKey] boolValue]) {
                        
                        if (result) {
                            UIImage * resImage = [result xrBrowser_fixOrientation];
                            weakSelf.finalImage = resImage;
                            weakSelf.progressInLoading = 1.0;
                            [weakSelf imageLoadingComplete];
                        }
                        else {
                            [weakSelf imageLoadingFailture];
                        }
                    }
                    else {
                        [weakSelf imageLoadingFailture];
                    }
                }
            }
            else {
                // 一般不会到这里，异步请求若走到这里也无法判断是哪一个请求出错了。
                XRBrowserLog(@"requestImageForAsset is error!");
            }
        }];
    }];
}

#pragma mark - Methods

- (void)startLoadingImage {
    
    [self _loadingImage];
}

- (void)retryReloadingFailtureImage {
    
    self.finalImage = nil;
    [self _loadingImage];
}

- (UIImage *)imageForPhotoModel {
    
    if (self.finalImage) {
        return self.finalImage;
    }
    else {
        [self _loadingImage];
        return nil;
    }
}

/// image load finished
- (void)imageLoadingComplete {
    
    if (self.finalImage) {
        self.loadState = XRPhotoBrowserImageLoadStateSuccess;
        self.isLoadingInProgress = YES;
    }
    else {
        self.loadState = XRPhotoBrowserImageLoadStateFaild;
        self.isLoadingInProgress = YES;
    }
    
    __weak __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:XRPHOTOBROWSER_IMAGE_LOAD_STATE_CHANGED_NNKEY object:weakSelf userInfo:nil];
    });
}

/// image load failture
- (void)imageLoadingFailture {
    
    self.loadState = XRPhotoBrowserImageLoadStateFaild;
    self.isLoadingInProgress = YES;
    
    __weak __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:XRPHOTOBROWSER_IMAGE_LOAD_STATE_CHANGED_NNKEY object:weakSelf userInfo:nil];
    });
}

- (void)cancelAllLoading {
    
    if (_webImageOperation) {
        [_webImageOperation cancel];
        _webImageOperation = nil;
    }
    
    // cancel PHImageManager loading
    if (self.imageRequestID != PHInvalidImageRequestID) {
        [self.imageManager cancelImageRequest:self.imageRequestID];
        self.imageRequestID = PHInvalidImageRequestID;
    }
}

- (void)releaseFinalImage {
    
    self.finalImage = nil;
    self.loadState = XRPhotoBrowserImageLoadStateLoading;
    self.progressInLoading = 0;
    self.isLoadingInProgress = NO;
}

@end
