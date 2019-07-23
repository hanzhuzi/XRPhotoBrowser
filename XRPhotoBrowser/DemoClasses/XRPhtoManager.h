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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define XR_iCloud_DownloadProgressKey @"XR_iCloud_DownloadProgressKey"
#define XR_iCloud_IndexPathKey @"XR_iCloud_IndexPathKey"

@class XRPhotoAlbumModel;
@class XRPhotoAssetModel;
@class PHCachingImageManager;
@interface XRPhtoManager : NSObject

/// 需要进行caching处理，目前没有进行caching处理。
@property (nonatomic, strong) PHCachingImageManager * cacheImageManager;
@property (nonatomic, strong) NSOperationQueue * requestQueue;
@property (nonatomic, assign) BOOL isAscingForCreation; // 是否按照创建日期进行升序排序 默认YES
@property (nonatomic, assign) BOOL authorizationStatusAuthrized; // 是否已经授权验证了

+ (XRPhtoManager *)defaultManager;

/** 获取相机相册列表
 
 @param allowPickVideo 是否选择视频
 
 @param targetSize 指定返回的图片的尺寸
 
 @param fetchedAlbumListBlock 返回相册回调
 */
- (void)getSmartPhotoAlbumListWithAllowPickVideo:(BOOL)allowPickVideo
                                      targetSize:(CGSize)targetSize
                                fetchedAlbumList:(void (^)(NSArray <XRPhotoAlbumModel *>* albumList))fetchedAlbumListBlock;

/** 获取所有的相册列表
 
 @param allowPickVideo 是否选择视频
 
 @param targetSize 指定返回的图片的尺寸
 
 @param fetchedAlbumListBlock 返回相册回调
 */
- (void)getAllPhotoAlbumListWithAllowPickVideo:(BOOL)allowPickVideo
                                    targetSize:(CGSize)targetSize
                              fetchedAlbumList:(void (^)(NSArray<XRPhotoAlbumModel *> *albumList))fetchedAlbumListBlock;

/** 获取缩略图
 
 @param phModel 资源模型
 
 @param targetSize 需要的图片尺寸，请勿*UIScreen的scale
 
 @param completeBlock 获取图片的回调
 */
- (void)getThumbImageWithAsset:(XRPhotoAssetModel *)phModel
                    targetSize:(CGSize)targetSize
                 completeBlock:(void (^)(BOOL isDegrade, UIImage * image))completeBlock;

/** 获取原图
 
 @param phModel 资源模型
 
 @param completeBlock 获取图片的回调
 */
- (void)getOriginalImageWithAsset:(XRPhotoAssetModel *)phModel completeBlock:(void (^)(UIImage * image))completeBlock;

/** 获取合适的缩略图
 
 @param phModel 资源模型
 
 @param completeBlock 获取图片的回调
 */
- (void)getFitsThumbImageWithAsset:(XRPhotoAssetModel *)phModel completeBlock:(void (^)(UIImage * image))completeBlock;

/** 获取合适的大图
 
 @param phModel 资源模型
 
 @param completeBlock 获取图片的回调
 */
- (void)getFitsBigImageWithAsset:(XRPhotoAssetModel *)phModel completeBlock:(void (^)(UIImage * image))completeBlock;

@end
