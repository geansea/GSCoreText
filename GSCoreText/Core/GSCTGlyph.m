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

- (CGRect)rect {
    return CGRectMake(_x,
                      _y - _ascent,
                      _width,
                      _ascent + _descent);
}

- (CGRect)usedRect {
    return CGRectMake(_x + _compressLeft,
                      _y - _ascent,
                      _width - _compressLeft - _compressRight,
                      _ascent + _descent);
}

@end
