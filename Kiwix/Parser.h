//
//  Parser.h
//  Kiwix
//
//  Created by Chris Li on 1/11/15.
//  Copyright (c) 2015 Chris Li. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Parser : NSObject

+ (NSArray *)tableOfContentFromTOCHTMLString:(NSString *)htmlString;

+ (NSString *)timeDifferenceStringBetweenNowAnd:(NSDate *)date;

+ (NSString *)articleCountString:(NSUInteger)articleCount;

@end
