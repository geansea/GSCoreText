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
    CGFloat tryWidth = width * 1.3;
    CFIndex length = CTTypesetterSuggestClusterBreak(_ctTypesetter, startIndex, tryWidth);
    CTLineRef ctLine = CTTypesetterCreateLine(_ctTypesetter, CFRangeMake(startIndex, length));
    GSCTLine *line = [_utils createLineFromCTLine:ctLine string:_layoutString.string vertical:NO];
    
    
    return nil;
    
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

@end
