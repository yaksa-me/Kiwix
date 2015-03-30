//
//  ZimMultiReader.m
//  Kiwix
//
//  Created by Chris Li on 3/29/15.
//  Copyright (c) 2015 Chris Li. All rights reserved.
//

#import "ZimMultiReader.h"
#import "zimReader.h"
#import "File.h"
#import "NSURL+KiwixURLProtocol.h"

@interface ZimMultiReader ()

@property (strong, nonatomic)NSMutableDictionary *dicOfZimReaders; // A dic with fileID as key and ZimReader as obj

@end

@implementation ZimMultiReader

+ (instancetype)sharedInstance
{
    static ZimMultiReader *sharedInstance = nil;
    static dispatch_once_t oncePredicate;

    dispatch_once(&oncePredicate, ^{
        sharedInstance = [[ZimMultiReader alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init { // init reader for all zim file in doc dir
    self = [super init];
    if (self) {
        self.dicOfZimReaders = [[NSMutableDictionary alloc] init];
        NSArray *arrayOfURL = [File zimFileURLsInDocDir];
        for (NSURL *url in arrayOfURL) {
            zimReader *reader = [[zimReader alloc] initWithZIMFileURL:url];
            [self.dicOfZimReaders setObject:reader forKey:[reader getID]];
        }
    }
    return self;
}

#pragma mark - Data Loading
- (NSData *)dataWithZimFileID:(NSString *)id andContentURLString:(NSString *)string {
    zimReader *reader = [self.dicOfZimReaders objectForKey:id];
    NSData *data = [reader dataWithContentURLString:string];
    return data;
}

#pragma mark - Search
- (NSArray *)universalSearchSuggestionWithSearchTerm:(NSString *)searchTerm {
    NSMutableArray *searchResult = [[NSMutableArray alloc] init];
    for (NSString *idString in [self.dicOfZimReaders allKeys]) {
        zimReader *reader = [self.dicOfZimReaders objectForKey:idString];
        NSArray *result =  [reader searchSuggestionsSmart:searchTerm];
        for (NSString *articleString in result) {
            NSURL *articleURL = [NSURL kiwixURLWithZIMFileIDString:idString articleString:articleString];
            [searchResult addObject:articleURL];
        }
    }
    return searchResult;
}
@end
