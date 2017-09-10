//
//  GSCTFramesetter.h
//  GSCoreText
//
//  Created by geansea on 2017/9/6.
//
//

#import "GSCTFrame.h"

@interface GSCTFramesetter : NSObject

@property (assign) CGFloat fontSize;            // base font size, default 16
@property (assign) CGFloat indent;              // em, default 0
@property (assign) NSTextAlignment alignment;   // default align left
@property (assign) BOOL vertical;               // default NO

- (instancetype)initWithString:(NSAttributedString *)attributedString;
- (NSAttributedString *)attributedString;
- (GSCTFrame *)createFrameWithRect:(CGRect)rect startIndex:(NSUInteger)startIndex;
- (GSCTFrame *)createFrameWithPath:(CGPathRef)path startIndex:(NSUInteger)startIndex;

@end
