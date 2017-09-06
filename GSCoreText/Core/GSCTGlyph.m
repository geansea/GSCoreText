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

- (UTF32Char)utf32Code {
    UTF32Char code = 0;
    //if ([_string getBytes:&code maxLength:4 usedLength:NULL encoding:NSUTF32LittleEndianStringEncoding options:0 range:NSMakeRange(0, 1) remainingRange:NULL]) {
    //    code = NSSwapLittleIntToHost(code);
    //}
    return code;
}

@end
