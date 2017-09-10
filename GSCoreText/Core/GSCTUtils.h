//
//  GSCTUtils.h
//  GSCoreText
//
//  Created by geansea on 2017/9/6.
//
//

#import "GSCTLine.h"
#import <CoreText/CoreText.h>

@interface GSCTUtils : NSObject

- (GSCTLine *)lineFromCTLine:(CTLineRef)ctLine
            attributedString:(NSAttributedString *)attributedString
                    vertical:(BOOL)vertical;

- (NSArray<GSCTGlyph *> *)glyphsFromCTLine:(CTLineRef)ctLine
                                    string:(NSString *)string
                                  vertical:(BOOL)vertical;

- (BOOL)shouldAddGap:(unichar)code prevCode:(unichar)prevCode;

- (BOOL)canCompressLeft:(unichar)code;

- (BOOL)canCompressRight:(unichar)code;

- (BOOL)canBreak:(unichar)code prevCode:(unichar)prevCode;

- (BOOL)canStretch:(unichar)code prevCode:(unichar)prevCode;

@end
