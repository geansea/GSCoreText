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
        self.font = [GSFont systemFontOfSize:GSFont.systemFontSize];
        self.indent = 0;
        self.alignment = NSTextAlignmentLeft;
        self.puncCompressRate = 0;
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
    NSArray<GSCTGlyph *> *glyphs = [_utils glyphsFromCTLine:ctLine string:_layoutString.string vertical:NO];
    CFRelease(ctLine);
    
    [self compressGlyphs:glyphs];
    
    NSUInteger breakPos = [self breakPosForGlyphs:glyphs withWidth:width];
    glyphs = [glyphs subarrayWithRange:NSMakeRange(0, breakPos)];
    
    [self adjustEndGlyphs:glyphs];
    CGPoint lineOrigin = [self adjustGlyphs:glyphs withWidth:width];
    
    // Line infos
    NSRange lineRange = NSMakeRange(0, 0);
    CGFloat lineWidth = 0;
    if (glyphs.count > 0) {
        GSCTGlyph *first = glyphs.firstObject;
        GSCTGlyph *last = glyphs.lastObject;
        lineRange.location = first.range.location;
        lineRange.length = NSMaxRange(last.range) - lineRange.location;
        lineWidth = CGRectGetMaxX(last.usedRect) - lineOrigin.x;
    }
    CGFloat lineAscent = 0;
    CGFloat lineDescent = 0;
    for (GSCTGlyph *glyph in glyphs) {
        lineAscent = MAX(lineAscent, glyph.ascent);
        lineDescent = MAX(lineDescent, glyph.descent);
    }
    GSCTLine *line = [[GSCTLine alloc] init];
    line.range = lineRange;
    line.string = [_attributedString attributedSubstringFromRange:line.range];
    line.glyphs = glyphs;
    line.x = lineOrigin.x;
    line.y = lineOrigin.y;
    line.ascent = lineAscent;
    line.descent = lineDescent;
    line.width = width;
    line.usedWidth = lineWidth;
    line.vertical = NO;
    return line;
}

- (GSCTFrame *)createFrameWithRect:(CGRect)rect startIndex:(NSUInteger)startIndex {
    // Lines
    NSMutableArray<GSCTLine *> *lines = [NSMutableArray array];
    NSUInteger lineLocation = startIndex;
    CGFloat lineTop = CGRectGetMinY(rect);
    while (lineLocation < _layoutString.length) {
        GSCTLine *line = [self createLineWithWidth:CGRectGetWidth(rect) startIndex:lineLocation];
        line.x += CGRectGetMinX(rect);
        line.y += lineTop + line.ascent;
        lineTop = line.y + line.descent;
        if (lineTop > CGRectGetHeight(rect)) {
            break;
        }
        
        [lines addObject:line];
        
        lineLocation = NSMaxRange(line.range);
        lineTop += _font.pointSize * _lineSpacing;
        if ([_utils isNewline:line.glyphs.lastObject.utf16Code]) {
            lineTop += _font.pointSize * _paragraphSpacing;
        }
    }
    
    // Frame infos
    NSRange frameRange = NSMakeRange(0, 0);
    CGRect frameRect = rect;
    CGFloat frameHeight = 0;
    if (lines.count > 0) {
        GSCTLine *first = lines.firstObject;
        GSCTLine *last = lines.lastObject;
        frameRange.location = first.range.location;
        frameRange.length = NSMaxRange(last.range) - frameRange.location;
        frameHeight = CGRectGetMaxY(last.usedRect);
    }
    CGFloat frameLeft = 0;
    CGFloat frameRight = 0;
    for (GSCTLine *line in lines) {
        frameLeft = MIN(frameLeft, CGRectGetMinX(line.usedRect));
        frameRight = MAX(frameRight, CGRectGetMaxX(line.usedRect));
    }
    GSCTFrame *frame = [[GSCTFrame alloc] init];
    frame.range = frameRange;
    frame.lines = lines;
    frame.rect = frameRect;
    frame.usedRect = CGRectMake(frameLeft, CGRectGetMinY(frameRect), frameRight - frameLeft, frameHeight);
    frame.vertical = NO;
    return frame;
}

#pragma mark - Private

