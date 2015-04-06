//
//  CoreDataTask.m
//  Kiwix
//
//  Created by Chris Li on 1/15/15.
//  Copyright (c) 2015 Chris Li. All rights reserved.
//

#import "CoreDataTask.h"

@implementation CoreDataTask

#pragma mark - Book methods
+ (NSArray *)allBooksInManagedObjectContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Book"];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"fileName" ascending:YES];
    request.sortDescriptors = @[sortDescriptor];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error) {
        //handling error
    }
    return matches;
}

+ (Book *)bookWithIDString:(NSString *)idString inManagedObjectContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Book"];
    request.predicate = [NSPredicate predicateWithFormat:@"idString = %@", idString];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || ([matches count] > 1)) {
        //handling error
    }
    return [matches firstObject];
}

#pragma mark - Article methods
+ (NSArray *)allArticlesInManagedObjectContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Article"];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error) {
        //handling error
    }
    return matches;
}

+ (NSArray *)allArticlesFromBook:(Book *)book inManagedObjectContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Article"];
    request.predicate = [NSPredicate predicateWithFormat:@"belongsToBook = %@", book];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error) {
        //handling error
    }
    return matches;
}

+ (NSArray *)articlesTitleFilteredBySearchText:(NSString *)searchText inManagedObjectContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Article"];
    request.predicate = [NSPredicate predicateWithFormat:@"title contains[c] %@", searchText];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error) {
        //handling error
    }
    return matches;
}

+ (NSArray *)articlesReadHistoryInManagedObjectContext:(NSManagedObjectContext *)context {
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

+ (NSArray *)articlesReadHistoryInBook:(Book *)book InManagedObjectContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Article"];
    request.predicate = [NSPredicate predicateWithFormat:@"lastReadDate != nil AND belongsToBook == %@", book];
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

+ (NSArray *)articlesBookmarkedInBook:(Book *)book InManagedObjectContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Article"];
    request.predicate = [NSPredicate predicateWithFormat:@"isBookmarked = YES AND belongsToBook == %@", book];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"lastReadDate" ascending:NO];
    request.sortDescriptors = @[sortDescriptor];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error) {
        //handling error
    }
    
    return matches;
}

+ (Article *)articleWithTitle:(NSString *)articleTitle fromBook:(Book *)book inManagedObjectContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Article"];
    request.predicate = [NSPredicate predicateWithFormat:@"belongsToBook = %@ AND title = %@", book, articleTitle];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || ([matches count] > 1)) {
        //handling error
    }
    return [matches firstObject];
}

+ (Article *)lastReadArticleInManagedObjectContext:(NSManagedObjectContext *)context {
    NSArray *articlesHistory = [self articlesReadHistoryInManagedObjectContext:context];
    return [articlesHistory firstObject];
}

+ (Article *)lastReadArticleFromBook:(Book *)book inManagedObjectContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Article"];
    request.predicate = [NSPredicate predicateWithFormat:@"lastReadDate != nil AND belongsToBook == %@", book];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"lastReadDate" ascending:NO];
    request.sortDescriptors = @[sortDescriptor];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error) {
        //handling error
    }
    
    return [matches firstObject];
}

+ (void)deleteArticleWithTitle:(NSString *)title inBook:(Book*)book inManagedObjectContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Article"];
    request.predicate = [NSPredicate predicateWithFormat:@"title = %@ AND belongsToBook = %@", title, book];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || ([matches count] > 1)) {
        //Should never get here, something is wrong.
    } else if ([matches count]) {
        //One article exist
        [context deleteObject:[matches firstObject]];
    } else {
        //book not exist
    }

}

+ (void)deleteArticle:(Article *)article inManagedObjectContext:(NSManagedObjectContext *)context {
    [context deleteObject:(NSManagedObject *)article];
}

@end
