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
