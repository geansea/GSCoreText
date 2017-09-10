//
//  GSCTGlyph.h
//  GSCoreText
//
//  Created by geansea on 2017/9/6.
//
//

#import "GSCTDefines.h"

@interface GSCTGlyph : NSObject

@property (assign) NSRange range;
@property (copy)   NSString *string;
@property (assign) CGGlyph glyph;
@property (strong) GSFont *font;
@property (assign) CGFloat x;
@property (assign) CGFloat y;
@property (assign) CGFloat ascent;
@property (assign) CGFloat descent;
@property (assign) CGFloat width;
@property (assign) CGFloat compressLeft;
@property (assign) CGFloat compressRight;
@property (assign) BOOL vertical;

- (unichar)utf16Code;
- (CGPoint)drawPos;
- (CGRect)rect;
- (CGRect)usedRect;

@end
