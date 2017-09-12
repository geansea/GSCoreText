//
//  GSCTUtils.m
//  GSCoreText
//
//  Created by geansea on 2017/9/6.
//
//

#import "GSCTUtils.h"

@interface GSCTUtils ()

@property (strong) NSMutableData *glyphsData;
@property (strong) NSMutableData *indicesData;
@property (strong) NSMutableData *positionsData;
@property (strong) NSMutableData *advancesData;

@property (strong) NSMutableIndexSet *compressLeftSet;
@property (strong) NSMutableIndexSet *compressRightSet;
@property (strong) NSMutableIndexSet *notLineBeginSet;
@property (strong) NSMutableIndexSet *notLineEndSet;

@end

@implementation GSCTUtils

- (instancetype)init {
    if (self = [super init]) {
        self.glyphsData = [NSMutableData data];
        self.indicesData = [NSMutableData data];
        self.positionsData = [NSMutableData data];
        self.advancesData = [NSMutableData data];
    }
    return self;
}

- (GSCTLine *)lineFromCTLine:(CTLineRef)ctLine
            attributedString:(NSAttributedString *)attributedString
                    vertical:(BOOL)vertical {
    CFRange lineRange = CTLineGetStringRange(ctLine);
    CGFloat lineAscent = 0;
    CGFloat lineDescent = 0;
    CGFloat lineWidth = CTLineGetTypographicBounds(ctLine, &lineAscent, &lineDescent, NULL);
    
    GSCTLine *line = [[GSCTLine alloc] init];
    line.range = NSMakeRange(lineRange.location, lineRange.length);
    line.string = [attributedString attributedSubstringFromRange:line.range];
    line.glyphs = [self glyphsFromCTLine:ctLine string:attributedString.string vertical:vertical];
    line.x = 0;
    line.y = 0;
    line.ascent = lineAscent;
    line.descent = lineDescent;
    line.usedWidth = lineWidth;
    line.vertical = vertical;
    return line;
}

- (NSArray<GSCTGlyph *> *)glyphsFromCTLine:(CTLineRef)ctLine
                                    string:(NSString *)string
                                  vertical:(BOOL)vertical {
    CFIndex glyphCount = CTLineGetGlyphCount(ctLine);
    NSMutableArray<GSCTGlyph *> *lineGlyphs = [NSMutableArray arrayWithCapacity:glyphCount];
    CFArrayRef runs = CTLineGetGlyphRuns(ctLine);
    for (CFIndex idx = 0; idx < CFArrayGetCount(runs); ++idx) {
        CTRunRef run = (CTRunRef)CFArrayGetValueAtIndex(runs, idx);
        // Run infos
        CFIndex glyphCount = CTRunGetGlyphCount(run);
        CFRange runRange = CTRunGetStringRange(run);
        CGFloat runAscent = 0;
        CGFloat runDescent = 0;
        CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &runAscent, &runDescent, NULL);
        const CGGlyph *glyphs = [self glyphsForRun:run];
        const CFIndex *indices = [self indicesForRun:run];
        const CGPoint *positions = [self positionsForRun:run];
        const CGSize *advances = [self advancesForRun:run];
        // Run attributes
        CFDictionaryRef attributes = CTRunGetAttributes(run);
        CTFontRef font = CFDictionaryGetValue(attributes, kCTFontAttributeName);
        if (vertical) {
            CGRect fontBounding = CTFontGetBoundingBox(font);
            CGFloat heightScale = CTFontGetSize(font) / CGRectGetHeight(fontBounding);
            runAscent = CGRectGetMaxY(fontBounding) * heightScale;
            runDescent = -CGRectGetMinY(fontBounding) * heightScale;
        }
        for (CFIndex i = 0; i < glyphCount; ++i) {
            CFIndex endIndex = runRange.location + runRange.length;
            if (i + 1 < glyphCount) {
                endIndex = indices[i + 1];
            }
            GSCTGlyph *glyph = [[GSCTGlyph alloc] init];
            glyph.range = NSMakeRange(indices[i], endIndex - indices[i]);
            glyph.string = [string substringWithRange:glyph.range];
            glyph.glyph = glyphs[i];
            glyph.font = (__bridge GSFont *)font;
            glyph.x = positions[i].x;
            glyph.y = -positions[i].y;
            if (vertical) {
                BOOL isNewline = [self isNewline:glyph.utf16Code];
                glyph.ascent = isNewline ? 0 : runAscent;
                glyph.descent = isNewline ? 0 : runDescent;
                glyph.width = -glyph.x * 2;
            } else {
                glyph.ascent = runAscent;
                glyph.descent = runDescent;
                glyph.width = advances[i].width;
            }
            [lineGlyphs addObject:glyph];
        }
    }
    return lineGlyphs;
}

