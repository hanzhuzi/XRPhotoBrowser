//
//  XRBrowserImageView.m
//  XRPhotoBrowser
//
//  Created by 徐冉 on 2019/7/17.
//  Copyright © 2019 QK. All rights reserved.
//

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
    
    XRLog(@"singleTapAction");
    if (self.delegate && [self.delegate respondsToSelector:@selector(imageViewSingleTapAction)]) {
        [self.delegate imageViewSingleTapAction];
    }
}

- (void)doubleTapAction:(UITouch *)touch {
    
    XRLog(@"doubleTapAction");
    if (self.delegate && [self.delegate respondsToSelector:@selector(imageViewDoubleTapAction:)]) {
        [self.delegate imageViewDoubleTapAction:touch];
    }
}

@end
