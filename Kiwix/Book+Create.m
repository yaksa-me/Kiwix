//
//  Book+Create.m
//  Kiwix
//
//  Created by Chris Li on 1/11/15.
//  Copyright (c) 2015 Chris Li. All rights reserved.
//

#import "Book+Create.h"

@implementation Book (Create)

+ (Book *)bookWithReaderInfo:(NSDictionary *)infoDictionary inManagedObjectContext:(NSManagedObjectContext *)context {
    Book *book = nil;
    
    NSString *idNumber = [infoDictionary objectForKey:@"idNumber"];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Book"];
    request.predicate = [NSPredicate predicateWithFormat:@"idNumber = %@", idNumber];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || ([matches count] > 1)) {
        //handling error
    } else if ([matches count]) {
        book = [matches firstObject];
    } else {
        book = [NSEntityDescription insertNewObjectForEntityForName:@"Book" inManagedObjectContext:context];
        book.idNumber = idNumber;
        book.title = [infoDictionary objectForKey:@"title"];
    }
    
    return book;
}

+ (Book *)bookWithBookIDNumber:(NSString *)idNumber inManagedObjectContext:(NSManagedObjectContext *)context {
    Book *book = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Book"];
    request.predicate = [NSPredicate predicateWithFormat:@"idNumber = %@", idNumber];
    
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
