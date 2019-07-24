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

#import "XRPhotoPickerViewController.h"
#import <Photos/Photos.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "XRPhotoBrowserModel.h"
#import "XRPhtoManager.h"
#import "XRPhotoAssetModel.h"
#import "XRPhotoAlbumModel.h"
#import "XRPhotoBrowserMarcos.h"
#import "UIImage+XRPhotoBrowser.h"
#import "XRPhotoPickerAssetCell.h"

#import "XRPhotoBrowser.h"

#define XR_PhotoAsset_Grid_Border ([UIScreen mainScreen].bounds.size.width < 375.0 ? 2.0 : 5.0)

@interface XRPhotoPickerViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

// PhotoPicker
@property (nonatomic, strong) UICollectionView * mainCollection;
@property (nonatomic, strong) NSMutableArray <XRPhotoAssetModel *>* assetArray;
@property (nonatomic, strong) NSMutableArray <XRPhotoAssetModel *>* selectedAssetArray;
@property (nonatomic, strong) NSMutableArray <XRPhotoAssetModel *>* tmpSelectedAssetArray;
@property (nonatomic, assign) NSUInteger selectStepCounter;

@property (nonatomic, strong) XRPhtoManager * phManager;
@property (nonatomic, strong) NSString * saveLocalIdentifier;

// PhotoAlbums
@property (nonatomic, strong) NSArray <XRPhotoAlbumModel *>* Allalbums;
@property (nonatomic, strong) XRPhotoAlbumModel * selectedAlbum;
@property (nonatomic, assign) CGSize targetSize;

@property (nonatomic, assign) BOOL isShowedAlbumList;

/// 为了适配横竖屏幕
@property (nonatomic, assign) CGFloat photoAlbumListMaxHeight;
@end

@implementation XRPhotoPickerViewController

#pragma mark - deinit
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    XRBrowserLog(@"'%@' is dealloc!", NSStringFromClass([self class]));
}

#pragma mark - Initilizations
// 当PhotoAlbumList在外面时，调用该初始化方法创建照片选择页面
- (instancetype)initWithAlbumModel:(XRPhotoAlbumModel *)albumModel {
    if (self = [super init]) {
        [self initilizationPhotoPicker];
        [_assetArray addObjectsFromArray:albumModel.phAssets];
    }
    return self;
}

// 当PhotoAlbumList在里面时，调用该初始化方法创建照片选择页面
- (instancetype)init {
    if (self = [super init]) {
        [self initilizationPhotoPicker];
    }
    return self;
}

- (void)initilizationPhotoPicker {
    
    _statusBarStyle = UIStatusBarStyleDefault;
    _assetArray = [NSMutableArray arrayWithCapacity:10];
    _selectedAssetArray = [NSMutableArray arrayWithCapacity:10];
    _tmpSelectedAssetArray = [NSMutableArray arrayWithCapacity:5];
    
    _selectStepCounter = 0;
    _isPortrait = YES; // 默认是竖屏
    _maxSelectPhotos = 5; // 默认最多选择的照片数为5张
}

#pragma mark - Setter Override
- (void)setMaxSelectPhotos:(NSInteger)maxSelectPhotos {
    if (maxSelectPhotos != _maxSelectPhotos) {
        _maxSelectPhotos = maxSelectPhotos;
    }
    
}

- (void)setIsAscingForCreation:(BOOL)isAscingForCreation {
    if (_isAscingForCreation != isAscingForCreation) {
        _isAscingForCreation = isAscingForCreation;
        _phManager.isAscingForCreation = _isAscingForCreation;
    }
}

- (void)setIsAllowMultipleSelect:(BOOL)isAllowMultipleSelect {
    if (isAllowMultipleSelect != _isAllowMultipleSelect) {
        _isAllowMultipleSelect = isAllowMultipleSelect;
    }
}

