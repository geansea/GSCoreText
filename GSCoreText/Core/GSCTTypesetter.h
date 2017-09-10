//
//  GSCTTypesetter.h
//  GSCoreText
//
//  Created by geansea on 2017/8/13.
//
//

#import "GSCTFrame.h"

@interface GSCTTypesetter : NSObject

@property (strong) GSFont *font;                // base font, default system font
@property (assign) CGFloat indent;              // em, default 0
@property (assign) NSTextAlignment alignment;   // default align left
@property (assign) CGFloat puncCompressRate;    // [0, 0.5], default 0 for no compress
@property (assign) CGFloat lineSpacing;         // em, default 0
@property (assign) CGFloat paragraphSpacing;    // em, default 0

- (instancetype)initWithString:(NSAttributedString *)attributedString;
- (NSAttributedString *)attributedString;
- (GSCTLine *)createLineWithWidth:(CGFloat)width startIndex:(NSUInteger)startIndex;
- (GSCTFrame *)createFrameWithRect:(CGRect)rect startIndex:(NSUInteger)startIndex;

@end
