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

+ (NSArray *)arrayOfBookMetadataFromData:(NSData *)data {
    TFHpple *bookListparser= [TFHpple hppleWithHTMLData:data];
    NSString *htmlXpathQueryString = @"//library/book";
    NSArray *parsingResultArray = [bookListparser searchWithXPathQuery:htmlXpathQueryString];
    
    NSMutableArray *arrayOfBookMetadataDic = [[NSMutableArray alloc] init];
    for (TFHppleElement *element in parsingResultArray) {
        [arrayOfBookMetadataDic addObject:element.attributes];
    }
    
    return arrayOfBookMetadataDic;
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
    } else if (interval >= 60*60*24 && interval <60*60*24*7) {
        NSUInteger day =  interval / (60*60*24);
        if (day == 1) {
            return [NSString stringWithFormat:@"%ldday", (long)day];
        } else {
            return [NSString stringWithFormat:@"%lddays", (long)day];
        }
    } else if (interval >= 60*60*24*7 && interval <60*60*24*30) {
        NSUInteger week =  interval / (60*60*24*7);
        if (week == 1) {
            return [NSString stringWithFormat:@"%ldweek", (long)week];
        } else {
            return [NSString stringWithFormat:@"%ldweeks", (long)week];
        }
    } else if (interval >= 60*60*24*30 && interval <60*60*24*365) {
        NSUInteger month =  interval / (60*60*24*30);
        if (month == 1) {
            return [NSString stringWithFormat:@"%ldmonth", (long)month];
        } else {
            return [NSString stringWithFormat:@"%ldmonths", (long)month];
        }
    } else {
        return [NSString stringWithFormat:@"%lds", (long)interval];
    }
    
}

+ (NSString *)articleCountString:(NSUInteger)articleCount {
    NSString *articleCountString = [self abbreviateNumber:articleCount withDecimal:2];
    return articleCountString;
}

+ (NSString *)abbreviateNumber:(int)num withDecimal:(int)dec {
    
    NSString *abbrevNum;
    float number = (float)num;
    
    NSArray *abbrev = @[@"K", @"M", @"B"];
    
    for (int i = abbrev.count - 1; i >= 0; i--) {
        
        // Convert array index to "1000", "1000000", etc
        int size = pow(10,(i+1)*3);
        
        if(size <= number) {
            // Here, we multiply by decPlaces, round, and then divide by decPlaces.
            // This gives us nice rounding to a particular decimal place.
            number = round(number*dec/size)/dec;
            
            NSString *numberString = [self floatToString:number];
            
            // Add the letter for the abbreviation
            abbrevNum = [NSString stringWithFormat:@"%@%@", numberString, [abbrev objectAtIndex:i]];
        }
    }
    return abbrevNum;
}

+ (NSString *) floatToString:(float) val {
    
    NSString *ret = [NSString stringWithFormat:@"%.1f", val];
    unichar c = [ret characterAtIndex:[ret length] - 1];
    
    while (c == 48 || c == 46) { // 0 or .
        ret = [ret substringToIndex:[ret length] - 1];
        c = [ret characterAtIndex:[ret length] - 1];
    }
    
    return ret;
}
@end
