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

#import "XRBrowserImageView.h"
#import "XRPhotoBrowserMarcos.h"

@implementation XRBrowserImageView

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
    
    self.userInteractionEnabled = YES;
}

// 系统手势识别单，双击使用requireGestureRecognizerToFail:，单击调用会有延迟，这里虽然也会延迟，不过小一些。
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    UITouch * touch = [touches anyObject];
    
    if (touch.tapCount == 1) {
        [self performSelector:@selector(singleTapAction) withObject:nil afterDelay:0.29];
    }
    else if (touch.tapCount == 2) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(singleTapAction) object:nil];
        
        [self doubleTapAction:touch];
    }
    
    [super touchesBegan:touches withEvent:event];
}

#pragma mark - Action

- (void)singleTapAction {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(imageViewSingleTapAction)]) {
        [self.delegate imageViewSingleTapAction];
    }
}

- (void)doubleTapAction:(UITouch *)touch {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(imageViewDoubleTapAction:)]) {
        [self.delegate imageViewDoubleTapAction:touch];
    }
}

@end
