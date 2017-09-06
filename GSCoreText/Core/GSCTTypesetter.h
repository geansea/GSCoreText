//
//  GSCTTypesetter.h
//  GSCoreText
//
//  Created by geansea on 2017/8/13.
//
//

#import "GSCTLine.h"

@interface GSCTTypesetter : NSObject

@property (assign) CGFloat fontSize;             // base font size
@property (assign) CGFloat indent;               // em, default 0
@property (assign) NSTextAlignment alignment;    // default align left
@property (assign) CGFloat puncCompressRate;     // [0.5, 1], default 1 for no compress

- (instancetype)initWithString:(NSAttributedString *)attributedString;
- (NSAttributedString *)attributedString;
- (GSCTLine *)createLineWithWidth:(CGFloat)width startIndex:(NSUInteger)startIndex;

@end
