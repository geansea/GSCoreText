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
        [line drawInContext:context move:_rect.origin];
    }
}

- (void)drawSublineInContext:(CGContextRef)context {
#if 1
    // Frame
    CGContextSetRGBStrokeColor(context, 1, 0, 0, 0.5);
    CGContextStrokeRectWithWidth(context, _rect, 1);
#endif
    
#if 1
    // Lines
    CGContextSetRGBStrokeColor(context, 0, 1, 0, 0.5);
    for (GSCTLine *line in _lines) {
        CGRect bound = line.rect;
        bound.origin.x += _rect.origin.x;
        bound.origin.y += _rect.origin.y;
        CGContextStrokeRectWithWidth(context, bound, 1);
    }
#endif
    
#if 1
    // Glyphs
    CGContextSetRGBStrokeColor(context, 0, 0, 1, 0.2);
    for (GSCTLine *line in _lines) {
        for (GSCTGlyph *glyph in line.glyphs) {
            CGRect bound = glyph.usedRect;
            bound.origin.x += _rect.origin.x + line.x;
            bound.origin.y += _rect.origin.x + line.y;
            CGContextStrokeRectWithWidth(context, bound, 1);
        }
    }
#endif
}

@end