- (void)setIsPortrait:(BOOL)isPortrait {
    if (_isPortrait != isPortrait) {
        _isPortrait = isPortrait;
    }
    
    ///只适配竖屏，暂时不适配横屏模式
    if (_isPortrait) {
        if ([UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeLeft || [UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeRight) {
            self.screenWidth = [UIScreen mainScreen].bounds.size.height;
            self.screenHeight = [UIScreen mainScreen].bounds.size.width;
        }
        else {
            self.screenWidth = [UIScreen mainScreen].bounds.size.width;
            self.screenHeight = [UIScreen mainScreen].bounds.size.height;
        }
    }
    else {
        // 若需要则需要适配横屏，但是现在都是竖屏模式
        if ([UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeLeft || [UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeRight) {
            self.screenWidth = [UIScreen mainScreen].bounds.size.height;
            self.screenHeight = [UIScreen mainScreen].bounds.size.width;
        }
        else {
            self.screenWidth = [UIScreen mainScreen].bounds.size.width;
            self.screenHeight = [UIScreen mainScreen].bounds.size.height;
        }
    }
}

#pragma mark - Lazy Porpertys
- (XRPhtoManager *)phManager {
    if (!_phManager) {
        _phManager = [XRPhtoManager defaultManager];
        _phManager.isAscingForCreation = _isAscingForCreation;
    }
    return _phManager;
}

#pragma mark - Setups

- (void)setupMainCollectionView {
    
    UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    _mainCollection = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.screenWidth, self.view.bounds.size.height) collectionViewLayout:flowLayout];
    _mainCollection.backgroundColor = UIColorFromRGB(0xFFFFFF);
    _mainCollection.delegate = self;
    _mainCollection.dataSource = self;
    _mainCollection.alwaysBounceVertical = YES;
    
    [_mainCollection registerClass:[XRPhotoPickerAssetCell class] forCellWithReuseIdentifier:@"XRPhotoPickerAssetCell"];
    
    [_mainCollection registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCell"];
    
    [self.view addSubview:_mainCollection];
}


#pragma mark - Life Cycles

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 设置不允许UIScrollView及其子类向下偏移
//    if ([self respondsToSelector:@selector(setAutomaticallyAdjustsScrollViewInsets:)]) {
//        [self setAutomaticallyAdjustsScrollViewInsets:NO];
//    }
    
    ///只适配竖屏，暂时不适配横屏模式
    if (_isPortrait) {
        if ([UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeLeft || [UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeRight) {
            self.screenWidth = [UIScreen mainScreen].bounds.size.height;
            self.screenHeight = [UIScreen mainScreen].bounds.size.width;
        }
        else {
            self.screenWidth = [UIScreen mainScreen].bounds.size.width;
            self.screenHeight = [UIScreen mainScreen].bounds.size.height;
        }
    }
    else {
        // 若需要则需要适配横屏，但是现在都是竖屏模式
        if ([UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeLeft || [UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeRight) {
            self.screenWidth = [UIScreen mainScreen].bounds.size.height;
            self.screenHeight = [UIScreen mainScreen].bounds.size.width;
        }
        else {
            self.screenWidth = [UIScreen mainScreen].bounds.size.width;
            self.screenHeight = [UIScreen mainScreen].bounds.size.height;
        }
    }

    
    if (@available(iOS 11.0, *)) {
        [self.mainCollection setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
    }
    else {
        if ([self respondsToSelector:@selector(setAutomaticallyAdjustsScrollViewInsets:)]) {
            [self setAutomaticallyAdjustsScrollViewInsets:NO];
        }
    }
    
    self.navigationItem.title = @"所有照片";
    [self addNotifications];
    [self setupMainCollectionView];
    [self requestAllPhotoAlbums];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    [self setNeedsStatusBarAppearanceUpdate];
    
    [self.view setNeedsLayout];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.mainCollection.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.statusBarStyle;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

// when present called
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

// 注册通知
- (void)addNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveiCloudDownloadNotification:) name:NNKEY_XRPHOTOBROWSER_PHMANAGER_DOWNLOAD_IMAGE_FROM_ICLOUD object:nil];
}

#pragma mark - Actions

// iCloud下载图片通知回调
- (void)receiveiCloudDownloadNotification:(NSNotification *)notif {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary * dict = (NSDictionary *)notif.object;
        
        if (dict && [dict isKindOfClass:[NSDictionary class]]) {
            NSIndexPath * indexpath = (NSIndexPath *)dict[XR_iCloud_IndexPathKey];
            NSNumber * progressNum = (NSNumber *)dict[XR_iCloud_DownloadProgressKey];
            
            if (indexpath && (indexpath.item >= 0 && indexpath.item < [self.mainCollection numberOfItemsInSection:0])) {
                XRPhotoPickerAssetCell * cell = (XRPhotoPickerAssetCell *)[self.mainCollection cellForItemAtIndexPath:indexpath];
                
                if (progressNum.doubleValue < 1.0) {
                    cell.progressLbl.hidden = NO;
                    cell.progressLbl.text = [NSString stringWithFormat:@"%d%%", (int)(progressNum.doubleValue * 100)];
                }
                else {
                    cell.progressLbl.hidden = YES;
                }
            }
        }
    });
}

- (void)cancelPhotoPickerAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(xr_photoPickerControllerDidCancel:)]) {
        [self.delegate xr_photoPickerControllerDidCancel:self];
    }
}


