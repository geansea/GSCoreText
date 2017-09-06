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
@property (strong) GSColor *color;
@property (assign) CGPoint drawPos;
@property (assign) CGRect rect;
@property (assign) CGRect usedRect;

- (unichar)utf16Code;
- (UTF32Char)utf32Code;

@end
