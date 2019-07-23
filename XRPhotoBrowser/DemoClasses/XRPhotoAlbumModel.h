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

@class PHFetchResult;
@class PHAsset;
@class PHAssetCollection;
@class XRPhotoAssetModel;

typedef void (^XRPhotoAlbumAutoSetImageBlock)(UIImage * image);

@interface XRPhotoAlbumModel : NSObject

@property (nonatomic, copy) NSString * albumTitle; // 相册标题
@property (nonatomic, strong) UIImage * albumThubImage; // 相册缩略图
@property (nonatomic, assign) NSInteger assetCount; // 资源数
@property (nonatomic, strong) NSMutableArray <XRPhotoAssetModel *>* phAssets; // 相片资源集
@property (nonatomic, strong) NSMutableArray <XRPhotoAssetModel *>* selectedPhAssets; // 选择的相片资源集

// 当Photo图库照片变化时，用来更新图库
@property (nonatomic, strong) PHFetchResult * fetchResult;
@property (nonatomic, strong) PHAssetCollection * assetCollection;

// 请求ID
@property (nonatomic, copy) NSString * requestIdentifier;

// 设置图片的回调
@property (nonatomic, copy) XRPhotoAlbumAutoSetImageBlock autoSetImageBlock;

@end


