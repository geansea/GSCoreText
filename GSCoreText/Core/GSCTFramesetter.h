//
//  GSCTFramesetter.h
//  GSCoreText
//
//  Created by geansea on 2017/9/6.
//
//

#import "GSCTFrame.h"

@interface GSCTFramesetter : NSObject

@property (copy)   NSAttributedString *attributedString;
@property (strong) GSFont *font;                            // base font, default system font
@property (assign) CGFloat indent;                          // em, default 0
@property (assign) NSTextAlignment alignment;               // default align left
@property (assign) CGFloat lineSpacing;                     // em, default 0
@property (assign) CGFloat paragraphSpacing;                // em, default 0
@property (assign) BOOL vertical;                           // default NO

- (instancetype)init;
- (void)prepare;
- (GSCTFrame *)createFrameWithRect:(CGRect)rect startIndex:(NSUInteger)startIndex;
- (GSCTFrame *)createFrameWithPath:(CGPathRef)path startIndex:(NSUInteger)startIndex;

@end
