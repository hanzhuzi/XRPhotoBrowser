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

#import "XRPhotoBrowser.h"
#import "XRPhotoBrowserModel.h"
#import "XRBrowserImageCell.h"
#import "XRBrowserImageView.h"
#import "XRPhotoBrowserDistanceLayout.h"
#import "XRPhotoBrowserMarcos.h"
#import "XRPhotoBrowserNavigationBar.h"

static CGFloat kAnimateTimeInterval = 0.3;
static CGFloat kImageViewAnimateTimeInterval = 0.4;

@interface XRPhotoBrowser ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    BOOL isApplyAnimateForImage;
    NSIndexPath * currentIndexPath;
    
    BOOL _isStatusBarHidden;
    UIStatusBarStyle _curStatusBarStyle;
}

@property (nonatomic, strong) UICollectionView * mainCollectionView;
@property (nonatomic, strong) XRPhotoBrowserDistanceLayout * flowLayout;
@property (nonatomic, strong) XRPhotoBrowserNavigationBar * navBar;

// 动画imageView
@property (nonatomic, strong) UIImageView * animateImageView;
@property (nonatomic, assign) CGRect toRect;

@end

@implementation XRPhotoBrowser

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    XRBrowserLog(@"%@ is dealloc!", NSStringFromClass(self.class));
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
        self.displayAtIndex = 0;
        self.isHideStatusBarForPhotoBrowser = YES;
        self->_isStatusBarHidden = NO;
        self.isReboundAnimateImageForBack = YES;
        self.fromImageContentMode = UIViewContentModeScaleAspectFill;
        self.presentingStatusBarStyle = UIStatusBarStyleLightContent;
        self->_curStatusBarStyle = self.presentingStatusBarStyle;
        self->currentIndexPath = [NSIndexPath indexPathForItem:-99 inSection:0];
        
        return self;
    }
    
    return nil;
}

#pragma mark - Lazy

- (XRPhotoBrowserDistanceLayout *)flowLayout {
    
    if (nil == _flowLayout) {
        _flowLayout = [[XRPhotoBrowserDistanceLayout alloc] init];
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _flowLayout.itemSize = CGSizeMake(XR_Main_Screen_Width, XR_Main_Screen_Height);
    }
    
    return _flowLayout;
}

- (UICollectionView *)mainCollectionView {
    
    if (nil == _mainCollectionView) {
        _mainCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, XR_Main_Screen_Width, XR_Main_Screen_Height) collectionViewLayout:self.flowLayout];
    }
    
    return _mainCollectionView;
}

- (XRPhotoBrowserNavigationBar *)navBar {
    
    if (nil == _navBar) {
        _navBar = [[XRPhotoBrowserNavigationBar alloc] initWithFrame:CGRectMake(0, 0, XR_Main_Screen_Width, 64)];
    }
    
    return _navBar;
}

#pragma mark - Setter

- (void)setDataArray:(NSArray<XRPhotoBrowserModel *> *)dataArray {
    
    _dataArray = dataArray;
}


#pragma mark - Initlzations

- (void)setup {
    
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.0];
    self.mainCollectionView.alpha = 0;
    
    [self.view addSubview:self.mainCollectionView];
    
    self.mainCollectionView.backgroundColor = [UIColor blackColor];
    self.mainCollectionView.pagingEnabled = YES;
    self.mainCollectionView.showsVerticalScrollIndicator = NO;
    self.mainCollectionView.showsHorizontalScrollIndicator = NO;
    self.mainCollectionView.alwaysBounceHorizontal = YES;
    self.mainCollectionView.alwaysBounceVertical = NO;
    
    self.mainCollectionView.delegate = self;
    self.mainCollectionView.dataSource = self;
    
    // register collection cells
    [self.mainCollectionView registerClass:[XRBrowserImageCell class] forCellWithReuseIdentifier:@"XRBrowserImageCell"];
    [self.mainCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCellForNull"];
    
    if (@available(iOS 11.0, *)) {
        self.mainCollectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    if (!CGSizeEqualToSize(self.fromRect.size, CGSizeZero) && self.animateImage) {
        self.animateImageView = [[UIImageView alloc] init];
        self.animateImageView.frame = self.fromRect;
        self.animateImageView.contentMode = self.fromImageContentMode;
        self.animateImageView.clipsToBounds = YES;
        self.animateImageView.image = self.animateImage;
        self.animateImageView.hidden = YES;
        [self.view addSubview:self.animateImageView];
        
        self.animateImageView.userInteractionEnabled = NO;
        self->isApplyAnimateForImage = NO;
        self.mainCollectionView.scrollEnabled = NO;
    }
    
    [self.view addSubview:self.navBar];
    self.navBar.alpha = 0;
}

- (void)addNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedImageLoadProgressChanged:) name:XRPHOTOBROWSER_IMAGE_LOAD_PROGRESS_CHANGED_NNKEY object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedImageLoadStateChanged:) name:XRPHOTOBROWSER_IMAGE_LOAD_STATE_CHANGED_NNKEY object:nil];
}

