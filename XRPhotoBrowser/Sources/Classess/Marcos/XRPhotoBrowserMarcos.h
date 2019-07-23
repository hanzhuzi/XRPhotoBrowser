//
//  XRPhotoBrowserMarcos.h
//  XRPhotoBrowser
//
//  Created by 徐冉 on 2019/7/17.
//  Copyright © 2019 QK. All rights reserved.
//

#ifndef XRPhotoBrowserMarcos_h
#define XRPhotoBrowserMarcos_h

#import <Foundation/Foundation.h>

#if DEBUG
#define XRLog(m, ...)  NSLog(m, ## __VA_ARGS__)
#else
#define XRLog(m, ...)
#endif

#define XR_Main_Screen_Width [UIScreen mainScreen].bounds.size.width
#define XR_Main_Screen_Height [UIScreen mainScreen].bounds.size.height

#define UIColorFromRGB(rgbValue)\
\
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 \
alpha:1.0]

#define UIColorFromRGBAlpha(rgbValue,a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:(a)]

// Notification Key
static NSString * XRPHOTOBROWSER_IMAGE_LOAD_PROGRESS_CHANGED_NNKEY = @"XRPHOTOBROWSER_IMAGE_LOAD_PROGRESS_CHANGED_NNKEY";
static NSString * XRPHOTOBROWSER_IMAGE_LOAD_STATE_CHANGED_NNKEY = @"XRPHOTOBROWSER_IMAGE_LOAD_STATE_CHANGED_NNKEY";
static NSString * const NNKEY_XR_PHMANAGER_DOWNLOAD_IMAGE_FROM_ICLOUD = @"NNKEY_XR_PHMANAGER_DOWNLOAD_IMAGE_FROM_ICLOUD";

#endif /* XRPhotoBrowserMarcos_h */
