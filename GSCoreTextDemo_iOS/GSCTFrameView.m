//
//  GSCTFrameView.m
//  GSCoreText
//
//  Created by geansea on 2017/9/10.
//
//

#import "GSCTFrameView.h"

@implementation GSCTFrameView

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    if (_gsFrame) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSaveGState(context);
        
        CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.0, -1.0));
        [_gsFrame drawInContext:context];
        [_gsFrame drawSublineInContext:context];
        
        CGContextRestoreGState(context);
    }
}

@end
