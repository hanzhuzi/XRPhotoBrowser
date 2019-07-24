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

#import "XRPhotoBrowserLoadingView.h"

@interface XRPhotoBrowserLoadingView ()

@property (nonatomic, strong) CAShapeLayer * circleLayer;

@end

@implementation XRPhotoBrowserLoadingView

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
    
    self.backgroundColor = [UIColor clearColor];
    
    self.progressLineWidth = 7.0;
    
    self.circleLayer = [CAShapeLayer layer];
    self.circleLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    
    [self.layer addSublayer:self.circleLayer];
    
    self.circleLayer.backgroundColor = [UIColor clearColor].CGColor;
    self.circleLayer.fillColor = [UIColor clearColor].CGColor;
    self.circleLayer.lineCap = kCALineCapRound;
    self.circleLayer.lineJoin = kCALineJoinRound;
    
    self.circleLayer.lineWidth = self.progressLineWidth;
    self.circleLayer.strokeColor = [UIColor whiteColor].CGColor;
    
    CGPoint center = CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height * 0.5);
    CGFloat radius = (self.bounds.size.width - _progressLineWidth * 2.0) * 0.5;
    
    UIBezierPath * path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:0 endAngle:(M_PI / 180.0) * 360 clockwise:YES];
    
    self.circleLayer.path = path.CGPath;
    
    self.circleLayer.strokeStart = 0;
    self.circleLayer.strokeEnd = 0;
}

- (void)setProgress:(double)progress {
    
    if (_progress != progress) {
        _progress = progress;
        _progress = _progress < 0 ? 0 : _progress;
        _progress = _progress > 1 ? 1 : _progress;
    }
    
    self.circleLayer.strokeEnd = _progress;
    
    if (_progress >= 1.0) {
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:0.2 animations:^{
            weakSelf.alpha = 0;
        } completion:^(BOOL finished) {
            weakSelf.alpha = 0;
        }];
    }
    else {
        if (self.alpha < 1) {
            self.alpha = 1;
            self.hidden = NO;
        }
    }
}

- (void)setProgressLineWidth:(CGFloat)progressLineWidth {
    
    _progressLineWidth = progressLineWidth;
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.circleLayer.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    
    CGPoint center = CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height * 0.5);
    CGFloat radius = (self.bounds.size.width - _progressLineWidth * 2.0) * 0.5;
    
    UIBezierPath * path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:0 endAngle:(M_PI / 180.0) * 360 clockwise:YES];
    
    self.circleLayer.path = path.CGPath;
    
    self.circleLayer.strokeEnd = _progress;
}

@end
