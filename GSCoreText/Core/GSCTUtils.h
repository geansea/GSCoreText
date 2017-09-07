//
//  GSCTUtils.h
//  GSCoreText
//
//  Created by geansea on 2017/9/6.
//
//

#import "GSCTLine.h"
#import <CoreText/CoreText.h>

@interface GSCTUtils : NSObject

- (GSCTLine *)createLineFromCTLine:(CTLineRef)ctLine
                            string:(NSString *)string
                          vertical:(BOOL)vertical;

@end
