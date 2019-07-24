//
//  Copyright (c) 2017-2020 是心作佛
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

#import "XRPhtoManager.h"
#import <Photos/Photos.h>
#import "XRPhotoAlbumModel.h"
#import "XRPhotoAssetModel.h"
#import "UIImage+XRPhotoBrowser.h"
#import "XRPhotoBrowserMarcos.h"

#define iOS9_Later ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0)

@interface XRPhtoManager ()

@end

@implementation XRPhtoManager

- (instancetype)init {
    if (self = [super init]) {
        _requestQueue = [[NSOperationQueue alloc] init];
        _requestQueue.maxConcurrentOperationCount = 10;
        _isAscingForCreation = YES;
    }
    return self;
}

+ (XRPhtoManager *)defaultManager {
    
    XRPhtoManager * manager = [[XRPhtoManager alloc] init];
    return manager;
}

#pragma mark - Propertys
- (PHCachingImageManager *)cacheImageManager {
    if (!_cacheImageManager) {
        _cacheImageManager = [[PHCachingImageManager alloc] init];
    }
    return _cacheImageManager;
}

- (BOOL)authorizationStatusAuthrized {
    return [PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized ? YES : NO;
}

#pragma mark - Methods


#pragma mark - 获取相册
// 获取相册
- (void)getPhotoAlumModelListFromFetchResult:(PHFetchResult <PHAssetCollection *>*)collectionResult isAllowPickVideo:(BOOL)allowPickVideo targetSize:(CGSize)targetSize photoAlbums:(void (^)(NSArray * phAlbums))phAlbumsBlock {
    
    NSMutableArray <XRPhotoAlbumModel *>* photoAlbums = [NSMutableArray arrayWithCapacity:10];
    
    PHFetchOptions * fetchOptions = [[PHFetchOptions alloc] init];
    if (!allowPickVideo) {
        fetchOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
    }
    fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:_isAscingForCreation]];
    
    for (NSInteger index = 0; index < collectionResult.count; index++) {
        if (collectionResult[index] && [collectionResult[index] isKindOfClass:[PHAssetCollection class]]) {
            PHAssetCollection * assetCollection = collectionResult[index];
            PHFetchResult * fetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:fetchOptions];
            
            // 过滤掉没有资源的相册
            if (fetchResult.count == 0) continue;
            
            // 过滤掉最近删除
            NSString * albumTitle = assetCollection.localizedTitle;
            if ([albumTitle containsString:@"最近删除"] || [albumTitle containsString:@"Deleted"]) {
                continue;
            }
            
            XRPhotoAlbumModel * albumModel = [[XRPhotoAlbumModel alloc] init];
            albumModel.albumTitle = assetCollection.localizedTitle;
            albumModel.fetchResult = fetchResult;
            albumModel.assetCollection = assetCollection;
            
            NSMutableArray * assets = [[NSMutableArray alloc] init];
            for (id asset in fetchResult) {
                if ([asset isKindOfClass:[PHAsset class]]) {
                    PHAsset * phAsset = asset;
                    XRPhotoAssetModel * assetModel = [[XRPhotoAssetModel alloc] init];
                    assetModel.phAsset = phAsset;
                    [assets addObject:assetModel];
                }
            }
            
            albumModel.phAssets = assets;
            
            // 预先获取一个小图
            if (albumModel.phAssets.count > 0) {
                XRPhotoAssetModel * pAsset;
                if (_isAscingForCreation) {
                    pAsset = albumModel.phAssets.lastObject;
                }
                else {
                    pAsset = albumModel.phAssets.firstObject;
                }
                
                // 设置requestIdentifier
                albumModel.requestIdentifier = pAsset.phAsset.localIdentifier;
                
                [self.requestQueue addOperationWithBlock:^{
                    // 获取图片
                    CGFloat scale = [UIScreen mainScreen].scale;
                    
                    PHImageRequestOptions * reqOptions = [[PHImageRequestOptions alloc] init];
                    reqOptions.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic; // 快速且高质量的返回图片
                    reqOptions.resizeMode = PHImageRequestOptionsResizeModeExact; // 严格按照targetSize获取图片
                    reqOptions.synchronous = NO; // 异步请求
                    
                    [self.cacheImageManager requestImageForAsset:pAsset.phAsset targetSize:CGSizeMake(targetSize.width * scale, targetSize.height * scale) contentMode:PHImageContentModeAspectFill options:reqOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                        if (result) {
                            result = [result xrBrowser_fixOrientation];
                            if ([albumModel.requestIdentifier isEqualToString:pAsset.phAsset.localIdentifier]) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    albumModel.albumThubImage = result;
                                });
                            }
                        }
                        else {
                            // 获取失败，设置默认图...
                        }
                    }];
                }];
            }
            
            if ([albumModel.albumTitle isEqualToString:@"Camera Roll"]
                || [albumModel.albumTitle isEqualToString:@"所有照片"]
                || [albumModel.albumTitle isEqualToString:@"相机胶卷"]
                || [albumModel.albumTitle isEqualToString:@"All Photos"]) {
                [photoAlbums insertObject:albumModel atIndex:0];
            }
            else {
                [photoAlbums addObject:albumModel];
            }
        }
    }
    
    phAlbumsBlock(photoAlbums);
}