#pragma mark - Request 
- (void)requestAllPhotoAlbums {
    
    __weak __typeof(self) weakSelf = self;
    
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
        MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.margin = 10;
        hud.bezelView.layer.cornerRadius = 5;
        [UIActivityIndicatorView appearanceWhenContainedIn:[MBProgressHUD class], nil].color = UIColorFromRGB(0xAAAAAA);
        hud.bezelView.color = UIColorFromRGB(0xF2F2F2);
        
        [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
            [weakSelf.phManager getAllPhotoAlbumListWithAllowPickVideo:NO targetSize:weakSelf.targetSize fetchedAlbumList:^(NSArray<XRPhotoAlbumModel *> *albumList) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                    weakSelf.Allalbums = albumList;
                    
                    // 默认选择第一个相册
                    if (weakSelf.Allalbums.count > 0) {
                        weakSelf.selectedAlbum = weakSelf.Allalbums.firstObject;
                        
                        [weakSelf.assetArray removeAllObjects];
                        [weakSelf.assetArray addObjectsFromArray:weakSelf.selectedAlbum.phAssets];
                        [weakSelf.mainCollection reloadData];
                    }
                });
            }];
        }];
    }
    else {
        // 首次授权后最好有个加载提示
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusDenied) {
                // 用户首次授权时点击了 '不允许'，或者手动关闭了访问照片库的权限，需要做引导让用户打开照片库权限
                UIAlertController * alertCtrl = [UIAlertController alertControllerWithTitle:@"您已关闭了照片库的访问权限，请点击'去设置'以打开照片库访问权限" message:nil preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    
                }];
                
                UIAlertAction * settingAction = [UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                }];
                
                [alertCtrl addAction:cancelAction];
                [alertCtrl addAction:settingAction];
                
                [self presentViewController:alertCtrl animated:YES completion:nil];
            }
            else if (status == PHAuthorizationStatusAuthorized) {
                // 用户首次授权时点击了 '好'，开始请求数据
                dispatch_async(dispatch_get_main_queue(), ^{
                    // 获取相册
                    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                    hud.margin = 10;
                    hud.bezelView.layer.cornerRadius = 5;
                    [UIActivityIndicatorView appearanceWhenContainedIn:[MBProgressHUD class], nil].color = UIColorFromRGB(0xAAAAAA);
                    hud.bezelView.color = UIColorFromRGB(0xF2F2F2);
                    
                    [self.phManager getAllPhotoAlbumListWithAllowPickVideo:NO targetSize:weakSelf.targetSize fetchedAlbumList:^(NSArray<XRPhotoAlbumModel *> *albumList) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                            weakSelf.Allalbums = albumList;
                            
                            // 默认选择第一个相册
                            if (weakSelf.Allalbums.count > 0) {
                                weakSelf.selectedAlbum = weakSelf.Allalbums.firstObject;
                                
                                [weakSelf.assetArray removeAllObjects];
                                [weakSelf.assetArray addObjectsFromArray:weakSelf.selectedAlbum.phAssets];
                                [weakSelf.mainCollection reloadData];
                            }
                        });
                    }];
                });
            }
        }];
    }
}

