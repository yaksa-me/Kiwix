//
//  Book+Task.h
//  Kiwix
//
//  Created by Chris Li on 4/2/15.
//  Copyright (c) 2015 Chris Li. All rights reserved.
//

#import "Book.h"

@interface Book (Task)

+ (Book *)bookWithReaderInfo:(NSDictionary *)infoDictionary inManagedObjectContext:(NSManagedObjectContext *)context;
+ (Book *)bookWithBookIDString:(NSString *)idString inManagedObjectContext:(NSManagedObjectContext *)context;
+ (void)bookMetadataToCoreDataWithMetadataArray:(NSArray *)array inManagedObjectContext:(NSManagedObjectContext *)context;
+ (void)deleteAllBooksNonLocalInManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSString *)fileNameOfBook:(Book *)book;
+ (NSMutableDictionary *)bookDownloadProgesssDicInManagedObjectContext:(NSManagedObjectContext *)context; // A dic with book idString as key and download progress <NSNumber> as value
@end