// 获取智能相册列表
- (void)getSmartPhotoAlbumListWithAllowPickVideo:(BOOL)allowPickVideo targetSize:(CGSize)targetSize fetchedAlbumList:(void (^)(NSArray <XRPhotoAlbumModel *>* albumList))fetchedAlbumListBlock {
    
    if (CGSizeEqualToSize(targetSize, CGSizeZero)) {
        targetSize = CGSizeMake(120, 120);
    }
    PHFetchResult * smartAlbumsResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    [self getPhotoAlumModelListFromFetchResult:smartAlbumsResult isAllowPickVideo:allowPickVideo targetSize:targetSize photoAlbums:^(NSArray *phAlbums) {
        fetchedAlbumListBlock(phAlbums);
    }];
}

// 获取所有的相册
- (void)getAllPhotoAlbumListWithAllowPickVideo:(BOOL)allowPickVideo targetSize:(CGSize)targetSize fetchedAlbumList:(void (^)(NSArray<XRPhotoAlbumModel *> *albumList))fetchedAlbumListBlock {
    
    if (CGSizeEqualToSize(targetSize, CGSizeZero)) {
        targetSize = CGSizeMake(120, 120);
    }
    
    __block NSMutableArray * allPhotoAlbums = [NSMutableArray arrayWithCapacity:10];
    
    // 获取所有智能相册
    PHAssetCollectionSubtype smartSubType = PHAssetCollectionSubtypeSmartAlbumUserLibrary | PHAssetCollectionSubtypeSmartAlbumRecentlyAdded;
    if (@available(iOS 9.0, *)) {
        smartSubType = PHAssetCollectionSubtypeSmartAlbumUserLibrary
        | PHAssetCollectionSubtypeSmartAlbumRecentlyAdded
        | PHAssetCollectionSubtypeSmartAlbumScreenshots
        | PHAssetCollectionSubtypeSmartAlbumSelfPortraits;
    } else {
        // Fallback on earlier versions
    }
    
    PHFetchResult * smartAlbumsResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:smartSubType options:nil];
    [self getPhotoAlumModelListFromFetchResult:smartAlbumsResult isAllowPickVideo:allowPickVideo targetSize:targetSize photoAlbums:^(NSArray *phAlbums) {
        [allPhotoAlbums addObjectsFromArray:phAlbums];
    }];
    
    // 获取所有用户的相册
    PHFetchResult * userAlbumResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular | PHAssetCollectionSubtypeAlbumSyncedAlbum options:nil];
    [self getPhotoAlumModelListFromFetchResult:userAlbumResult isAllowPickVideo:allowPickVideo targetSize:targetSize photoAlbums:^(NSArray *phAlbums) {
        [allPhotoAlbums addObjectsFromArray:phAlbums];
    }];
    
    fetchedAlbumListBlock(allPhotoAlbums);
}

#pragma mark - 获取图片资源
// 获取缩略图
- (void)getThumbImageWithAsset:(XRPhotoAssetModel *)phModel targetSize:(CGSize)targetSize completeBlock:(void (^)(BOOL isDegrade, UIImage * image))completeBlock {
    
    if (CGSizeEqualToSize(targetSize, CGSizeZero)) {
        targetSize = CGSizeMake(100, 100);
    }
    
    [self.requestQueue addOperationWithBlock:^{
        CGFloat scale = [UIScreen mainScreen].scale;
        
        // 获取图片
        PHImageRequestOptions * reqOptions = [[PHImageRequestOptions alloc] init];
        reqOptions.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
        reqOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
        reqOptions.synchronous = NO; // 异步请求
        reqOptions.networkAccessAllowed = YES;
        
        reqOptions.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
            
            XRBrowserLog(@"iCloud图片下载进度：%.2f", progress);
            
            NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:5];
            NSNumber * progressNum = [NSNumber numberWithDouble:progress];
            [dict setValue:progressNum forKey:XR_iCloud_DownloadProgressKey];
            [dict setValue:phModel.indexPath forKey:XR_iCloud_IndexPathKey];
            
            phModel.isDownloadingFromiCloud = YES;
            phModel.downloadProgress = progressNum;
            
            [NSNotificationCenter.defaultCenter postNotificationName:NNKEY_XRPHOTOBROWSER_PHMANAGER_DOWNLOAD_IMAGE_FROM_ICLOUD object:dict];
        };
        
        PHAsset * pAsset = phModel.phAsset;
        
        [self.cacheImageManager requestImageForAsset:pAsset targetSize:CGSizeMake(targetSize.width * scale, targetSize.height * scale) contentMode:PHImageContentModeAspectFill options:reqOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            if (result) {
                result = [result xrBrowser_fixOrientation];
                
                if ([phModel.requestIdentifier isEqualToString:pAsset.localIdentifier]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        BOOL isDegrade = [info[PHImageResultIsDegradedKey] boolValue];
                        completeBlock(isDegrade, result);
                    });
                }
            }
            else {
                if ([phModel.requestIdentifier isEqualToString:pAsset.localIdentifier]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completeBlock(YES, nil);
                    });
                }
            }
        }];
    }];
}

