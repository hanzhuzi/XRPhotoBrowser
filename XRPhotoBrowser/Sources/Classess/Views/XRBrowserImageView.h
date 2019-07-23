//
//  XRBrowserImageView.h
//  XRPhotoBrowser
//
//  Created by 徐冉 on 2019/7/17.
//  Copyright © 2019 QK. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol XRBrowserImageViewDelegate <NSObject>

- (void)imageViewSingleTapAction;
- (void)imageViewDoubleTapAction:(UITouch *)touch;

@end

@interface XRBrowserImageView : UIImageView

@property (nonatomic, weak, nullable) id<XRBrowserImageViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
