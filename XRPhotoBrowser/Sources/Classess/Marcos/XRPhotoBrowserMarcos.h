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


#ifndef XRPhotoBrowserMarcos_h
#define XRPhotoBrowserMarcos_h

#import <Foundation/Foundation.h>

#if DEBUG
#define XRBrowserLog(m, ...)  NSLog(m, ## __VA_ARGS__)
#else
#define XRBrowserLog(m, ...)
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
static NSString * const NNKEY_XRPHOTOBROWSER_PHMANAGER_DOWNLOAD_IMAGE_FROM_ICLOUD = @"NNKEY_XR_PHMANAGER_DOWNLOAD_IMAGE_FROM_ICLOUD";

#endif /* XRPhotoBrowserMarcos_h */
