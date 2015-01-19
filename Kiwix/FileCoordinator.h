//
//  FileProcessor.h
//  Kiwix
//
//  Created by Chris Li on 1/11/15.
//  Copyright (c) 2015 Chris Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface FileCoordinator : NSObject

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
- (void)processAllBooks;
+ (void)moveZimFileFromDocumentDirectoryToApplicationSupport;
+ (void)addAllFilesInApplicationSupportDirToDatabaseInManagedObjectContext:(NSManagedObjectContext *)context;

+ (void)deleteBookWithID:(NSString *)idString inManagedObjectContext:(NSManagedObjectContext *)context; //Delete a book in Coredata DB and delete the relevent file on disk

@end
