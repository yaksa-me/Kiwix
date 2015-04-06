//
//  ZimMultiReader.h
//  Kiwix
//
//  Created by Chris Li on 3/29/15.
//  Copyright (c) 2015 Chris Li. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZimMultiReader : NSObject

+ (instancetype)sharedInstance;

#pragma mark - Data Loading
- (NSData *)dataWithZimFileID:(NSString *)id andContentURLString:(NSString *)string;

#pragma mark - Search
- (NSArray *)universalSearchSuggestionWithSearchTerm:(NSString *)searchTerm;//return an array of article Paths, e.g., ID/Article Title
- (NSString *)articleURLStringFromZimFile:(NSString *)idString andTitle:(NSString *)title;

@end
