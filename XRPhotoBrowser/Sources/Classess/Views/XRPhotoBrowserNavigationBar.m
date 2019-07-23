//
//  XRPhotoBrowserNavigationBar.m
//  XRPhotoBrowser
//
//  Created by 徐冉 on 2019/7/23.
//  Copyright © 2019 QK. All rights reserved.
//

#import "XRPhotoBrowserNavigationBar.h"

@interface XRPhotoBrowserNavigationBar ()

@property (nonatomic, strong) UILabel * titleLbl;
@property (nonatomic, strong) UIButton * leftBtn;
@property (nonatomic, strong) UIButton * rightBtn;

@end

@implementation XRPhotoBrowserNavigationBar

- (instancetype)init {
    self = [super init];
    
    if (self) {
        [self setup];
        return self;
    }
    
    return nil;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setup];
        return self;
    }
    
    return nil;
}

- (void)setup {
    
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.16];
    
    self.titleLbl = [[UILabel alloc] init];
    [self addSubview:self.titleLbl];
    self.titleLbl.textColor = [UIColor whiteColor];
    self.titleLbl.textAlignment = NSTextAlignmentCenter;
    self.titleLbl.font = [UIFont boldSystemFontOfSize:16];
    
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    CGFloat titleLblWidth = 200;
    CGFloat titleLblHeight = 44;
    CGFloat titleLblX = (bounds.size.width - titleLblWidth) * 0.5;
    CGFloat titleLblY = 20;
    self.titleLbl.frame = CGRectMake(titleLblX, titleLblY, titleLblWidth, titleLblHeight);
}

- (void)setNav_title:(NSString *)nav_title {
    
    _nav_title = nav_title;
    self.titleLbl.text = _nav_title;
}

@end
