//
//  Book+Task.m
//  Kiwix
//
//  Created by Chris Li on 4/2/15.
//  Copyright (c) 2015 Chris Li. All rights reserved.
//

#import "Book+Task.h"
#import "Marco.h"

@implementation Book (Task)

+ (Book *)bookWithReaderInfo:(NSDictionary *)infoDictionary inManagedObjectContext:(NSManagedObjectContext *)context {
    NSString *idString = [infoDictionary valueForKey:BOOK_ID_STRING];
    Book *book = [self bookWithBookIDString:idString inManagedObjectContext:context];
    
    book.fileName = [[infoDictionary objectForKey:@"fileName"] stringByReplacingOccurrencesOfString:@".zim" withString:@""];
    
    book.articleCount = [infoDictionary objectForKey:BOOK_ARTICLE_COUNT];
    book.mediaCount = [infoDictionary objectForKey:BOOK_MEDIA_COUNT];
    
    book.title = [infoDictionary objectForKey:BOOK_TITLE];
    book.desc = [infoDictionary objectForKey:BOOK_DESCRIPTION];
    book.language = [infoDictionary objectForKey:BOOK_LANGUAGE];
    book.date = [infoDictionary objectForKey:BOOK_DATE];
    book.creator = [infoDictionary objectForKey:BOOK_CREATOR];
    book.publisher = [infoDictionary objectForKey:BOOK_PUBLISHER];
    //book.fileSize = [infoDictionary objectForKey:BOOK_FILE_SIZE];
    book.favIcon = [infoDictionary objectForKey:BOOK_FAVICON];
    
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
    } else if ([matches count] == 1) {
        book = [matches firstObject];
    } else {
        book = [NSEntityDescription insertNewObjectForEntityForName:@"Book" inManagedObjectContext:context];
        book.idString = idString;
    }
    return book;
}

+ (void)bookMetadataToCoreDataWithMetadataArray:(NSArray *)array inManagedObjectContext:(NSManagedObjectContext *)context {
    for (NSDictionary *dic in array) {
        for (NSString *key in [dic allKeys]) {
            NSString *newString = [[dic valueForKey:key] stringByTrimmingCharactersInSet:[NSCharacterSet punctuationCharacterSet]];
            [dic setValue:newString forKey:key];
        }
        
        NSString *idString = [dic objectForKey:BOOK_ID_STRING];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        
        Book *book = [self bookWithBookIDString:idString inManagedObjectContext:context];
        book.articleCount = [dic objectForKey:BOOK_ARTICLE_COUNT];
        book.creator = [dic objectForKey:BOOK_CREATOR];
        book.date =  [dateFormatter dateFromString:[dic objectForKey:BOOK_DATE]];
        book.desc = [dic objectForKey:BOOK_DESCRIPTION];
        book.favIcon = [[dic objectForKey:BOOK_FAVICON] dataUsingEncoding:NSUTF8StringEncoding];
        book.language = [dic objectForKey:BOOK_LANGUAGE];
        book.mediaCount = [numberFormatter numberFromString:[dic objectForKey:BOOK_MEDIA_COUNT]];
        book.publisher = [dic objectForKey:BOOK_PUBLISHER];
        book.title = [dic objectForKey:BOOK_TITLE] ? [dic objectForKey:BOOK_TITLE] : @"N/A";
        book.meta4URL = [dic objectForKey:BOOK_META4_URL];
    }
}

+ (void)deleteAllBooksNonLocalInManagedObjectContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Book"];
    request.predicate = [NSPredicate predicateWithFormat:@"isLocal = %@", [NSNumber numberWithBool:NO]];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (matches) {
        for (Book *book in matches) {
            [context deleteObject:book];
        }
    }
}

@end
