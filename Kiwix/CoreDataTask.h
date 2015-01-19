//
//  CoreDataTask.h
//  Kiwix
//
//  Created by Chris Li on 1/15/15.
//  Copyright (c) 2015 Chris Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Book.h"
@interface CoreDataTask : NSObject

+ (NSArray *)allBooksInManagedObjectContext:(NSManagedObjectContext *)context;  //An array of Book object.
+ (NSArray *)allBookTitleInManagedObjectContext:(NSManagedObjectContext *)context;

+ (Book *)bookWithIDString:(NSString *)idString inManagedObjectContext:(NSManagedObjectContext *)context;



+ (NSArray *)allArticlesInManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray *)articlesTitleFilteredBySearchText:(NSString *)searchText inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray *)allArticlesFromBook:(Book *)book inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray *)articlesReadHistoryInManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray *)articlesBookmarkedInManagedObjectContext:(NSManagedObjectContext *)context;

+ (Article *)articleWithTitle:(NSString *)articleTitle fromBook:(Book *)book inManagedObjectContext:(NSManagedObjectContext *)context;



@end
