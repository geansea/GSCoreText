//
//  GSCTDefines.h
//  GSCoreText
//
//  Created by geansea on 2017/8/13.
//
//

#import <Foundation/Foundation.h>

// Compatibility
#if TARGET_OS_IOS

#import <UIKit/UIKit.h>
@compatibility_alias GSColor UIColor;
@compatibility_alias GSImage UIImage;
@compatibility_alias GSFont UIFont;
#define GSRectMake(x, y, w, h) CGRectMake(x, y, w, h)
#define GSSizeMake(w, h) CGSizeMake(w, h)

#else

#import <AppKit/AppKit.h>
@compatibility_alias GSColor NSColor;
@compatibility_alias GSImage NSImage;
@compatibility_alias GSFont NSFont;
#define GSRectMake(x, y, w, h) NSMakeRect(x, y, w, h)
#define GSSizeMake(w, h) NSMakeSize(w, h)

#endif
