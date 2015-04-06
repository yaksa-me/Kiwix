//
//  CoreDataTask.h
//  Kiwix
//
//  Created by Chris Li on 1/15/15.
//  Copyright (c) 2015 Chris Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Book+Task.h"
@interface CoreDataTask : NSObject

+ (NSArray *)allBooksInManagedObjectContext:(NSManagedObjectContext *)context;  //An array of Book object.

+ (Book *)bookWithIDString:(NSString *)idString inManagedObjectContext:(NSManagedObjectContext *)context;


+ (NSArray *)allArticlesInManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray *)allArticlesFromBook:(Book *)book inManagedObjectContext:(NSManagedObjectContext *)context;

+ (NSArray *)articlesTitleFilteredBySearchText:(NSString *)searchText inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray *)articlesReadHistoryInManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray *)articlesReadHistoryInBook:(Book *)book InManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray *)articlesBookmarkedInManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray *)articlesBookmarkedInBook:(Book *)book InManagedObjectContext:(NSManagedObjectContext *)context;

+ (Article *)articleWithTitle:(NSString *)articleTitle fromBook:(Book *)book inManagedObjectContext:(NSManagedObjectContext *)context;

+ (Article *)lastReadArticleInManagedObjectContext:(NSManagedObjectContext *)context;
+ (Article *)lastReadArticleFromBook:(Book *)book inManagedObjectContext:(NSManagedObjectContext *)context;


+ (void)deleteArticleWithTitle:(NSString *)title inBook:(Book*)book inManagedObjectContext:(NSManagedObjectContext *)context;
+ (void)deleteArticle:(Article *)article inManagedObjectContext:(NSManagedObjectContext *)context;


@end
