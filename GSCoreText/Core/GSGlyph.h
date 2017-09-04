//
//  GSGlyph.h
//  GSCoreText
//
//  Created by geansea on 2017/8/25.
//
//

#import "GSCTDefines.h"

@interface GSGlyph : NSObject

@property (nonatomic, assign) NSRange    srcRange;
@property (nonatomic, copy)   NSString * srcString;
@property (nonatomic, assign) CGGlyph    glyph;
@property (nonatomic, assign) BOOL       canBreakBefore;
@property (nonatomic, assign) BOOL       canStretchBefore;
@property (nonatomic, strong) GSFont *   font;
@property (nonatomic, strong) GSColor *  color;
@property (nonatomic, assign) CGPoint    drawPos;
@property (nonatomic, assign) CGRect     visibleBound;

- (unichar)utf16Code;
- (UTF32Char)utf32Code;
- (CGRect)bound;

@end
