//
//  GSCTLine.m
//  GSCoreText
//
//  Created by geansea on 2017/9/4.
//
//

#import "GSCTLine.h"
#import <CoreText/CoreText.h>

@implementation GSCTLine

- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}

- (CGRect)usedRect {
    if (_vertical) {
        return CGRectMake(_x - _descent,
                          _y,
                          _ascent + _descent,
                          _usedWidth);
    } else {
        return CGRectMake(_x,
                          _y - _ascent,
                          _usedWidth,
                          _ascent + _descent);
    }
}

- (void)drawInContext:(CGContextRef)context {
    CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.0, -1.0));
    for (GSCTGlyph *glyph in _glyphs) {
        NSUInteger glyphLocation = glyph.range.location - _range.location;
        NSDictionary<NSString *, id> *attributes = [_string attributesAtIndex:glyphLocation effectiveRange:NULL];
        GSColor *color = attributes[NSForegroundColorAttributeName] ? : [GSColor blackColor];
        CGContextSetFillColorWithColor(context, color.CGColor);
        CTFontRef ctFont = (__bridge CTFontRef)glyph.font;
        CGGlyph cgGlyph = glyph.glyph;
        CGContextSetTextPosition(context, round(_x + glyph.x), round(_y + glyph.y));
        CTFontDrawGlyphs(ctFont, &cgGlyph, &CGPointZero, 1, context);
    }
}

@end
