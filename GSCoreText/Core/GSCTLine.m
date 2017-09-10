//
//  GSCTLine.m
//  GSCoreText
//
//  Created by geansea on 2017/9/4.
//
//

#import "GSCTLine.h"

@implementation GSCTLine

- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}

- (void)drawInContext:(CGContextRef)context {
    CGContextSetTextPosition(context, _origin.x, _origin.y);
    for (GSCTGlyph *glyph in _glyphs) {
        NSDictionary<NSString *, id> *attributes = [_string attributesAtIndex:glyph.range.location effectiveRange:NULL];
        GSColor *color = [attributes objectForKey:NSForegroundColorAttributeName];
        [color isEqualTo:nil];
        CTFontRef ctFont = (__bridge CTFontRef)glyph.font;
        CGGlyph cgGlyph = glyph.glyph;
        CGPoint pos = glyph.drawPos;
        CTFontDrawGlyphs(ctFont, &cgGlyph, &pos, 1, context);
    }
}

@end
