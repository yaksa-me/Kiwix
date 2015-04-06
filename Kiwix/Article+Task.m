//
//  Article+Task.m
//  Kiwix
//
//  Created by Chris Li on 4/2/15.
//  Copyright (c) 2015 Chris Li. All rights reserved.
//

#import "Article+Task.h"
#import "Marco.h"


@implementation Article (Task)

+ (Article *)articleWithTitleInfo:(NSDictionary *)articleInfo andBook:(Book *)book inManagedObjectContext:(NSManagedObjectContext *)context {
    Article *article = nil;
    
    NSString *articleTitle = [articleInfo objectForKey:ARTICLE_TITLE];
    NSString *articleRelativeURL = [articleInfo objectForKey:ARTICLE_RELATIVE_URL];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Article"];
    request.predicate = [NSPredicate predicateWithFormat:@"relativeURL = %@ AND belongsToBook = %@", articleRelativeURL, book];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || ([matches count] > 1)) {
        //handling error
    } else if ([matches count]) {
        article = [matches firstObject];
    } else {
        article = [NSEntityDescription insertNewObjectForEntityForName:@"Article" inManagedObjectContext:context];
        article.title = articleTitle;
        article.relativeURL = articleRelativeURL;
        article.lastReadDate = [NSDate date];
        article.belongsToBook = book;
    }
    return article;
}

+ (NSArray *)articlesHaveBeenReadInManagedObjectContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Article"];
    request.predicate = [NSPredicate predicateWithFormat:@"lastReadDate != nil"];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"lastReadDate" ascending:NO];
    request.sortDescriptors = @[sortDescriptor];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error) {
        //handling error
    }
    
    return matches;
}
+ (NSArray *)articlesBookmarkedInManagedObjectContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Article"];
    request.predicate = [NSPredicate predicateWithFormat:@"isBookmarked = YES"];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"lastReadDate" ascending:NO];
    request.sortDescriptors = @[sortDescriptor];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error) {
        //handling error
    }
    
    return matches;
}

+ (void)deleteArticle:(Article *)article inManagedObjectContext:(NSManagedObjectContext *)context {
    [context deleteObject:(NSManagedObject *)article];
}

@end
