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

@property (strong) GSCTUtils *utils;
@property (copy)   NSAttributedString *attributedString;
@property (strong) NSMutableAttributedString *layoutString;

@end

@implementation GSCTFramesetter

- (instancetype)initWithString:(NSAttributedString *)attributedString {
    if (self = [super init]) {
        self.font = [GSFont systemFontOfSize:GSFont.systemFontSize];
        self.indent = 0;
        self.alignment = NSTextAlignmentLeft;
        self.vertical = NO;
        self.utils = [[GSCTUtils alloc] init];
        self.attributedString = attributedString;
    }
    return self;
}

- (GSCTFrame *)createFrameWithRect:(CGRect)rect startIndex:(NSUInteger)startIndex {
    CGPathRef path = CGPathCreateWithRect(rect, NULL);
    GSCTFrame *frame = [self createFrameWithPath:path startIndex:startIndex];
    CGPathRelease(path);
    return frame;
}

- (GSCTFrame *)createFrameWithPath:(CGPathRef)path startIndex:(NSUInteger)startIndex {
    [self createLayoutString];
    CTFramesetterRef ctFramesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)_layoutString);
    
    CGRect frameRect = CGPathGetBoundingBox(path);
    CGAffineTransform transform = CGAffineTransformMakeScale(1.0, -1.0);
    CGPathRef framePath = CGPathCreateCopyByTransformingPath(path, &transform);
    
    NSMutableDictionary<NSString *, id> *attributes = [NSMutableDictionary dictionary];
    [attributes setObject:@(_vertical ? kCTFrameProgressionRightToLeft : kCTFrameProgressionTopToBottom) forKey:(__bridge NSString *)kCTFrameProgressionAttributeName];
    CTFrameRef ctFrame = CTFramesetterCreateFrame(ctFramesetter, CFRangeMake(startIndex, _layoutString.length - startIndex), framePath, (__bridge CFDictionaryRef)attributes);
    
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
    CFRelease(ctFramesetter);
    
    // Frame infos
    NSRange frameRange = NSMakeRange(0, 0);
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
    // Paragraph style
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.firstLineHeadIndent = _font.pointSize * _indent;
    paragraphStyle.lineSpacing = _font.pointSize * _lineSpacing;
    paragraphStyle.paragraphSpacing = _font.pointSize * _paragraphSpacing;
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
}

@end
