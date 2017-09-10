//
//  GSCTFramesetter.m
//  GSCoreText
//
//  Created by geansea on 2017/9/6.
//
//

#import "GSCTFramesetter.h"
#import "GSCTUtils.h"

@interface GSCTFramesetter () {
    CTFramesetterRef _ctFramesetter;
}

@property (strong) GSCTUtils *utils;
@property (copy)   NSAttributedString *attributedString;
@property (strong) NSMutableAttributedString *layoutString;

@end

@implementation GSCTFramesetter

- (instancetype)initWithString:(NSAttributedString *)attributedString {
    if (self = [super init]) {
        self.fontSize = 16;
        self.indent = 0;
        self.alignment = NSTextAlignmentLeft;
        self.vertical = NO;
        self.utils = [[GSCTUtils alloc] init];
        self.attributedString = attributedString;
        [self createLayoutString];
        _ctFramesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)_layoutString);
    }
    return self;
}

- (void)dealloc {
    CFRelease(_ctFramesetter);
}

- (GSCTFrame *)createFrameWithRect:(CGRect)rect startIndex:(NSUInteger)startIndex {
    CGPathRef path = CGPathCreateWithRect(rect, NULL);
    GSCTFrame *frame = [self createFrameWithPath:path startIndex:startIndex];
    CGPathRelease(path);
    return frame;
}

- (GSCTFrame *)createFrameWithPath:(CGPathRef)path startIndex:(NSUInteger)startIndex {
    NSMutableDictionary<NSString *, id> *attributes = [NSMutableDictionary dictionary];
    [attributes setObject:@(_vertical ? kCTFrameProgressionRightToLeft : kCTFrameProgressionTopToBottom) forKey:(__bridge NSString *)kCTFrameProgressionAttributeName];
    CTFrameRef ctFrame = CTFramesetterCreateFrame(_ctFramesetter, CFRangeMake(startIndex, _layoutString.length - startIndex), path, (__bridge CFDictionaryRef)attributes);
    
    CFRelease(ctFrame);
    return nil;
}

#pragma mark - Private

- (void)createLayoutString {
    self.layoutString = [[NSMutableAttributedString alloc] initWithString:_attributedString.string];
    NSRange totalRange = NSMakeRange(0, _layoutString.length);
    CTFontRef baseCTFont = (__bridge CTFontRef)[GSFont systemFontOfSize:_fontSize];
    [_layoutString addAttribute:(__bridge NSString *)kCTFontAttributeName value:(__bridge id)baseCTFont range:totalRange];
    [_attributedString enumerateAttributesInRange:totalRange options:0 usingBlock:^(NSDictionary<NSString *, id> *attrs, NSRange range, BOOL *stop) {
        GSFont *font = [attrs objectForKey:NSFontAttributeName];
        if (font && [font isKindOfClass:[GSFont class]]) {
            CTFontRef ctFont = (__bridge CTFontRef)font;
            [_layoutString addAttribute:(__bridge NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:range];
        }
    }];
}

@end
