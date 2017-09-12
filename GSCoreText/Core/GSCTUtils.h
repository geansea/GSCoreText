//
//  GSCTUtils.h
//  GSCoreText
//
//  Created by geansea on 2017/9/6.
//
//

#import "GSCTFrame.h"
#import <CoreText/CoreText.h>

@interface GSCTUtils : NSObject

- (GSCTLine *)lineFromCTLine:(CTLineRef)ctLine
            attributedString:(NSAttributedString *)attributedString
                    vertical:(BOOL)vertical;

- (NSArray<GSCTGlyph *> *)glyphsFromCTLine:(CTLineRef)ctLine
                                    string:(NSString *)string
                                  vertical:(BOOL)vertical;

- (GSCTFrame *)horizontalFrameWithLines:(NSArray<GSCTLine *> *)lines rect:(CGRect)rect;

- (GSCTFrame *)verticalFrameWithLines:(NSArray<GSCTLine *> *)lines rect:(CGRect)rect;

- (BOOL)isNewline:(unichar)code;

- (BOOL)shouldAddGap:(unichar)code prevCode:(unichar)prevCode;

- (BOOL)canGlyphCompressLeft:(GSCTGlyph *)glyph;

- (BOOL)canGlyphCompressRight:(GSCTGlyph *)glyph;

- (BOOL)canBreak:(unichar)code prevCode:(unichar)prevCode;

- (BOOL)canStretch:(unichar)code prevCode:(unichar)prevCode;

@end
