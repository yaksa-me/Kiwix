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
        book.creator = [dic objectForKey:BOOK_CREATOR] ? [dic objectForKey:BOOK_CREATOR] : @"N/A";
        book.date =  [dateFormatter dateFromString:[dic objectForKey:BOOK_DATE]];
        book.desc = [dic objectForKey:BOOK_DESCRIPTION] ? [dic objectForKey:BOOK_DESCRIPTION]: @"N/A";
        book.language = [dic objectForKey:BOOK_LANGUAGE] ? [dic objectForKey:BOOK_LANGUAGE] : @"N/A";
        book.mediaCount = [numberFormatter numberFromString:[dic objectForKey:BOOK_MEDIA_COUNT]];
        book.publisher = [dic objectForKey:BOOK_PUBLISHER] ? [dic objectForKey:BOOK_PUBLISHER]: @"N/A";
        book.title = [dic objectForKey:BOOK_TITLE] ? [dic objectForKey:BOOK_TITLE] : @"N/A";
        book.meta4URL = [dic objectForKey:BOOK_META4_URL];
        book.fileSize = [numberFormatter numberFromString:[dic objectForKey:BOOK_SIZE]];
        
        if ([dic objectForKey:BOOK_FAVICON]) {
            book.favIcon = [[NSData alloc] initWithBase64EncodedString:[dic objectForKey:BOOK_FAVICON] options:NSDataBase64DecodingIgnoreUnknownCharacters];
        }
    }
}

+ (void)deleteAllBooksNonLocalInManagedObjectContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Book"];
    request.predicate = [NSPredicate predicateWithFormat:@"downloadProgress == nil"];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (matches) {
        for (Book *book in matches) {
            [context deleteObject:book];
        }
    }
}

+ (NSString *)fileNameOfBook:(Book *)book {
    NSString *meta4URL = book.meta4URL;
    NSString *fileName = [[meta4URL pathComponents] lastObject];
    fileName = [fileName stringByReplacingOccurrencesOfString:@".meta4" withString:@""];
    return fileName;
}

+ (NSMutableDictionary *)bookDownloadProgesssDicInManagedObjectContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Book"];
    request.predicate = [NSPredicate predicateWithFormat:@"downloadProgress != nil", [NSNumber numberWithFloat:0.0]];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    if (matches) {
        for (Book *book in matches) {
            [dic setValue:book.downloadProgress forKey:book.idString];
        }
    }
    return dic;
}
@end
