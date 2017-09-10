//
//  GSCTFrame.h
//  GSCoreText
//
//  Created by geansea on 2017/9/6.
//
//

#import "GSCTLine.h"

@interface GSCTFrame : NSObject

@property (assign) NSRange range;
@property (copy)   NSAttributedString *string;
@property (copy)   NSArray<GSCTLine *> *lines;
@property (assign) CGRect rect;
@property (assign) CGRect usedRect;
@property (assign) BOOL vertical;

- (void)drawInContext:(CGContextRef)context;

@end