#pragma mark - Methods
- (UICollectionViewCell *)cellForPhotoPickerWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath {
    
    __block XRPhotoPickerAssetCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"XRPhotoPickerAssetCell" forIndexPath:indexPath];
    
    cell.backgroundColor = UIColorFromRGB(0xCCCCCC);
    
    NSInteger index = indexPath.item;
    
    if (index < _assetArray.count) {
        __block XRPhotoAssetModel * assetModel = _assetArray[index];
        assetModel.indexPath = indexPath; // 记录IndexPath
        
        cell.representedAssetIdentifier = assetModel.phAsset.localIdentifier;
        
        [self.phManager getFitsThumbImageWithAsset:assetModel completeBlock:^(UIImage *image) {
            if ([cell.representedAssetIdentifier isEqualToString:assetModel.phAsset.localIdentifier] && image) {
                cell.assetImageView.image = image;
            }
        }];
        
        // 处理iCloud图片下载
        if (assetModel.isDownloadingFromiCloud && assetModel.downloadProgress.doubleValue < 1.0) {
            cell.progressLbl.hidden = NO;
            
            cell.progressLbl.text = [NSString stringWithFormat:@"%d%%", (int)([assetModel.downloadProgress doubleValue] * 100)];
        }
        else {
            // 无需iCloud下载，或已下载到本地相册中
            cell.progressLbl.hidden = YES;
        }
        
        return cell;
    }
    
    return [collectionView dequeueReusableCellWithReuseIdentifier:@"UICollectionViewCell" forIndexPath:indexPath];
}

- (void)takePhotoAction {
    
    __weak __typeof(self) weakSelf = self;
    
    if (![AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo]) {
        UIAlertController * alertCtrl = [UIAlertController alertControllerWithTitle:@"无法检测到摄像头，请确定是在真机上运行哦" message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        [alertCtrl addAction:cancelAction];
        
        [self presentViewController:alertCtrl animated:YES completion:nil];
        return;
    }
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if (authStatus == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (granted) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                        UIImagePickerController * pickerCtrl = [[UIImagePickerController alloc] init];
                        pickerCtrl.sourceType = UIImagePickerControllerSourceTypeCamera;
                        pickerCtrl.delegate = weakSelf;
                        [weakSelf presentViewController:pickerCtrl animated:YES completion:nil];
                    }
                }];
            }
        }];
    }
    else if (authStatus == AVAuthorizationStatusRestricted) {
        UIAlertController * alertCtrl = [UIAlertController alertControllerWithTitle:@"系统限制原因，无法使用摄像功能" message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        [alertCtrl addAction:cancelAction];
        
        [self presentViewController:alertCtrl animated:YES completion:nil];
    }
    else if (authStatus == AVAuthorizationStatusDenied) {
        UIAlertController * alertCtrl = [UIAlertController alertControllerWithTitle:@"您已关闭了相机的访问权限，请点击'去设置'以打开相机访问权限" message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        UIAlertAction * settingAction = [UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }];
        
        [alertCtrl addAction:cancelAction];
        [alertCtrl addAction:settingAction];
        
        [self presentViewController:alertCtrl animated:YES completion:nil];
    }
    else if (authStatus == AVAuthorizationStatusAuthorized) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIImagePickerController * pickerCtrl = [[UIImagePickerController alloc] init];
            pickerCtrl.sourceType = UIImagePickerControllerSourceTypeCamera;
            pickerCtrl.delegate = self;
            [self presentViewController:pickerCtrl animated:YES completion:nil];
        }
    }
}

