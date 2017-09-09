//
//  GSCTTypesetter.m
//  GSCoreText
//
//  Created by geansea on 2017/8/13.
//
//

#import "GSCTTypesetter.h"
#import "GSCTUtils.h"

@interface GSCTTypesetter () {
    CTTypesetterRef _ctTypesetter;
}

@property (strong) GSCTUtils *utils;
@property (copy)   NSAttributedString *attributedString;
@property (strong) NSMutableAttributedString *layoutString;

@end

@implementation GSCTTypesetter

- (instancetype)initWithString:(NSAttributedString *)attributedString {
    if (self = [super init]) {
        self.utils = [[GSCTUtils alloc] init];
        self.attributedString = attributedString;
        [self createLayoutString];
        _ctTypesetter = CTTypesetterCreateWithAttributedString((__bridge CFAttributedStringRef)_layoutString);
    }
    return self;
    
}

- (void)dealloc {
    CFRelease(_ctTypesetter);
}

- (GSCTLine *)createLineWithWidth:(CGFloat)width startIndex:(NSUInteger)startIndex {
    // Glyphs
    CGFloat tryWidth = width * 1.3;
    CFIndex length = CTTypesetterSuggestClusterBreak(_ctTypesetter, startIndex, tryWidth);
    CTLineRef ctLine = CTTypesetterCreateLine(_ctTypesetter, CFRangeMake(startIndex, length));
    NSArray<GSCTGlyph *> *tryGlyphs = [_utils glyphsFromCTLine:ctLine string:_layoutString.string vertical:NO];
    
    [self compressGlyphs:tryGlyphs];
    
    NSUInteger breakPos = [self breakPosForGlyphs:tryGlyphs withWidth:width];
    NSArray<GSCTGlyph *> *glyphs = [tryGlyphs subarrayWithRange:NSMakeRange(0, breakPos)];
    
    [self adjustGlyphs:glyphs withWidth:width];
    
    // Line infos
    NSRange lineRange = NSMakeRange(0, 0);
    CGFloat lineLeft = 0;
    CGFloat lineRight = 0;
    if (glyphs.count > 0) {
        GSCTGlyph *first = glyphs.firstObject;
        GSCTGlyph *last = glyphs.lastObject;
        lineRange.location = first.range.location;
        lineRange.length = NSMaxRange(last.range) - lineRange.location;
        lineLeft = CGRectGetMinX(first.usedRect);
        lineRight = CGRectGetMaxX(last.usedRect);
    }
    CGFloat lineTop = 0;
    CGFloat lineBottom = 0;
    for (GSCTGlyph *glyph in glyphs) {
        lineTop = MIN(lineTop, CGRectGetMinY(glyph.usedRect));
        lineBottom = MAX(lineBottom, CGRectGetMaxY(glyph.usedRect));
    }
    GSCTLine *line = [[GSCTLine alloc] init];
    line.range = lineRange;
    line.string = [_layoutString.string substringWithRange:line.range];
    line.glyphs = glyphs;
    line.origin = CGPointZero;
    line.rect = CGRectMake(0, lineTop, width, lineBottom - lineTop);
    line.usedRect = CGRectMake(lineLeft, lineTop, lineRight - lineLeft, lineBottom - lineTop);
    line.vertical = NO;
    return line;
}

#pragma mark - Private

- (void)createLayoutString {
    self.layoutString = [[NSMutableAttributedString alloc] initWithString:_attributedString.string];
    NSRange totalRange = NSMakeRange(0, _layoutString.length);
    CTFontRef font = (__bridge CTFontRef)[GSFont systemFontOfSize:_fontSize];
    [_layoutString addAttribute:(__bridge NSString *)kCTFontAttributeName value:(__bridge id)font range:totalRange];
    [_attributedString enumerateAttributesInRange:totalRange options:0 usingBlock:^(NSDictionary<NSString *, id> *attrs, NSRange range, BOOL *stop) {
        ;
    }];
}

- (void)compressGlyphs:(NSArray<GSCTGlyph *> *)glyphs {
    
}

- (NSUInteger)breakPosForGlyphs:(NSArray<GSCTGlyph *> *)glyphs withWidth:(CGFloat)width {
    return 0;
}

- (void)adjustGlyphs:(NSArray<GSCTGlyph *> *)glyphs withWidth:(CGFloat)width {
    
}

@end
