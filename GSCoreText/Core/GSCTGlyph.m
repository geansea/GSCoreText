//
//  GSCTGlyph.m
//  GSCoreText
//
//  Created by geansea on 2017/9/6.
//
//

#import "GSCTGlyph.h"

@implementation GSCTGlyph

- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}

- (unichar)utf16Code {
    return [_string characterAtIndex:0];
}

@end
