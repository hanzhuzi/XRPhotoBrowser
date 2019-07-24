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

#import "XRPhotoPickerAssetCell.h"
#import "XRPhotoBrowserMarcos.h"
#import "UIImage+XRPhotoBrowser.h"

#define XR_PhotoAsset_Grid_Border ([UIScreen mainScreen].bounds.size.width < 375.0 ? 2.0 : 5.0)

@implementation XRPhotoPickerAssetCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        _assetImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:_assetImageView];
        
        _progressLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _progressLbl.center = CGPointMake(CGRectGetWidth(frame) * 0.5, CGRectGetHeight(frame) * 0.5);
        [self addSubview:_progressLbl];
        
        _progressLbl.backgroundColor = UIColorFromRGBAlpha(0x000000, 0.65);
        _progressLbl.textColor = UIColorFromRGBAlpha(0xFFFFFF, 1);
        _progressLbl.textAlignment = NSTextAlignmentCenter;
        _progressLbl.font = [UIFont systemFontOfSize:14];
        _progressLbl.hidden = YES;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _assetImageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    
    _progressLbl.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    _progressLbl.center = CGPointMake(CGRectGetWidth(self.frame) * 0.5, CGRectGetHeight(self.frame) * 0.5);
}

@end
