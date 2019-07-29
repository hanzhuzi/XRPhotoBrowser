//
//  ViewController.m
//  XRPhotoBrowser
//
//  Created by 徐冉 on 2019/7/15.
//  Copyright © 2019 QK. All rights reserved.
//

#import "ViewController.h"
#import "XRPhotoBrowser.h"
#import "XRPhotoBrowserModel.h"
#import "PhotosPreViewController.h"
#import "XRPhotoPickerViewController.h"

#import <SDWebImage/SDWebImageManager.h>
#import <SDWebImage/SDImageCache.h>

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@property (nonatomic, strong) NSMutableArray * dataArray;
@property (nonatomic, strong) NSArray * cellTitleArray;

@property (nonatomic, strong) XRPhotoPickerViewController * photoPicker;

@end

@implementation ViewController

@synthesize dataArray = dataArray;

- (void)loadPhotos {
    
    XRPhotoBrowserModel * model1 = [XRPhotoBrowserModel photoBrowserModelWithURLString:@"http://pic37.nipic.com/20140113/8800276_184927469000_2.png"];
    XRPhotoBrowserModel * model2 = [XRPhotoBrowserModel photoBrowserModelWithURLString:@"http://img.redocn.com/sheji/20141219/zhongguofengdaodeliyizhanbanzhijing_3744115.jpg"];
    XRPhotoBrowserModel * model3 = [XRPhotoBrowserModel photoBrowserModelWithURLString:@"http://pic31.nipic.com/20130801/11604791_100539834000_2.jpg"];
    XRPhotoBrowserModel * model4 = [XRPhotoBrowserModel photoBrowserModelWithURLString:@"http://pic27.nipic.com/20130325/11918471_071536564166_2.jpg"];
    XRPhotoBrowserModel * model5 = [XRPhotoBrowserModel photoBrowserModelWithURLString:@"http://pic27.nipic.com/20130325/11918471_071536564166.jpg"];
    //http://img5.duitang.com/uploads/item/201507/04/20150704082822_neLMC.thumb.700_0.jpeg
    XRPhotoBrowserModel * model6 = [XRPhotoBrowserModel photoBrowserModelWithURLString:@"http://img5.duitang.com/uploads/item/201507/04/20150704082822_neLMC.thumb.700_0.jpeg"];
    XRPhotoBrowserModel * model7 = [XRPhotoBrowserModel photoBrowserModelWithURLString:@"http://b-ssl.duitang.com/uploads/item/201707/24/20170724102404_wAjaP.png"];
    NSURL * fileUrl = [[NSBundle mainBundle] URLForResource:@"01.jpg" withExtension:nil];
    XRPhotoBrowserModel * model8 = [XRPhotoBrowserModel photoBrowserModelWithURL:fileUrl];
    XRPhotoBrowserModel * model9 = [XRPhotoBrowserModel photoBrowserModelWithURL:[NSURL URLWithString:@"http://img.lanrentuku.com/img/allimg/1609/14747974667766.jpg"]];
    XRPhotoBrowserModel * model10 = [XRPhotoBrowserModel photoBrowserModelWithImage:[UIImage imageNamed:@"02.jpg"]];
    
    XRPhotoBrowserModel * model11 = [XRPhotoBrowserModel photoBrowserModelWithData:[NSData dataWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"02.jpg" withExtension:nil]]];
    XRPhotoBrowserModel * model12 = [XRPhotoBrowserModel photoBrowserModelWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://static.runoob.com/images/demo/demo4.jpg"]]];

    NSArray * urls = @[
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
                       @"https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR8dC1yjTy7zUUtZWJ8qTlZMjFts4Edx2krl4bCH5uH5Wv1U6OssQ",
                       @"http://img02.tooopen.com/images/20150908/tooopen_sy_141843416414.jpg",
                       @"https://desk-fd.zol-img.com.cn/t_s960x600c5/g5/M00/02/05/ChMkJ1bKyUyIDBjLABf-1SUJOpIAALIMAHHrtgAF_7t974.jpg",
                       @"http://img.51miz.com/Element/00/87/60/07/091dec56_E876007_d5bb735a.jpg",
                       @"http://pic.10huan.com/pic16/b/r/11/20/10/9349.jpg",
                       @"http://pic.616pic.com/bg_w1180/00/23/86/oi7dQjjjpI.jpg",
                       @"http://img.tupianzj.com/uploads/allimg/190429/34-1Z429111500.jpg",
                       @"https://png.pngtree.com/thumb_back/fw800/background/20190223/ourmid/pngtree-autumn-grove-beautiful-background-design-backgroundtreesplantfallen-leavesillustration-backgroundadvertising-image_64758.jpg",
                       @"https://png.pngtree.com/thumb_back/fw800/background/20190109/pngtree-dream-gradual-change-aesthetic-winter-snow-forest-background-image_235.jpg",
                       @"http://pic1.win4000.com/wallpaper/1/5397c4c51171d.jpg",
                       @"http://t1.hxzdhn.com/uploads/allimg/20150417/zl4nczqp13t.jpg"
                       ];
    
    for (NSString * urlString in urls) {
        XRPhotoBrowserModel * model = [XRPhotoBrowserModel photoBrowserModelWithURLString:urlString];
        [self.dataArray addObject:model];
    }
    
    [dataArray addObject:model1];
    [dataArray addObject:model2];
    [dataArray addObject:model3];
    [dataArray addObject:model4];
    [dataArray addObject:model5];
    [dataArray addObject:model6];
    [dataArray addObject:model7];
    [dataArray addObject:model8];
    [dataArray addObject:model9];
    [dataArray addObject:model10];
    [dataArray addObject:model11];
    [dataArray addObject:model12];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.cellTitleArray = @[@"预览一组图片>>>", @"预览一组网络图片>>>", @"照片库图片>>>", @"清理图片缓存"];
    
    self.dataArray = [NSMutableArray array];
    
    [self loadPhotos];
    
    if (@available(iOS 11.0, *)) {
        self.mainTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    [self.mainTableView reloadData];
    
}

#pragma mark - Actions

- (void)previewPhotosAction {
    
    XRPhotoBrowser * photoBrowser = [[XRPhotoBrowser alloc] init];
    photoBrowser.displayAtIndex = 2;
    photoBrowser.dataArray = dataArray;
    
    [photoBrowser showPhotoBrowser:self];
}

- (void)cleanCachesAction {
    
    [[SDImageCache sharedImageCache] clearDiskOnCompletion:^{
        
    }];
    
    [[SDImageCache sharedImageCache] clearMemory];
}

#pragma mark - UITableViewDelegate & DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.cellTitleArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCellIDForList"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCellIDForList"];
    }
    
    NSString * cellTitle = self.cellTitleArray[indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.textLabel.text = cellTitle;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 0:
        {
            [self previewPhotosAction];
        }
            break;
        case 1:
        {
            PhotosPreViewController * photoListCtrl = [[PhotosPreViewController alloc] init];
            [self.navigationController pushViewController:photoListCtrl animated:YES];
        }
            break;
        case 2:
        {
            self.photoPicker = [[XRPhotoPickerViewController alloc] init];
            self.photoPicker.delegate = self;
            self.photoPicker.isPortrait = YES;
            self.photoPicker.isAllowCrop = YES;
            self.photoPicker.isAllowMultipleSelect = NO;
            self.photoPicker.isSupportCamera = YES;
            self.photoPicker.cropSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width);
            [self.navigationController pushViewController:self.photoPicker animated:true];
        }
            break;
        case 3:
        {
            [self cleanCachesAction];
        }
            break;
        default:
            break;
    }
}

@end
