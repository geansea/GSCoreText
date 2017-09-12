//
//  GSCTFramesetter.m
//  GSCoreText
//
//  Created by geansea on 2017/9/6.
//
//

#import "GSCTFramesetter.h"
#import "GSCTUtils.h"

@interface GSCTFramesetter ()

@property (assign) CTFramesetterRef ctFramesetter;
@property (strong) GSCTUtils *utils;
@property (strong) NSMutableAttributedString *layoutString;

@end

@implementation GSCTFramesetter

- (instancetype)init {
    if (self = [super init]) {
        self.font = [GSFont systemFontOfSize:GSFont.systemFontSize];
        self.indent = 0;
        self.alignment = NSTextAlignmentLeft;
        self.vertical = NO;
        self.ctFramesetter = NULL;
        self.utils = [[GSCTUtils alloc] init];
    }
    return self;
}

- (void)dealloc {
    if (_ctFramesetter) {
        CFRelease(_ctFramesetter);
        self.ctFramesetter = NULL;
    }
}

- (void)prepare {
    if (_ctFramesetter) {
        CFRelease(_ctFramesetter);
        self.ctFramesetter = NULL;
    }
    
    self.layoutString = [[NSMutableAttributedString alloc] initWithString:_attributedString.string];
    NSRange totalRange = NSMakeRange(0, _layoutString.length);
    // Paragraph style
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = _font.pointSize * _lineSpacing;
    paragraphStyle.paragraphSpacing = _font.pointSize * _paragraphSpacing;
    paragraphStyle.alignment = _alignment;
    paragraphStyle.firstLineHeadIndent = _font.pointSize * _indent;
    [_layoutString addAttribute:(__bridge NSString *)kCTParagraphStyleAttributeName value:paragraphStyle range:totalRange];
    // Font
    [_layoutString addAttribute:(__bridge NSString *)kCTFontAttributeName value:_font range:totalRange];
    // Vertical
    [_layoutString addAttribute:(__bridge NSString *)kCTVerticalFormsAttributeName value:@(_vertical) range:totalRange];
    // Custom fonts
    [_attributedString enumerateAttributesInRange:totalRange options:0 usingBlock:^(NSDictionary<NSString *, id> *attrs, NSRange range, BOOL *stop) {
        GSFont *font = [attrs objectForKey:NSFontAttributeName];
        if (font && [font isKindOfClass:[GSFont class]]) {
            CTFontRef ctFont = (__bridge CTFontRef)font;
            [_layoutString addAttribute:(__bridge NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:range];
        }
    }];
    
    self.ctFramesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)_layoutString);
}

- (GSCTFrame *)createFrameWithRect:(CGRect)rect startIndex:(NSUInteger)startIndex {
    CGPathRef path = CGPathCreateWithRect(rect, NULL);
    GSCTFrame *frame = [self createFrameWithPath:path startIndex:startIndex];
    CGPathRelease(path);
    return frame;
}

- (GSCTFrame *)createFrameWithPath:(CGPathRef)path startIndex:(NSUInteger)startIndex {
    if (!_ctFramesetter) {
        return nil;
    }
    
    CGRect frameRect = CGPathGetBoundingBox(path);
    CGAffineTransform transform = CGAffineTransformMakeScale(1.0, -1.0);
    CGPathRef framePath = CGPathCreateCopyByTransformingPath(path, &transform);
    
    NSMutableDictionary<NSString *, id> *attributes = [NSMutableDictionary dictionary];
    [attributes setObject:@(_vertical ? kCTFrameProgressionRightToLeft : kCTFrameProgressionTopToBottom) forKey:(__bridge NSString *)kCTFrameProgressionAttributeName];
    CTFrameRef ctFrame = CTFramesetterCreateFrame(_ctFramesetter, CFRangeMake(startIndex, _layoutString.length - startIndex), framePath, (__bridge CFDictionaryRef)attributes);
    
    // Lines
    NSMutableArray<GSCTLine *> *lines = [NSMutableArray array];
    CFArrayRef ctLines = CTFrameGetLines(ctFrame);
    CFIndex lineCount = CFArrayGetCount(ctLines);
    CGPoint lineOrigins[lineCount];
    CTFrameGetLineOrigins(ctFrame, CFRangeMake(0, lineCount), lineOrigins);
    for (CFIndex i = 0; i < lineCount; ++i) {
        CTLineRef ctLine = CFArrayGetValueAtIndex(ctLines, i);
        GSCTLine *line = [_utils lineFromCTLine:ctLine attributedString:_attributedString vertical:_vertical];
        line.x = CGRectGetMinX(frameRect) + lineOrigins[i].x;
        line.y = CGRectGetMaxY(frameRect) - lineOrigins[i].y;
        [lines addObject:line];
    }
    CFRelease(ctFrame);
    CFRelease(framePath);
    
    if (_vertical) {
        return [_utils verticalFrameWithLines:lines rect:frameRect];
    } else {
        return [_utils horizontalFrameWithLines:lines rect:frameRect];
    }
}

#pragma mark - Private

@end