#pragma mark - Life Cycles
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addNotifications];
    [self setup];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    if (self.isHideStatusBarForPhotoBrowser) {
        if (self.presentingStatusBarStyle != UIStatusBarStyleLightContent) {
            self->_curStatusBarStyle = self.presentingStatusBarStyle;
        }
        else {
            self->_curStatusBarStyle = self.presentingViewController.preferredStatusBarStyle;
        }
    }
    [self setNeedsStatusBarAppearanceUpdate];
    
    [self reloadData];
    if (self.displayAtIndex > 0) {
        [self scrollToItemAtIndex:self.displayAtIndex];
    }
    else {
        self->currentIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    }
    
    NSString * navTitle = [NSString stringWithFormat:@"%ld / %ld", self->currentIndexPath.item + 1, self.dataArray.count];
    self.navBar.nav_title = navTitle;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.mainCollectionView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
}

#pragma mark StatusBar

- (BOOL)prefersStatusBarHidden {
    return self->_isStatusBarHidden;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return _curStatusBarStyle;
}

#pragma mark - Methods

- (void)showPhotoBrowser:(UIViewController *)presentViewController {
    
    __weak __typeof(self) weakSelf = self;
    
    self.modalPresentationStyle = UIModalPresentationOverFullScreen;
    // @see status bar appearance control is transferred from the presenting to the presented view controller only if the presented controller's modalPresentationStyle value is UIModalPresentationFullScreen. By setting this property to YES, you specify the presented view controller controls status bar appearance, even though presented non-fullscreen.
    self.modalPresentationCapturesStatusBarAppearance = YES;
    
    [presentViewController presentViewController:self animated:NO completion:^{
        [weakSelf show];
    }];
}

- (void)showPhotoBrowser:(UIViewController *)presentViewController displayAtIndex:(NSUInteger)atIndex {
    
    self.displayAtIndex = atIndex;
    
    __weak __typeof(self) weakSelf = self;
    
    self.modalPresentationStyle = UIModalPresentationOverFullScreen;
    // @see status bar appearance control is transferred from the presenting to the presented view controller only if the presented controller's modalPresentationStyle value is UIModalPresentationFullScreen. By setting this property to YES, you specify the presented view controller controls status bar appearance, even though presented non-fullscreen.
    self.modalPresentationCapturesStatusBarAppearance = YES;
    
    [presentViewController presentViewController:self animated:NO completion:^{
        [weakSelf show];
    }];
}

- (void)show {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    __weak __typeof(self) weakSelf = self;
    
    if (self.isHideStatusBarForPhotoBrowser) {
        if (self.presentingStatusBarStyle != UIStatusBarStyleLightContent) {
            self->_curStatusBarStyle = self.presentingStatusBarStyle;
        }
        else {
            self->_curStatusBarStyle = self.presentingViewController.preferredStatusBarStyle;
        }
    }
    
    [UIView animateWithDuration:kAnimateTimeInterval animations:^{
        weakSelf.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:1.0];
        weakSelf.mainCollectionView.alpha = 1.0;
        weakSelf.navBar.alpha = 1.0;
    } completion:^(BOOL finished) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf->_isStatusBarHidden = strongSelf.isHideStatusBarForPhotoBrowser;
        [strongSelf showOrHiddenStatusBar:strongSelf->_isStatusBarHidden];
    }];
}

