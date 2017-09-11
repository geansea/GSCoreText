//
//  GSCTFrame.m
//  GSCoreText
//
//  Created by geansea on 2017/9/6.
//
//

#import "GSCTFrame.h"

@implementation GSCTFrame

- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}

- (void)drawInContext:(CGContextRef)context {
    for (GSCTLine *line in _lines) {
        [line drawInContext:context];
    }
}

- (void)drawSublineInContext:(CGContextRef)context {
#if 1
    // Frame
    CGContextSetRGBStrokeColor(context, 1, 0, 0, 0.5);
    CGContextStrokeRectWithWidth(context, _usedRect, 1);
#endif
    
#if 1
    // Lines
    CGContextSetRGBStrokeColor(context, 0, 1, 0, 0.5);
    for (GSCTLine *line in _lines) {
        CGContextStrokeRectWithWidth(context, line.usedRect, 1);
    }
#endif
    
#if 1
    // Glyphs
    CGContextSetRGBStrokeColor(context, 0, 0, 1, 0.2);
    for (GSCTLine *line in _lines) {
        for (GSCTGlyph *glyph in line.glyphs) {
            CGRect bound = glyph.usedRect;
            bound.origin.x += line.x;
            bound.origin.y += line.y;
            CGContextStrokeRectWithWidth(context, bound, 1);
        }
    }
#endif
}

@end