- (void)createLayoutString {
    self.layoutString = [[NSMutableAttributedString alloc] initWithString:_attributedString.string];
    NSRange totalRange = NSMakeRange(0, _layoutString.length);
    [_layoutString addAttribute:(__bridge NSString *)kCTFontAttributeName value:_font range:totalRange];
    [_attributedString enumerateAttributesInRange:totalRange options:0 usingBlock:^(NSDictionary<NSString *, id> *attrs, NSRange range, BOOL *stop) {
        GSFont *font = [attrs objectForKey:NSFontAttributeName];
        if (font && [font isKindOfClass:[GSFont class]]) {
            CTFontRef ctFont = (__bridge CTFontRef)font;
            [_layoutString addAttribute:(__bridge NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:range];
        }
    }];
}

- (void)compressGlyphs:(NSArray<GSCTGlyph *> *)glyphs {
    GSCTGlyph *prevGlyph = nil;
    CGFloat fontSize = _font.pointSize;
    CGFloat move = 0;
    for (GSCTGlyph *thisGlyph in glyphs) {
        unichar code = thisGlyph.utf16Code;
        unichar prevCode = prevGlyph.utf16Code;
        // Add gap
        if ([_utils shouldAddGap:code prevCode:prevCode]) {
            move += fontSize / 6;
        }
        // Punctuation compress
        if ([_utils canGlyphCompressLeft:thisGlyph]) {
            if (0 == prevCode) {
                thisGlyph.compressLeft = thisGlyph.width * _puncCompressRate;
                move -= thisGlyph.compressLeft;
            }
            if ([_utils canGlyphCompressRight:prevGlyph]) {
                thisGlyph.compressLeft = thisGlyph.width * _puncCompressRate / 2;
                move -= thisGlyph.compressLeft;
                prevGlyph.compressRight = prevGlyph.width * _puncCompressRate / 2;
                move -= prevGlyph.compressRight;
            }
        }
        if ([_utils canGlyphCompressRight:thisGlyph]) {
            if ([_utils canGlyphCompressRight:prevGlyph]) {
                prevGlyph.compressRight = prevGlyph.width * _puncCompressRate / 2;
                move -= prevGlyph.compressRight;
            }
        }
        // Move
        thisGlyph.x += move;
        // Fix CRLF width
        if ([_utils isNewline:code]) {
            move -= thisGlyph.width;
            thisGlyph.compressRight = thisGlyph.width;
        }
        prevGlyph = thisGlyph;
    }
}

- (NSUInteger)breakPosForGlyphs:(NSArray<GSCTGlyph *> *)glyphs withWidth:(CGFloat)width {
    NSUInteger breakPos = 0;
    NSUInteger forceBreakPos = 0;
    for (NSUInteger i = 1; i < glyphs.count; ++i) {
        GSCTGlyph *prevGlyph = glyphs[i - 1];
        GSCTGlyph *thisGlyph = glyphs[i];
        if ([_utils canBreak:thisGlyph.utf16Code prevCode:prevGlyph.utf16Code]) {
            breakPos = i;
        }
        CGFloat currentWidth = CGRectGetMaxX(thisGlyph.usedRect);
        if (currentWidth > width) {
            if ([_utils canGlyphCompressRight:thisGlyph]) {
                CGFloat compressRight = thisGlyph.width * _puncCompressRate;
                currentWidth = CGRectGetMaxX(thisGlyph.rect) - compressRight;
            }
        }
        if (currentWidth > width) {
            forceBreakPos = i;
            break;
        }
    }
    // If all glyphs can be in line
    if (0 == forceBreakPos) {
        breakPos = glyphs.count;
    }
    // If no valid break position
    if (0 == breakPos) {
        breakPos = forceBreakPos;
    }
    // Add next space if possible, for latin layout
    if (breakPos < glyphs.count) {
        if (' ' == glyphs[breakPos].utf16Code) {
            ++breakPos;
        }
    }
    return breakPos;
}

- (void)adjustEndGlyphs:(NSArray<GSCTGlyph *> *)glyphs {
    // Compress last none CRLF glyph if possible
    NSUInteger count = glyphs.count;
    GSCTGlyph *lastGlyph = glyphs[count - 1];
    GSCTGlyph *crlfGlyph = nil;
    if ([_utils isNewline:lastGlyph.utf16Code]) {
        crlfGlyph = lastGlyph;
        if (count > 1) {
            lastGlyph = glyphs[count - 2];
        }
    }
    if ([_utils canGlyphCompressRight:lastGlyph]) {
        lastGlyph.compressRight = lastGlyph.width * _puncCompressRate;
    }
    if (' ' == lastGlyph.utf16Code) {
        lastGlyph.compressRight = lastGlyph.width;
    }
    if (crlfGlyph) {
        crlfGlyph.x = CGRectGetMaxX(lastGlyph.usedRect);
    }
}

- (CGPoint)adjustGlyphs:(NSArray<GSCTGlyph *> *)glyphs withWidth:(CGFloat)width {
    CGPoint origin = CGPointZero;
    GSCTGlyph *lastGlyph = glyphs.lastObject;
    BOOL reachEnd = [_utils isNewline:lastGlyph.utf16Code];
    if (NSMaxRange(lastGlyph.range) == [_layoutString length]) {
        reachEnd = YES;
    }
    CGFloat adjustWidth = width - CGRectGetMaxX(lastGlyph.usedRect);
    if (adjustWidth > 0) {
        switch (_alignment) {
            case NSTextAlignmentLeft:
                break;
            case NSTextAlignmentRight:
                origin.x = adjustWidth;
                break;
            case NSTextAlignmentCenter:
                origin.x = adjustWidth / 2;
                break;
            case NSTextAlignmentJustified:
                if (!reachEnd) {
                    NSUInteger stretchCount = 0;
                    for (NSUInteger i = 1; i < glyphs.count; ++i) {
                        GSCTGlyph *prevGlyph = glyphs[i - 1];
                        GSCTGlyph *thisGlyph = glyphs[i];
                        if ([_utils canStretch:thisGlyph.utf16Code prevCode:prevGlyph.utf16Code]) {
                            ++stretchCount;
                        }
                    }
                    CGFloat stretchWidth = adjustWidth / stretchCount;
                    CGFloat move = 0;
                    for (NSUInteger i = 1; i < glyphs.count; ++i) {
                        GSCTGlyph *prevGlyph = glyphs[i - 1];
                        GSCTGlyph *thisGlyph = glyphs[i];
                        if ([_utils canStretch:thisGlyph.utf16Code prevCode:prevGlyph.utf16Code]) {
                            move += stretchWidth;
                        }
                        thisGlyph.x += move;
                    }
                    break;
                }
            default:
                break;
        }
    }
    return origin;
}

@end
