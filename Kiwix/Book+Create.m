//
//  Book+Create.m
//  Kiwix
//
//  Created by Chris Li on 1/11/15.
//  Copyright (c) 2015 Chris Li. All rights reserved.
//

#import "Book+Create.h"

#define ARTICLE_COUNT @"articleCount"
#define MEDIA_COUNT @"mediaCount"
#define GLOBAL_COUNT @"globalCount"

#define ID_STRING @"idString"
#define TITLE @"title"
#define DESCRIPTION @"desc"
#define LANGUAGE @"language"
#define DATE @"date"
#define CREATOR @"creator"
#define PUBLISHER @"publisher"
#define ORIGIN_ID @"originID"
#define FILE_SIZE @"fileSize"
#define FAVICON @"favicon"

@implementation Book (Create)

+ (Book *)bookWithReaderInfo:(NSDictionary *)infoDictionary inManagedObjectContext:(NSManagedObjectContext *)context {
    Book *book = nil;
    
    NSString *idString = [infoDictionary objectForKey:ID_STRING];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Book"];
    request.predicate = [NSPredicate predicateWithFormat:@"idString = %@", idString];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || ([matches count] > 1)) {
        //handling error
    } else if ([matches count]) {
        book = [matches firstObject];
    } else {
        book = [NSEntityDescription insertNewObjectForEntityForName:@"Book" inManagedObjectContext:context];
        book.idString = idString;
        book.fileName = [[infoDictionary objectForKey:@"fileName"] stringByReplacingOccurrencesOfString:@".zim" withString:@""];
        
        book.articleCount = [infoDictionary objectForKey:ARTICLE_COUNT];
        book.mediaCount = [infoDictionary objectForKey:MEDIA_COUNT];
        book.globalCount = [infoDictionary objectForKey:GLOBAL_COUNT];
        
        book.title = [infoDictionary objectForKey:TITLE];
        book.desc = [infoDictionary objectForKey:DESCRIPTION];
        book.language = [infoDictionary objectForKey:LANGUAGE];
        book.date = [infoDictionary objectForKey:DATE];
        book.creator = [infoDictionary objectForKey:CREATOR];
        book.publisher = [infoDictionary objectForKey:PUBLISHER];
        book.fileSize = [infoDictionary objectForKey:FILE_SIZE];
        book.favIcon = [infoDictionary objectForKey:FAVICON];
    }
    
    return book;
}

+ (Book *)bookWithBookIDString:(NSString *)idString inManagedObjectContext:(NSManagedObjectContext *)context {
    Book *book = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Book"];
    request.predicate = [NSPredicate predicateWithFormat:@"idString = %@", idString];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || ([matches count] > 1)) {
        //handling error
    } else if ([matches count]) {
        book = [matches firstObject];
    } else {
        //book not exist
    }
    return book;
}

@end
