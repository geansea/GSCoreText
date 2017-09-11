//
//  GSCTLine.h
//  GSCoreText
//
//  Created by geansea on 2017/9/4.
//
//

#import "GSCTGlyph.h"

@interface GSCTLine : NSObject

@property (assign) NSRange range;
@property (copy)   NSAttributedString *string;
@property (copy)   NSArray<GSCTGlyph *> *glyphs;
@property (assign) CGFloat x;
@property (assign) CGFloat y;
@property (assign) CGFloat ascent;
@property (assign) CGFloat descent;
@property (assign) CGFloat usedWidth;
@property (assign) BOOL vertical;

- (CGRect)usedRect;
- (void)drawInContext:(CGContextRef)context;

@end
