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

#import <UIKit/UIKit.h>

@class XRPhotoPickerViewController;
@class XRPhotoAlbumModel;
@class XRPhotoAssetModel;

@protocol XRPhotoPickerControllerDelegate<NSObject>

@optional

// 选择资源数超出最大允许选择资源数时回调
- (void)xr_photoPickerControllerDidOverrunMaxAllowSelectCount:(XRPhotoPickerViewController *)picker;

// 点击取消
- (void)xr_photoPickerControllerDidCancel:(XRPhotoPickerViewController *)picker;

// 点击完成
- (void)xr_photoPickerControllerDidFinished:(XRPhotoPickerViewController *)picker didSelectAssets:(NSArray <XRPhotoAssetModel *> *)assets;

// 单选时选择照片\拍照返回原图回调
- (void)xr_photoPickerController:(XRPhotoPickerViewController *)picker didSelectAssetWithOriginalImage:(UIImage *)originalImaage;

// 单选时选择照片\拍照返回裁剪的图片回调
- (void)xr_photoPickerController:(XRPhotoPickerViewController *)picker didSelectAssetWithCropImage:(UIImage *)cropImaage;
@end

@interface XRPhotoPickerViewController : UIViewController

@property (nonatomic, assign) BOOL isSupportCamera; // 是否支持拍照
@property (nonatomic, assign) BOOL isAllowMultipleSelect; // 是否允许多选
@property (nonatomic, assign) BOOL isAllowCrop; // 是否允许裁剪
@property (nonatomic, assign) BOOL isPreviewForSingleSelect; // 单选时是否需要预览，且只在单选时有效
@property (nonatomic, assign) BOOL isAscingForCreation; // 是否按照创建日期进行升序排序 默认YES
@property (nonatomic, assign) BOOL isPortrait; // 是否是竖屏

@property (nonatomic, assign) NSInteger maxSelectPhotos; // 最大可选择的照片数
// 为了保证cropSize是正确的，因此必须在设置cropSize之前先设置isPortraint
@property (nonatomic, assign) CGSize cropSize; // 裁剪区域大小
// 横竖屏适配
@property (nonatomic, assign) CGFloat screenWidth;
@property (nonatomic, assign) CGFloat screenHeight;
// 状态栏样式
@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;

@property (nonatomic, weak) id<XRPhotoPickerControllerDelegate> delegate;

- (instancetype)initWithAlbumModel:(XRPhotoAlbumModel *)albumModel;

@end
