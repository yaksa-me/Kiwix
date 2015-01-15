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

+ (Article *)articleWithTitle:(NSString *)title andBookIDNumber:(NSString *)idNumber inManagedObjectContext:(NSManagedObjectContext *)context {
    Article *article = nil;
    
    article = [NSEntityDescription insertNewObjectForEntityForName:@"Article" inManagedObjectContext:context];
    article.title = title;
    article.belongsToBook = [Book bookWithBookIDNumber:idNumber inManagedObjectContext:context];

    return article;
}

+ (void)insertArticleWithTitle:(NSString *)title andBookIDNumber:(NSString *)idNumber inManagedObjectContext:(NSManagedObjectContext *)context {
    Article *article = nil;
    
    article = [NSEntityDescription insertNewObjectForEntityForName:@"Article" inManagedObjectContext:context];
    article.title = title;
    article.belongsToBook = [Book bookWithBookIDNumber:idNumber inManagedObjectContext:context];
}

@end
