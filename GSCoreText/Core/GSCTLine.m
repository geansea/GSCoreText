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

- (void)drawInContext:(CGContextRef)context {
    CGContextSetTextPosition(context, _origin.x, _origin.y);
    //CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.0, -1.0));
    for (GSCTGlyph *glyph in _glyphs) {
        NSUInteger glyphLocation = glyph.range.location - _range.location;
        NSDictionary<NSString *, id> *attributes = [_string attributesAtIndex:glyphLocation effectiveRange:NULL];
        //GSColor *color = [attributes objectForKey:NSForegroundColorAttributeName];
        CTFontRef ctFont = (__bridge CTFontRef)glyph.font;
        CGGlyph cgGlyph = glyph.glyph;
        CGPoint pos = glyph.drawPos;
        CTFontDrawGlyphs(ctFont, &cgGlyph, &pos, 1, context);
    }
}

@end
