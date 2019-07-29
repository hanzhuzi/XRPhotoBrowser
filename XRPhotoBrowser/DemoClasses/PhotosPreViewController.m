//
//  PhotosPreViewController.m
//  XRPhotoBrowser
//
//  Created by 徐冉 on 2019/7/18.
//  Copyright © 2019 QK. All rights reserved.
//

#import "PhotosPreViewController.h"
#import "XRPhotoBrowserMarcos.h"
#import "PhotoListCell.h"
#import "XRPhotoBrowserModel.h"
#import "XRPhotoBrowser.h"

#import <UIKit/UIKit.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface PhotosPreViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView * mainCollectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout * flowLayout;
@property (nonatomic, strong) NSArray * dataArray;

@end

@implementation PhotosPreViewController

- (void)dealloc {
    
    NSLog(@"%@ is dealloc!", self.class);
}

#pragma mark - Lazy

- (UICollectionViewFlowLayout *)flowLayout {
    
    if (nil == _flowLayout) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _flowLayout.sectionInset = UIEdgeInsetsMake(64 + 5, 5, 5, 5);
        _flowLayout.minimumLineSpacing = 5;
        _flowLayout.minimumInteritemSpacing = 5;
        CGFloat itemWidth = (XR_Main_Screen_Width - 10 - 15) / 4.0;
        _flowLayout.itemSize = CGSizeMake(itemWidth, itemWidth);
    }
    
    return _flowLayout;
}

- (UICollectionView *)mainCollectionView {
    
    if (nil == _mainCollectionView) {
        _mainCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, XR_Main_Screen_Width, XR_Main_Screen_Height) collectionViewLayout:self.flowLayout];
    }
    
    return _mainCollectionView;
}

#pragma mark - Setter

#pragma mark - Initlzations