#pragma mark - Delegates
#pragma mark - UICollectionViewDelegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return _assetArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.item < _assetArray.count) {
        
        return [self cellForPhotoPickerWithCollectionView:collectionView indexPath:indexPath];
    }
    
    return [collectionView dequeueReusableCellWithReuseIdentifier:@"UICollectionViewCell" forIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.item < self.assetArray.count) {
        
        XRPhotoPickerAssetCell * cell = (XRPhotoPickerAssetCell *)[collectionView cellForItemAtIndexPath:indexPath];
        
        NSMutableArray * photoArray = [NSMutableArray arrayWithCapacity:10];
        
        [self.assetArray enumerateObjectsUsingBlock:^(XRPhotoAssetModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            XRPhotoBrowserModel * photo = [XRPhotoBrowserModel photoBrowserModelWithAsset:obj.phAsset];
            [photoArray addObject:photo];
        }];
        
        XRPhotoBrowser * photoBrowser = [[XRPhotoBrowser alloc] init];
        photoBrowser.dataArray = photoArray;
        
        // 设置转场动画相关参数
        CGRect fromRect = [XRPhotoBrowser getTransitionAnimateImageViewFromRectWithImageView:cell.assetImageView targetView:self.view.window];
        [photoBrowser setTransitionAnimateWithImage:cell.assetImageView.image contentMode:cell.assetImageView.contentMode fromRect:fromRect reboundAnimateForBack:YES];
        
        [photoBrowser showPhotoBrowser:self displayAtIndex:indexPath.item];
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(XR_PhotoAsset_Grid_Border, XR_PhotoAsset_Grid_Border, XR_PhotoAsset_Grid_Border, XR_PhotoAsset_Grid_Border);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return XR_PhotoAsset_Grid_Border;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return XR_PhotoAsset_Grid_Border;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat itemWidth = (self.screenWidth - XR_PhotoAsset_Grid_Border * 5.0) / 4.0;
    return CGSizeMake(itemWidth, itemWidth);
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    __weak __typeof(self) weakSelf = self;
    if ([info[UIImagePickerControllerMediaType] isEqualToString:(NSString *)kUTTypeImage] && [info objectForKey:UIImagePickerControllerOriginalImage]) {
        UIImage * originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        originalImage = [originalImage xrBrowser_fixOrientation];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if (weakSelf.isAllowCrop) {
                
            }
            else {
                if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(xr_photoPickerController:didSelectAssetWithOriginalImage:)]) {
                    [weakSelf.delegate xr_photoPickerController:weakSelf didSelectAssetWithOriginalImage:originalImage];
                }
            }
        }];
        
        // Save to PhotoLibrary
        __weak __typeof(self) weakSelf = self;
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetChangeRequest * creationRquest = [PHAssetChangeRequest creationRequestForAssetFromImage:originalImage];
            weakSelf.saveLocalIdentifier = creationRquest.placeholderForCreatedAsset.localIdentifier;
            
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            if (!success) {
                XRBrowserLog(@"cratation asset error!");
            }
            else {
                PHFetchResult * ftResult = [PHAsset fetchAssetsWithLocalIdentifiers:@[weakSelf.saveLocalIdentifier] options:nil];
                PHAsset * asset = ftResult.firstObject;
                XRPhotoAssetModel * assetModel = [[XRPhotoAssetModel alloc] init];
                assetModel.phAsset = asset;
                NSInteger insertIndex = 0;
                if (weakSelf.phManager.isAscingForCreation) {
                    insertIndex = weakSelf.selectedAlbum.phAssets.count;
                }
                else {
                    insertIndex = 0;
                }
                [weakSelf.selectedAlbum.phAssets insertObject:assetModel atIndex:insertIndex];
                [weakSelf.assetArray removeAllObjects];
                [weakSelf.assetArray addObjectsFromArray:weakSelf.selectedAlbum.phAssets];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.mainCollection performBatchUpdates:^{
                        [weakSelf.mainCollection insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:1 inSection:0]]];
                    } completion:^(BOOL finished) {
                        if (finished) {
                            [weakSelf.phManager getAllPhotoAlbumListWithAllowPickVideo:NO targetSize:weakSelf.targetSize fetchedAlbumList:^(NSArray<XRPhotoAlbumModel *> *albumList) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    weakSelf.Allalbums = albumList;
                                    
                                });
                            }];
                        }
                    }];
                });
            }
        }];
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end






