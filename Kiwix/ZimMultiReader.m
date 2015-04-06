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
#import "Book+Task.h"
#import "AppDelegate.h"

@interface ZimMultiReader ()

@property (strong, nonatomic)NSMutableDictionary *dicOfZimReaders; // A dic with fileID as key and ZimReader as obj
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

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
        self.managedObjectContext = ((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;
        
        self.dicOfZimReaders = [[NSMutableDictionary alloc] init];
        NSArray *arrayOfURL = [File zimFileURLsInDocDir];
        for (NSURL *url in arrayOfURL) {
            zimReader *reader = [[zimReader alloc] initWithZIMFileURL:url];
            NSString *fileIDString = [reader getID];
            [self.dicOfZimReaders setObject:reader forKey:fileIDString];
            
            Book *book = [Book bookWithBookIDString:fileIDString inManagedObjectContext:self.managedObjectContext];
            
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
            NSString *articlePath = [idString stringByAppendingPathComponent:articleString];
            [searchResult addObject:articlePath];
        }
    }
    return searchResult;
}

- (NSString *)articleURLStringFromZimFile:(NSString *)idString andTitle:(NSString *)title {
    zimReader *reader = [self.dicOfZimReaders objectForKey:idString];
    return [reader pageURLFromTitle:title];
}
@end
