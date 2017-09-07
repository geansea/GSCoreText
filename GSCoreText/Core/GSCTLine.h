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
@property (copy)   NSString *string;
@property (copy)   NSArray<GSCTGlyph *> *glyphs;
@property (assign) CGPoint origin;
@property (assign) CGRect rect;
@property (assign) CGRect usedRect;
@property (assign) BOOL vertical;

@end