- (BOOL)isNewline:(unichar)code {
    return ('\r' == code || '\n' == code);
}

- (BOOL)shouldAddGap:(unichar)code prevCode:(unichar)prevCode {
    if ([self isAlphaDigit:prevCode] && [self isCjk:code]) {
        return YES;
    }
    if ([self isCjk:prevCode] && [self isAlphaDigit:code]) {
        return YES;
    }
    return NO;
}

- (BOOL)canGlyphCompressLeft:(GSCTGlyph *)glyph {
    if (glyph.width < glyph.font.pointSize * 0.9) {
        return NO;
    }
    return [self canCompressLeft:glyph.utf16Code];
}

- (BOOL)canGlyphCompressRight:(GSCTGlyph *)glyph {
    if (glyph.width < glyph.font.pointSize * 0.9) {
        return NO;
    }
    return [self canCompressRight:glyph.utf16Code];
}

- (BOOL)canBreak:(unichar)code prevCode:(unichar)prevCode {
    if (0 == prevCode) {
        return NO;
    }
    // Always can break after space
    if (' ' == prevCode) {
        return YES;
    }
    // No Break SPace
    if (0xA0 == prevCode) {
        return NO;
    }
    // Space follow prev
    if (' ' == code || 0xA0 == code) {
        return NO;
    }
    if ([self isAlphaDigit:prevCode]) {
        if ([self isAlphaDigit:code]) {
            return NO;
        }
        if ('\'' == code || '\"' == code || '-' == code || '_' == code) {
            return NO;
        }
    }
    if ([self isAlphaDigit:code]) {
        if ('\'' == prevCode || '\"' == prevCode || 0x2019 == prevCode) {
            return NO;
        }
    }
    if ([self cannotLineBegin:code]) {
        return NO;
    }
    if ([self cannotLineEnd:prevCode]) {
        return NO;
    }
    return YES;
}

