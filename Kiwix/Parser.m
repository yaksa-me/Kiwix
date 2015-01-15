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

@end
