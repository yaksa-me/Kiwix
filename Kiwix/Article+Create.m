//
//  Article+Create.m
//  Kiwix
//
//  Created by Chris Li on 1/11/15.
//  Copyright (c) 2015 Chris Li. All rights reserved.
//

#import "Article+Create.h"
#import "Book+Create.h"

@implementation Article (Create)

+ (Article *)articleWithTitle:(NSString *)title andBook:(Book *)book inManagedObjectContext:(NSManagedObjectContext *)context {
    Article *article = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Article"];
    request.predicate = [NSPredicate predicateWithFormat:@"title = %@ AND belongsToBook = %@", title, book];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || ([matches count] > 1)) {
        //handling error
    } else if ([matches count]) {
        article = [matches firstObject];
    } else {
        article = [NSEntityDescription insertNewObjectForEntityForName:@"Article" inManagedObjectContext:context];
        article.title = title;
        article.belongsToBook = book;
    }
    return article;
}

+ (void)insertArticleWithTitle:(NSString *)title andBookIDString:(NSString *)idString inManagedObjectContext:(NSManagedObjectContext *)context {
    Article *article = nil;
    
    article = [NSEntityDescription insertNewObjectForEntityForName:@"Article" inManagedObjectContext:context];
    article.title = title;
    article.belongsToBook = [Book bookWithBookIDString:idString inManagedObjectContext:context];
}

@end
