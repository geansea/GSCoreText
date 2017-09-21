//
//  GSCTTypesetter.m
//  GSCoreText
//
//  Created by geansea on 2017/8/13.
//
//

#import "GSCTTypesetter.h"
#import "GSCTUtils.h"

@interface GSCTTypesetter ()

@property (assign) CTTypesetterRef ctTypesetter;
@property (strong) GSCTUtils *utils;
@property (strong) NSMutableAttributedString *layoutString;

@end

@implementation GSCTTypesetter

- (instancetype)init {
    if (self = [super init]) {
        self.font = [GSFont systemFontOfSize:GSFont.systemFontSize];
        self.indent = 0;
        self.alignment = NSTextAlignmentLeft;
        self.puncCompressRate = 0;
        self.ctTypesetter = NULL;
        self.utils = [[GSCTUtils alloc] init];
    }
    return self;
}

- (void)dealloc {
    if (_ctTypesetter) {
        CFRelease(_ctTypesetter);
        self.ctTypesetter = NULL;
    }
}

- (void)prepare {
    if (_ctTypesetter) {
        CFRelease(_ctTypesetter);
        self.ctTypesetter = NULL;
    }
    
    self.layoutString = [[NSMutableAttributedString alloc] initWithString:_attributedString.string];
    NSRange totalRange = NSMakeRange(0, _layoutString.length);
    // Vertical
    [_layoutString addAttribute:(__bridge NSString *)kCTVerticalFormsAttributeName value:@(_vertical) range:totalRange];
    // Font
    [_layoutString addAttribute:(__bridge NSString *)kCTFontAttributeName value:_font range:totalRange];
    // Custom fonts
    [_attributedString enumerateAttributesInRange:totalRange options:0 usingBlock:^(NSDictionary<NSString *, id> *attrs, NSRange range, BOOL *stop) {
        GSFont *font = [attrs objectForKey:NSFontAttributeName];
        if (font && [font isKindOfClass:[GSFont class]]) {
            CTFontRef ctFont = (__bridge CTFontRef)font;
            [_layoutString addAttribute:(__bridge NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:range];
        }
    }];
    
    self.ctTypesetter = CTTypesetterCreateWithAttributedString((__bridge CFAttributedStringRef)_layoutString);
}

- (GSCTLine *)createLineWithWidth:(CGFloat)width startIndex:(NSUInteger)startIndex {
    if (!_ctTypesetter) {
        return nil;
    }
    CGFloat indent = 0;
    if (0 == startIndex || [_utils isNewline:[_layoutString.string characterAtIndex:(startIndex - 1)]]) {
        indent = _font.pointSize * _indent;
    }
    if (_vertical) {
        return [self createVerticalLineWithWidth:(width - indent) indent:indent startIndex:startIndex];
    } else {
        return [self createHorizontalLineWithWidth:(width - indent) indent:indent startIndex:startIndex];
    }
}

- (GSCTFrame *)createFrameWithRect:(CGRect)rect startIndex:(NSUInteger)startIndex {
    if (!_ctTypesetter) {
        return nil;
    }
    if (_vertical) {
        return [self createVerticalFrameWithRect:rect startIndex:startIndex];
    } else {
        return [self createHorizontalFrameWithRect:rect startIndex:startIndex];
    }
}

#pragma mark - Private

- (GSCTLine *)createHorizontalLineWithWidth:(CGFloat)width indent:(CGFloat)indent startIndex:(NSUInteger)startIndex {
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
    CGPoint lineOrigin = [self adjustGlyphs:glyphs withWidth:width indent:indent];
    
    // Line infos
    NSRange lineRange = NSMakeRange(startIndex, 0);
    CGFloat lineWidth = 0;
    if (glyphs.count > 0) {
        GSCTGlyph *last = glyphs.lastObject;
        lineRange.length = NSMaxRange(last.range) - lineRange.location;
        lineWidth = CGRectGetMaxX(last.usedRect);
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
    line.usedWidth = lineWidth;
    line.vertical = NO;
    return line;
}

- (GSCTLine *)createVerticalLineWithWidth:(CGFloat)width indent:(CGFloat)indent startIndex:(NSUInteger)startIndex {
    // Glyphs
    CFIndex length = CTTypesetterSuggestLineBreak(_ctTypesetter, startIndex, width);
    CTLineRef ctLine = CTTypesetterCreateLine(_ctTypesetter, CFRangeMake(startIndex, length));
    NSArray<GSCTGlyph *> *glyphs = [_utils glyphsFromCTLine:ctLine string:_layoutString.string vertical:YES];
    CFRelease(ctLine);
    
    CGPoint lineOrigin = [self adjustGlyphs:glyphs withWidth:width indent:indent];
    
    // Line infos
    NSRange lineRange = NSMakeRange(startIndex, 0);
    CGFloat lineWidth = 0;
    if (glyphs.count > 0) {
        GSCTGlyph *last = glyphs.lastObject;
        lineRange.length = NSMaxRange(last.range) - lineRange.location;
        lineWidth = CGRectGetMaxY(last.usedRect);
    }
    CGFloat lineAscent = 0;
    CGFloat lineDescent = 0;
    for (GSCTGlyph *glyph in glyphs) {
        lineAscent = MAX(lineAscent, CGRectGetMaxX(glyph.usedRect));
        lineDescent = MAX(lineDescent, -CGRectGetMinX(glyph.usedRect));
    }
    GSCTLine *line = [[GSCTLine alloc] init];
    line.range = lineRange;
    line.string = [_attributedString attributedSubstringFromRange:line.range];
    line.glyphs = glyphs;
    line.x = lineOrigin.x;
    line.y = lineOrigin.y;
    line.ascent = lineAscent;
    line.descent = lineDescent;
    line.usedWidth = lineWidth;
    line.vertical = YES;
    return line;
}

- (GSCTFrame *)createHorizontalFrameWithRect:(CGRect)rect startIndex:(NSUInteger)startIndex {
    NSMutableArray<GSCTLine *> *lines = [NSMutableArray array];
    NSUInteger lineLocation = startIndex;
    CGFloat lineTop = CGRectGetMinY(rect);
    while (lineLocation < _layoutString.length) {
        GSCTLine *line = [self createLineWithWidth:CGRectGetWidth(rect) startIndex:lineLocation];
        line.x += CGRectGetMinX(rect);
        line.y += lineTop + line.ascent;
        lineTop = line.y + line.descent;
        if (lineTop > CGRectGetMaxY(rect)) {
            break;
        }
        [lines addObject:line];
        lineLocation = NSMaxRange(line.range);
        lineTop += _font.pointSize * _lineSpacing;
        if ([_utils isNewline:line.glyphs.lastObject.utf16Code]) {
            lineTop += _font.pointSize * _paragraphSpacing;
        }
    }
    return [_utils horizontalFrameWithLines:lines rect:rect];
}

- (GSCTFrame *)createVerticalFrameWithRect:(CGRect)rect startIndex:(NSUInteger)startIndex {
    NSMutableArray<GSCTLine *> *lines = [NSMutableArray array];
    NSUInteger lineLocation = startIndex;
    CGFloat lineRight = CGRectGetMaxX(rect);
    while (lineLocation < _layoutString.length) {
        GSCTLine *line = [self createLineWithWidth:CGRectGetHeight(rect) startIndex:lineLocation];
        line.x += lineRight - line.ascent;
        line.y += CGRectGetMinY(rect);
        lineRight = line.x - line.descent;
        if (lineRight < CGRectGetMinX(rect)) {
            break;
        }
        [lines addObject:line];
        lineLocation = NSMaxRange(line.range);
        lineRight -= _font.pointSize * _lineSpacing;
        if ([_utils isNewline:line.glyphs.lastObject.utf16Code]) {
            lineRight -= _font.pointSize * _paragraphSpacing;
        }
    }
    return [_utils verticalFrameWithLines:lines rect:rect];
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

- (CGPoint)adjustGlyphs:(NSArray<GSCTGlyph *> *)glyphs withWidth:(CGFloat)width indent:(CGFloat)indent {
    CGPoint origin = CGPointZero;
    if (_vertical) {
        origin.y = indent;
    } else {
        origin.x = indent;
    }
    GSCTGlyph *lastGlyph = glyphs.lastObject;
    BOOL reachEnd = [_utils isNewline:lastGlyph.utf16Code];
    if (NSMaxRange(lastGlyph.range) == [_layoutString length]) {
        reachEnd = YES;
    }
    CGFloat lineWidth = _vertical ? CGRectGetMaxY(lastGlyph.usedRect) : CGRectGetMaxX(lastGlyph.usedRect);
    CGFloat adjustWidth = width - lineWidth;
    if (adjustWidth > 0) {
        switch (_alignment) {
            case NSTextAlignmentLeft:
                break;
            case NSTextAlignmentRight:
                if (_vertical) {
                    origin.y += adjustWidth;
                } else {
                    origin.x += adjustWidth;
                }
                break;
            case NSTextAlignmentCenter:
                if (_vertical) {
                    origin.y += adjustWidth / 2;
                } else {
                    origin.x += adjustWidth / 2;
                }
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
                        if (_vertical) {
                            thisGlyph.y += move;
                        } else {
                            thisGlyph.x += move;
                        }
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