// 获取原图
- (void)getOriginalImageWithAsset:(XRPhotoAssetModel *)phModel completeBlock:(void (^)(UIImage * image))completeBlock {
    
    [self.requestQueue addOperationWithBlock:^{
        
        // 获取图片
        PHImageRequestOptions * reqOptions = [[PHImageRequestOptions alloc] init];
        reqOptions.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
        reqOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
        reqOptions.synchronous = NO; // 异步请求
        reqOptions.networkAccessAllowed = YES;
        
        reqOptions.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
            
            XRBrowserLog(@"iCloud图片下载进度：%.2f", progress);
            
            NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:5];
            NSNumber * progressNum = [NSNumber numberWithDouble:progress];
            [dict setValue:progressNum forKey:XR_iCloud_DownloadProgressKey];
            [dict setValue:phModel.indexPath forKey:XR_iCloud_IndexPathKey];
            
            phModel.isDownloadingFromiCloud = YES;
            phModel.downloadProgress = progressNum;
            
            [NSNotificationCenter.defaultCenter postNotificationName:NNKEY_XRPHOTOBROWSER_PHMANAGER_DOWNLOAD_IMAGE_FROM_ICLOUD object:dict];
        };
        
        PHAsset * pAsset = phModel.phAsset;
        
        [self.cacheImageManager requestImageForAsset:pAsset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFit options:reqOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            if (result && info) {
                if (![info[PHImageResultIsDegradedKey] boolValue] && ![info[PHImageCancelledKey] boolValue] && ![info[PHImageErrorKey] boolValue]) {
                    result = [result xrBrowser_fixOrientation];
                    
                    if (pAsset.mediaType == PHAssetMediaTypeImage) {
                        NSURL * fileURL = (NSURL *)info[@"PHImageFileURLKey"];
                        XRBrowserLog(@"image fileURL--> %@", fileURL);
                    }
                    else if (pAsset.mediaType == PHAssetMediaTypeVideo) {
                        if ([pAsset isKindOfClass:[AVURLAsset class]]) {
                            NSURL * fileURL = ((AVURLAsset *)pAsset).URL;
                            XRBrowserLog(@"video fileURL--> %@", fileURL);
                        }
                    }
                    
                    if ([phModel.requestIdentifier isEqualToString:pAsset.localIdentifier]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completeBlock(result);
                        });
                    }
                }
            }
            else {
                if ([phModel.requestIdentifier isEqualToString:pAsset.localIdentifier]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completeBlock(nil);
                    });
                }
            }
        }];
    }];
}

