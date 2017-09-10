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

@end