- (void)hide {
    
    __weak __typeof(self) weakSelf = self;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    // 关闭时还原成跟上个页面的状态栏样式一致以解决关闭时上个页面导航栏闪动问题
    self->_isStatusBarHidden = NO;
    if (self.presentingStatusBarStyle != UIStatusBarStyleLightContent) {
        self->_curStatusBarStyle = self.presentingStatusBarStyle;
    }
    else {
        self->_curStatusBarStyle = self.presentingViewController.preferredStatusBarStyle;
    }
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    if (self.isReboundAnimateImageForBack && self.animateImage && self->currentIndexPath.item == self.displayAtIndex) {
        
        XRBrowserImageCell * imgCell = (XRBrowserImageCell *)[self.mainCollectionView cellForItemAtIndexPath:self->currentIndexPath];
        
        __block XRBrowserImageView * imageView = imgCell.imageView;
        
        if (self.animateImageView && imageView) {
            self.animateImageView.hidden = NO;
            imageView.hidden = YES;
            self.mainCollectionView.scrollEnabled = NO;
            
            [UIView animateWithDuration:kImageViewAnimateTimeInterval animations:^{
                weakSelf.animateImageView.frame = weakSelf.fromRect;
                weakSelf.animateImageView.contentMode = weakSelf.fromImageContentMode;
                weakSelf.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
                weakSelf.mainCollectionView.alpha = 0;
                weakSelf.navBar.alpha = 0;
                [weakSelf setNeedsStatusBarAppearanceUpdate];
            } completion:^(BOOL finished) {
                weakSelf.animateImageView.frame = weakSelf.fromRect;
                if (finished) {
                    [weakSelf dismissViewControllerAnimated:NO completion:nil];
                }
            }];
        }
        else {
            self.mainCollectionView.scrollEnabled = NO;
            [UIView animateWithDuration:kAnimateTimeInterval animations:^{
                weakSelf.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
                weakSelf.mainCollectionView.alpha = 0;
                weakSelf.navBar.alpha = 0;
                [weakSelf setNeedsStatusBarAppearanceUpdate];
            } completion:^(BOOL finished) {
                [weakSelf dismissViewControllerAnimated:NO completion:nil];
            }];
        }
    }
    else {
        self.mainCollectionView.scrollEnabled = NO;
        [UIView animateWithDuration:kAnimateTimeInterval animations:^{
            weakSelf.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
            weakSelf.mainCollectionView.alpha = 0;
            weakSelf.navBar.alpha = 0;
            [weakSelf setNeedsStatusBarAppearanceUpdate];
        } completion:^(BOOL finished) {
            [weakSelf dismissViewControllerAnimated:NO completion:nil];
        }];
    }
}

- (void)setTransitionAnimateWithImage:(UIImage *)fromImage
                          contentMode:(UIViewContentMode)fromContentMode
                             fromRect:(CGRect)fromRect
                reboundAnimateForBack:(BOOL)isReboundAnimateForBack {
    
    self.animateImage = fromImage;
    self.fromImageContentMode = fromContentMode;
    self.fromRect = fromRect;
    self.isReboundAnimateImageForBack = isReboundAnimateForBack;
}

+ (CGRect)getTransitionAnimateImageViewFromRectWithImageView:(UIImageView *)imageView targetView:(UIView *)targetView {
    
    CGRect fromRect = [imageView.superview convertRect:imageView.frame toView:targetView];
    return fromRect;
}

- (void)reloadData {
    
    [self.mainCollectionView reloadData];
}

- (void)scrollToItemAtIndex:(NSUInteger)index {
    
    if (self.dataArray.count == 0) {
        return;
    }
    
    NSUInteger atIndex = index;
    atIndex = atIndex < 0 ? 0 : atIndex;
    atIndex = atIndex >= self.dataArray.count ? self.dataArray.count - 1 : atIndex;
    
    NSIndexPath * toIndexPath = [NSIndexPath indexPathForItem:atIndex inSection:0];
    self->currentIndexPath = toIndexPath;
    
    [self.mainCollectionView scrollToItemAtIndexPath:toIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
}

/// 显示\隐藏StatusBar
- (void)showOrHiddenStatusBar:(BOOL)isHidden {
    
    [UIView beginAnimations:nil context:nil];
    
    [UIView setAnimationDuration:0.25];
    [UIView setAnimationDelay:0];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationRepeatCount:1];
    [UIView setAnimationRepeatAutoreverses:NO];
    
    self->_isStatusBarHidden = isHidden;
    [self setNeedsStatusBarAppearanceUpdate];
    
    [UIView commitAnimations];
}

#pragma mark - Actions

- (void)receivedImageLoadProgressChanged:(NSNotification *)notif {
    
    NSArray * visiableCells = self.mainCollectionView.visibleCells;
    
    for (UICollectionViewCell *cell in visiableCells) {
        NSIndexPath * indexPath = [self.mainCollectionView indexPathForCell:cell];
        if (indexPath.item < self.dataArray.count) {
            XRPhotoBrowserModel * model = self.dataArray[indexPath.item];
            
            if ([cell isKindOfClass:[XRBrowserImageCell class]]) {
                XRBrowserImageCell * imgCell = (XRBrowserImageCell *)cell;
                BOOL isScaleToBounds = indexPath.item != self->currentIndexPath.item;
                [imgCell setPhotoModel:model isShouldScaleToBounds:isScaleToBounds];
                [imgCell startLoadingAndDisplayImage];
            }
        }
    }
}

