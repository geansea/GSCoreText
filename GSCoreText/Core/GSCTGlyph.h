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
@property (assign) CGPoint origin;
@property (assign) CGRect rect;
@property (assign) CGRect usedRect;
@property (assign) BOOL vertical;

- (unichar)utf16Code;

@end