- (void)setup {
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.mainCollectionView];
    
    self.mainCollectionView.backgroundColor = [UIColor whiteColor];
    self.mainCollectionView.showsVerticalScrollIndicator = NO;
    self.mainCollectionView.showsHorizontalScrollIndicator = NO;
    self.mainCollectionView.alwaysBounceVertical = YES;
    
    self.mainCollectionView.delegate = self;
    self.mainCollectionView.dataSource = self;
    
    // register collection cells
    [self.mainCollectionView registerClass:[PhotoListCell class] forCellWithReuseIdentifier:@"PhotoListCell"];
    [self.mainCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCellForNull"];
    
    if (@available(iOS 11.0, *)) {
        self.mainCollectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
}

#pragma mark - Life Cycles
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Web Photos";
    
    self.dataArray = @[
                       @"http://img.wxcha.com/file/201603/07/7ec4c7c1f7.jpg",
                       @"http://p3.pstatp.com/large/pgc-image/15251918032103439a7bfd0",
                       @"https://pub-static.haozhaopian.net/static/web/site/features/cn/crop/images/crop_20a7dc7fbd29d679b456fa0f77bd9525d.jpg",
                       @"http://p2-q.mafengwo.net/s13/M00/A0/2A/wKgEaVypsqCAS2lWAA3ARj9YRuU94.jpeg",
                       @"http://www.51pptmoban.com/d/file/2015/11/27/2123f7686d354b4d1b67b99a7f657747.jpg",
                       @"https://img0.sc115.com/uploads3/sc/jpgs/1809/zzpic14004_sc115.com.jpg",
                       @"http://img95.699pic.com/photo/50055/5642.jpg_wh300.jpg",
                       @"http://img.tupianzj.com/uploads/190715/29-1ZG5100454243.jpg",
                       @"http://www.fubaike.com/res/2019/07-10/a85dee6f7aefd8a46f72cd6b7153f94c.png",
                       @"http://img95.699pic.com/photo/40010/1502.jpg_wh860.jpg",
                       @"http://pic.616pic.com/bg_w1180/00/20/11/2NzhdfqJ4d.jpg",
                       @"http://sjbz.fd.zol-img.com.cn/t_s750x530c/g5/M00/00/02/ChMkJlfJVDiIDFWiAAfLkx7beOYAAU9vwBZBPgAB8ur798.jpg",
                       @"http://img02.tooopen.com/images/20150908/tooopen_sy_141843416414.jpg",
                       @"https://desk-fd.zol-img.com.cn/t_s960x600c5/g5/M00/02/05/ChMkJ1bKyUyIDBjLABf-1SUJOpIAALIMAHHrtgAF_7t974.jpg",
                       @"http://img.51miz.com/Element/00/87/60/07/091dec56_E876007_d5bb735a.jpg",
                       @"http://pic.10huan.com/pic16/b/r/11/20/10/9349.jpg",
                       @"http://pic.616pic.com/bg_w1180/00/23/86/oi7dQjjjpI.jpg",
                       @"http://img.tupianzj.com/uploads/allimg/190429/34-1Z429111500.jpg",
                       @"https://png.pngtree.com/thumb_back/fw800/background/20190223/ourmid/pngtree-autumn-grove-beautiful-background-design-backgroundtreesplantfallen-leavesillustration-backgroundadvertising-image_64758.jpg",
                       @"https://png.pngtree.com/thumb_back/fw800/background/20190109/pngtree-dream-gradual-change-aesthetic-winter-snow-forest-background-image_235.jpg",
                       @"http://pic1.win4000.com/wallpaper/1/5397c4c51171d.jpg",
                       @"http://t1.hxzdhn.com/uploads/allimg/20150417/zl4nczqp13t.jpg",
                       @"http://img02.tooopen.com/images/20150908/tooopen_sy_141843416414.jpg",
                       @"https://desk-fd.zol-img.com.cn/t_s960x600c5/g5/M00/02/05/ChMkJ1bKyUyIDBjLABf-1SUJOpIAALIMAHHrtgAF_7t974.jpg",
                       @"http://img.51miz.com/Element/00/87/60/07/091dec56_E876007_d5bb735a.jpg",
                       @"http://pic.10huan.com/pic16/b/r/11/20/10/9349.jpg",
                       @"http://pic.616pic.com/bg_w1180/00/23/86/oi7dQjjjpI.jpg",
                       @"http://img.tupianzj.com/uploads/allimg/190429/34-1Z429111500.jpg",
                       @"http://img02.tooopen.com/images/20150908/tooopen_sy_141843416414.jpg",
                       @"https://desk-fd.zol-img.com.cn/t_s960x600c5/g5/M00/02/05/ChMkJ1bKyUyIDBjLABf-1SUJOpIAALIMAHHrtgAF_7t974.jpg",
                       @"http://img.51miz.com/Element/00/87/60/07/091dec56_E876007_d5bb735a.jpg",
                       @"http://pic.10huan.com/pic16/b/r/11/20/10/9349.jpg",
                       @"http://pic.616pic.com/bg_w1180/00/23/86/oi7dQjjjpI.jpg",
                       @"http://img.tupianzj.com/uploads/allimg/190429/34-1Z429111500.jpg"
                       ];
    
    [self setup];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.mainCollectionView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
}

#pragma mark StatusBar 

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationFade;
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
    
    NSString * imgUrl = self.dataArray[indexPath.row];
    
    PhotoListCell * imageCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoListCell" forIndexPath:indexPath];
    [imageCell.imageView sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:nil];
    
    return imageCell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.item < self.dataArray.count) {
        
        PhotoListCell * cell = (PhotoListCell *)[collectionView cellForItemAtIndexPath:indexPath];
        
        NSMutableArray * photoArray = [[NSMutableArray alloc] init];
        
        for (NSString * urlStr in self.dataArray) {
            XRPhotoBrowserModel * photo = [XRPhotoBrowserModel photoBrowserModelWithURLString:urlStr];
            [photoArray addObject:photo];
        }
        
        XRPhotoBrowser * photoBrowser = [[XRPhotoBrowser alloc] init];
        photoBrowser.dataArray = photoArray;
        photoBrowser.isHideStatusBarForPhotoBrowser = YES;
        // 转场动画设置
        photoBrowser.animateImage = cell.imageView.image;
        photoBrowser.fromImageContentMode = cell.imageView.contentMode;
        photoBrowser.fromRect = [XRPhotoBrowser getTransitionAnimateImageViewFromRectWithImageView:cell.imageView targetView:self.view.window];
        
        [photoBrowser showPhotoBrowser:self displayAtIndex:indexPath.item];
    }
    
}

@end
