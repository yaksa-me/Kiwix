//
//  Parser.m
//  Kiwix
//
//  Created by Chris Li on 1/11/15.
//  Copyright (c) 2015 Chris Li. All rights reserved.
//

#import "Parser.h"
#import "TFHpple.h"

@implementation Parser

+ (NSArray *)tableOfContentFromTOCHTMLString:(NSString *)htmlString {
    NSData *htmlData = [htmlString dataUsingEncoding:NSUTF8StringEncoding];
    TFHpple *htmlParser = [TFHpple hppleWithHTMLData:htmlData];
    NSString *htmlXpathQueryString = @"//div[@id='content']/ul/li/a";
    NSArray *resultArray = [htmlParser searchWithXPathQuery:htmlXpathQueryString];
    
    NSMutableArray *mutableResultArray = [[NSMutableArray alloc] init];
    for (TFHppleElement *element in resultArray) {
        [mutableResultArray addObject:[[element firstChild] content]];
    }
    return mutableResultArray;
}

+ (NSString *)timeDifferenceStringBetweenNowAnd:(NSDate *)date {
    NSInteger interval = -1 * date.timeIntervalSinceNow;
    
    if (interval < 60) {
        if (interval < 30) {
            return @"just now";
        } else {
            return @"half a min";
        }
    } else if (interval >=60 && interval < 60*60) {
        NSInteger minute =  interval / 60;
        if (minute == 1) {
            return [NSString stringWithFormat:@"%ldmin", (long)minute];
        } else {
            return [NSString stringWithFormat:@"%ldmins", (long)minute];
        }
    } else if (interval >= 60*60 && interval < 60*60*24) {
        NSInteger hour =  interval / (60*60);
        if (hour == 1) {
            return [NSString stringWithFormat:@"%ldhour", (long)hour];
        } else {
            return [NSString stringWithFormat:@"%ldhours", (long)hour];
        }
    } else if (interval >= 60*60*24 && interval <60*60*24*30) {
        NSUInteger day =  interval / (60*60*24);
        if (day == 1) {
            return [NSString stringWithFormat:@"%ldday", (long)day];
        } else {
            return [NSString stringWithFormat:@"%lddays", (long)day];
        }
    }
    else {
        return [NSString stringWithFormat:@"%lds", (long)interval];
    }
    
}

@end