- (BOOL)canStretch:(unichar)code prevCode:(unichar)prevCode {
    if (![self canBreak:code prevCode:prevCode]) {
        return NO;
    }
    if ('/' == prevCode) {
        if ([self isAlphaDigit:code]) {
            return NO;
        }
    }
    if ('/' == code) {
        if ([self isAlphaDigit:prevCode]) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - Private

- (const CGGlyph *)glyphsForRun:(CTRunRef)run {
    const CGGlyph *glyphs = CTRunGetGlyphsPtr(run);
    if (!glyphs) {
        CFIndex count = CTRunGetGlyphCount(run);
        _glyphsData.length = sizeof(CGGlyph) * count;
        CGGlyph *buffer = (CGGlyph *)_glyphsData.mutableBytes;
        CTRunGetGlyphs(run, CFRangeMake(0, count), buffer);
        glyphs = buffer;
    }
    return glyphs;
}

- (const CFIndex *)indicesForRun:(CTRunRef)run {
    const CFIndex *indices = CTRunGetStringIndicesPtr(run);
    if (!indices) {
        CFIndex count = CTRunGetGlyphCount(run);
        _indicesData.length = sizeof(CFIndex) * count;
        CFIndex *buffer = (CFIndex *)_indicesData.mutableBytes;
        CTRunGetStringIndices(run, CFRangeMake(0, count), buffer);
        indices = buffer;
    }
    return indices;
}

- (const CGPoint *)positionsForRun:(CTRunRef)run {
    const CGPoint *positions = CTRunGetPositionsPtr(run);
    if (!positions) {
        CFIndex count = CTRunGetGlyphCount(run);
        _positionsData.length = sizeof(CGPoint) * count;
        CGPoint *buffer = (CGPoint *)_positionsData.mutableBytes;
        CTRunGetPositions(run, CFRangeMake(0, count), buffer);
        positions = buffer;
    }
    return positions;
}

- (const CGSize *)advancesForRun:(CTRunRef)run {
    const CGSize *advances = CTRunGetAdvancesPtr(run);
    if (!advances) {
        CFIndex count = CTRunGetGlyphCount(run);
        _advancesData.length = sizeof(CGSize) * count;
        CGSize *buffer = (CGSize *)_advancesData.mutableBytes;
        CTRunGetAdvances(run, CFRangeMake(0, count), buffer);
        advances = buffer;
    }
    return advances;
}

- (BOOL)isAlphaDigit:(unichar)code {
    return ('a' <= code && code <= 'z') || ('A' <= code && code <= 'Z') || ('0' <= code && code <= '9');
}

- (BOOL)isCjk:(unichar)code {
    return (0x4E00 <= code && code < 0xD800) || (0xE000 <= code && code < 0xFB00);
}

- (BOOL)canCompressLeft:(unichar)code {
    if (!_compressLeftSet) {
        self.compressLeftSet = [NSMutableIndexSet indexSet];
        [_compressLeftSet addIndex:0x2018]; // ‘
        [_compressLeftSet addIndex:0x201C]; // “
        [_compressLeftSet addIndex:0x3008]; // 〈
        [_compressLeftSet addIndex:0x300A]; // 《
        [_compressLeftSet addIndex:0x300C]; // 「
        [_compressLeftSet addIndex:0x300E]; // 『
        [_compressLeftSet addIndex:0x3010]; // 【
        [_compressLeftSet addIndex:0x3014]; // 〔
        [_compressLeftSet addIndex:0x3016]; // 〖
        [_compressLeftSet addIndex:0xFF08]; // （
        [_compressLeftSet addIndex:0xFF3B]; // ［
        [_compressLeftSet addIndex:0xFF5B]; // ｛
    }
    return [_compressLeftSet containsIndex:code];
}

- (BOOL)canCompressRight:(unichar)code {
    if (!_compressRightSet) {
        self.compressRightSet = [NSMutableIndexSet indexSet];
        [_compressRightSet addIndex:0x2019]; // ’
        [_compressRightSet addIndex:0x201D]; // ”
        [_compressRightSet addIndex:0x3001]; // 、
        [_compressRightSet addIndex:0x3002]; // 。
        [_compressRightSet addIndex:0x3009]; // 〉
        [_compressRightSet addIndex:0x300B]; // 》
        [_compressRightSet addIndex:0x300D]; // 」
        [_compressRightSet addIndex:0x300F]; // 』
        [_compressRightSet addIndex:0x3011]; // 】
        [_compressRightSet addIndex:0x3015]; // 〕
        [_compressRightSet addIndex:0x3017]; // 〗
        [_compressRightSet addIndex:0xFF01]; // ！
        [_compressRightSet addIndex:0xFF09]; // ）
        [_compressRightSet addIndex:0xFF0C]; // ，
        [_compressRightSet addIndex:0xFF1A]; // ：
        [_compressRightSet addIndex:0xFF1B]; // ；
        [_compressRightSet addIndex:0xFF1F]; // ？
        [_compressRightSet addIndex:0xFF3D]; // ］
        [_compressRightSet addIndex:0xFF5D]; // ｝
    }
    return [_compressRightSet containsIndex:code];
}

- (BOOL)cannotLineBegin:(unichar)code {
    if ([self canCompressRight:code]) {
        return YES;
    }
    if (!_notLineBeginSet) {
        self.notLineBeginSet = [NSMutableIndexSet indexSet];
        [_notLineBeginSet addIndex:'!'];
        [_notLineBeginSet addIndex:')'];
        [_notLineBeginSet addIndex:','];
        [_notLineBeginSet addIndex:'.'];
        [_notLineBeginSet addIndex:':'];
        [_notLineBeginSet addIndex:';'];
        [_notLineBeginSet addIndex:'>'];
        [_notLineBeginSet addIndex:'?'];
        [_notLineBeginSet addIndex:']'];
        [_notLineBeginSet addIndex:'}'];
    }
    return [_notLineBeginSet containsIndex:code];
}

- (BOOL)cannotLineEnd:(unichar)code {
    if ([self canCompressLeft:code]) {
        return YES;
    }
    if (!_notLineEndSet) {
        self.notLineEndSet = [NSMutableIndexSet indexSet];
        [_notLineEndSet addIndex:'('];
        [_notLineEndSet addIndex:'<'];
        [_notLineEndSet addIndex:'['];
        [_notLineEndSet addIndex:'{'];
    }
    return [_notLineEndSet containsIndex:code];
}

@end