// 获取合适的缩略图
- (void)getFitsThumbImageWithAsset:(XRPhotoAssetModel *)phModel completeBlock:(void (^)(UIImage * image))completeBlock {
    
    [self.requestQueue addOperationWithBlock:^{
        
        // 获取图片
        PHImageRequestOptions * reqOptions = [[PHImageRequestOptions alloc] init];
        reqOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        reqOptions.resizeMode = PHImageRequestOptionsResizeModeFast;
        reqOptions.synchronous = NO; // 异步请求
        reqOptions.networkAccessAllowed = YES;
        reqOptions.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
            
            XRBrowserLog(@"iCloud图片下载进度：%.2f", progress);
            
            NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:5];
            NSNumber * progressNum = [NSNumber numberWithDouble:progress];
            [dict setValue:progressNum forKey:XR_iCloud_DownloadProgressKey];
            [dict setValue:phModel.indexPath forKey:XR_iCloud_IndexPathKey];
            
            phModel.isDownloadingFromiCloud = YES;
            phModel.downloadProgress = progressNum;
            
            [NSNotificationCenter.defaultCenter postNotificationName:NNKEY_XRPHOTOBROWSER_PHMANAGER_DOWNLOAD_IMAGE_FROM_ICLOUD object:dict];
        };
        
        PHAsset * pAsset = phModel.phAsset;
        
        CGFloat scale = [UIScreen mainScreen].scale;
        CGFloat imageSize = MAX(XR_Main_Screen_Width, XR_Main_Screen_Height) * 1.5;
        CGSize thumbTargetSize = CGSizeMake(imageSize / 3.0 * scale, imageSize / 3.0 * scale); // 缩略图
        
        [self.cacheImageManager requestImageForAsset:pAsset targetSize:thumbTargetSize contentMode:PHImageContentModeAspectFit options:reqOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            if (result && info) {
                if (![info[PHImageCancelledKey] boolValue] && ![info[PHImageErrorKey] boolValue]) {
                    result = [result xrBrowser_fixOrientation];
                    
                    if (pAsset.mediaType == PHAssetMediaTypeImage) {
                        NSURL * fileURL = (NSURL *)info[@"PHImageFileURLKey"];
                        XRBrowserLog(@"image fileURL--> %@", fileURL);
                    }
                    else if (pAsset.mediaType == PHAssetMediaTypeVideo) {
                        if ([pAsset isKindOfClass:[AVURLAsset class]]) {
                            NSURL * fileURL = ((AVURLAsset *)pAsset).URL;
                            XRBrowserLog(@"video fileURL--> %@", fileURL);
                        }
                    }
                    
                    if ([phModel.requestIdentifier isEqualToString:pAsset.localIdentifier]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completeBlock(result);
                        });
                    }
                }
            }
            else {
                if ([phModel.requestIdentifier isEqualToString:pAsset.localIdentifier]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completeBlock(nil);
                    });
                }
            }
        }];
    }];
}

// 获取合适的大图
- (void)getFitsBigImageWithAsset:(XRPhotoAssetModel *)phModel completeBlock:(void (^)(UIImage *))completeBlock {
    
    [self.requestQueue addOperationWithBlock:^{
        
        // 获取图片
        PHImageRequestOptions * reqOptions = [[PHImageRequestOptions alloc] init];
        reqOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        reqOptions.resizeMode = PHImageRequestOptionsResizeModeFast;
        reqOptions.synchronous = NO; // 异步请求
        reqOptions.networkAccessAllowed = YES;
        reqOptions.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
            
            XRBrowserLog(@"iCloud图片下载进度：%.2f", progress);
            
            NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:5];
            NSNumber * progressNum = [NSNumber numberWithDouble:progress];
            [dict setValue:progressNum forKey:XR_iCloud_DownloadProgressKey];
            [dict setValue:phModel.indexPath forKey:XR_iCloud_IndexPathKey];
            
            phModel.isDownloadingFromiCloud = YES;
            phModel.downloadProgress = progressNum;
            
            [NSNotificationCenter.defaultCenter postNotificationName:NNKEY_XRPHOTOBROWSER_PHMANAGER_DOWNLOAD_IMAGE_FROM_ICLOUD object:dict];
        };
        
        PHAsset * pAsset = phModel.phAsset;
        
        CGFloat scale = [UIScreen mainScreen].scale;
        CGFloat imageSize = MAX(XR_Main_Screen_Width, XR_Main_Screen_Height) * 1.5;
        CGSize imageTargetSize = CGSizeMake(imageSize * scale, imageSize * scale); // 大图
        
        [self.cacheImageManager requestImageForAsset:pAsset targetSize:imageTargetSize contentMode:PHImageContentModeAspectFit options:reqOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            if (result && info) {
                if (![info[PHImageCancelledKey] boolValue] && ![info[PHImageErrorKey] boolValue]) {
                    result = [result xrBrowser_fixOrientation];
                    
                    if (pAsset.mediaType == PHAssetMediaTypeImage) {
                        NSURL * fileURL = (NSURL *)info[@"PHImageFileURLKey"];
                        XRBrowserLog(@"image fileURL--> %@", fileURL);
                    }
                    else if (pAsset.mediaType == PHAssetMediaTypeVideo) {
                        if ([pAsset isKindOfClass:[AVURLAsset class]]) {
                            NSURL * fileURL = ((AVURLAsset *)pAsset).URL;
                            XRBrowserLog(@"video fileURL--> %@", fileURL);
                        }
                    }
                    if ([phModel.requestIdentifier isEqualToString:pAsset.localIdentifier]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completeBlock(result);
                        });
                    }
                }
            }
            else {
                if ([phModel.requestIdentifier isEqualToString:pAsset.localIdentifier]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completeBlock(nil);
                    });
                }
            }
        }];
    }];
}

@end




