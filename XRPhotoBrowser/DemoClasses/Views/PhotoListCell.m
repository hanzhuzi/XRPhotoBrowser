//
//  PhotoListCell.m
//  XRPhotoBrowser
//
//  Created by 徐冉 on 2019/7/18.
//  Copyright © 2019 QK. All rights reserved.
//

#import "PhotoListCell.h"

@interface PhotoListCell ()

@end

@implementation PhotoListCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        
        [self setup];
        return self;
    }
    
    return nil;
}

- (void)setup {
    
    self.backgroundColor = [UIColor whiteColor];
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    self.imageView = [[UIImageView alloc] init];
    self.imageView.frame = self.bounds;
    self.imageView.contentMode = UIViewContentModeScaleToFill;
    
    [self.contentView addSubview:self.imageView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageView.frame = self.bounds;
}

@end