- (void)receivedImageLoadStateChanged:(NSNotification *)notif {
    
    NSArray * visiableCells = self.mainCollectionView.visibleCells;
    
    for (UICollectionViewCell *cell in visiableCells) {
        NSIndexPath * indexPath = [self.mainCollectionView indexPathForCell:cell];
        if (indexPath.item < self.dataArray.count) {
            XRPhotoBrowserModel * model = self.dataArray[indexPath.item];
            
            if ([cell isKindOfClass:[XRBrowserImageCell class]]) {
                XRBrowserImageCell * imgCell = (XRBrowserImageCell *)cell;
                BOOL isScaleToBounds = indexPath.item != self->currentIndexPath.item;
                [imgCell setPhotoModel:model isShouldScaleToBounds:isScaleToBounds];
                [imgCell startLoadingAndDisplayImage];
            }
        }
    }
}

#pragma mark - Delegates

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.item >= self.dataArray.count) {
        return [collectionView dequeueReusableCellWithReuseIdentifier:@"UICollectionViewCellForNull" forIndexPath:indexPath];
    }
    
    XRBrowserImageCell * imageCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"XRBrowserImageCell" forIndexPath:indexPath];
    
    XRPhotoBrowserModel * model = self.dataArray[indexPath.item];
    [imageCell setPhotoModel:model isShouldScaleToBounds:YES];
    
    __weak __typeof(self) weakSelf = self;
    imageCell.singleTapBlock = ^(BOOL isScaling){
        if (!isScaling) {
            [weakSelf hide];
        }
    };
    
    imageCell.imageViewHandlePanBlock = ^(BOOL isScaling){
        if (!isScaling) {
            [weakSelf hide];
        }
    };
    
    imageCell.imageViewDidFinishLayoutFrameBlock = ^(UIImageView * imageView, CGRect imageViewFrame){
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (!CGRectEqualToRect(imageView.frame, CGRectZero) && strongSelf->isApplyAnimateForImage == NO) {
            strongSelf->isApplyAnimateForImage = YES;
            imageView.hidden = YES;
            strongSelf.animateImageView.hidden = NO;
            
            CGRect toFrame = [XRPhotoBrowser getTransitionAnimateImageViewFromRectWithImageView:imageView targetView:weakSelf.view];
            weakSelf.toRect = toFrame;
            
            [UIView animateWithDuration:kImageViewAnimateTimeInterval animations:^{
                weakSelf.animateImageView.frame = weakSelf.toRect;
                weakSelf.animateImageView.contentMode = UIViewContentModeScaleAspectFit;
            } completion:^(BOOL finished) {
                weakSelf.animateImageView.frame = weakSelf.toRect;
                if (finished) {
                    imageView.hidden = NO;
                    weakSelf.animateImageView.hidden = YES;
                    weakSelf.mainCollectionView.scrollEnabled = YES;
                }
            }];
        }
        
    };
    
    return imageCell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.item < self.dataArray.count) {
        
        XRPhotoBrowserModel * photoModel = self.dataArray[indexPath.item];
        XRBrowserImageCell * imageCell = (XRBrowserImageCell *)cell;
        
        BOOL isScaleToBounds = indexPath.item != self->currentIndexPath.item;
        [imageCell setPhotoModel:photoModel isShouldScaleToBounds:isScaleToBounds];
        [imageCell startLoadingAndDisplayImage];
    }
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsZero;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake(XR_Main_Screen_Width, XR_Main_Screen_Height);
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    NSIndexPath * indexPath = [self.mainCollectionView indexPathForItemAtPoint:scrollView.contentOffset];
    self->currentIndexPath = indexPath;
    
    NSString * navTitle = [NSString stringWithFormat:@"%ld / %ld", self->currentIndexPath.item + 1, self.dataArray.count];
    self.navBar.nav_title = navTitle;
    
    NSUInteger index = indexPath.item;
    
    // release not displaying pre and next image
    if (index > 0 && index < self.dataArray.count - 1) {
        NSUInteger preIndex = index - 1;
        NSUInteger nextIndex = index + 1;
        
        if (preIndex >= 0 && preIndex < self.dataArray.count) {
            XRPhotoBrowserModel * photo = self.dataArray[preIndex];
            [photo releaseFinalImage];
        }
        
        if (nextIndex >= 0 && nextIndex < self.dataArray.count) {
            XRPhotoBrowserModel * photo = self.dataArray[nextIndex];
            [photo releaseFinalImage];
        }
    }
}

@end
