//
//  GSCTTypesetter.h
//  GSCoreText
//
//  Created by geansea on 2017/8/13.
//
//

#import "GSCTDefines.h"

@interface GSCTTypesetter : NSObject

@property (nonatomic) CGFloat indent;               // em, default 0
@property (nonatomic) NSTextAlignment alignment;    // default align left
@property (nonatomic) CGFloat puncCompressRate;     // [0.5, 1], default 1 for no compress

//- (instancetype)initWithString:(NSAttributedString *)attributedString fontSize:(CGFloat)size;
//- (NSAttributedString *)attributedString;
//- (GSLine *)createLineWithWidth:(CGFloat)width startIndex:(NSUInteger)startIndex align:(GSAlign)align;

@end
