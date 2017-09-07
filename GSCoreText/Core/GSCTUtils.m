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

@end

@implementation GSCTUtils

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (GSCTLine *)createLineFromCTLine:(CTLineRef)ctLine {
    GSCTLine *line = [[GSCTLine alloc] init];
    
    // Line infos
    CFRange lineRange = CTLineGetStringRange(ctLine);
    CGFloat lineAscent = 0;
    CGFloat lineDescent = 0;
    CGFloat lineWidth = CTLineGetTypographicBounds(ctLine, &lineAscent, &lineDescent, NULL);
    line.range = NSMakeRange(lineRange.location, lineRange.length);
    line.rect = CGRectMake(0, -lineAscent, lineWidth, lineAscent + lineDescent);
    
    // Line glyphs
    CFIndex glyphCount = CTLineGetGlyphCount(ctLine);
    NSMutableArray<GSCTGlyph *> *lineGlyphs = [NSMutableArray arrayWithCapacity:glyphCount];
    CFArrayRef runs = CTLineGetGlyphRuns(ctLine);
    for (CFIndex idx = 0; idx < CFArrayGetCount(runs); ++idx) {
        CTRunRef run = (CTRunRef)CFArrayGetValueAtIndex(runs, idx);
        // Run infos
        CGFloat runAscent = 0;
        CGFloat runDescent = 0;
        CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &runAscent, &runDescent, NULL);
        const CGGlyph *glyphs = [self glyphsForRun:run];
        const CFIndex *indices = [self indicesForRun:run];
        const CGPoint *positions = [self positionsForRun:run];
        const CGSize *advances = [self advancesForRun:run];
        // Run attributes
        CFDictionaryRef attributes = CTRunGetAttributes(run);
        //GSFont *font = (__bridge GSFont *)CFDictionaryGetValue(attributes, kCTFontAttributeName);
        //GSColor *color = [GSColor colorWithCGColor:<#(nonnull CGColorRef)#>];
        //UIFont *font = attributes[NSFontAttributeName];
        //UIColor *color = attributes[NSForegroundColorAttributeName];
        for (CFIndex i = 0; i < CTRunGetGlyphCount(run); ++i) {
            GSCTGlyph *glyph = [[GSCTGlyph alloc] init];
            
            [lineGlyphs addObject:glyph];
        }
    }
    if (lineGlyphs.lastObject) {
        GSCTGlyph *glyph = lineGlyphs.lastObject;
    }
    
    return line;
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

@end
