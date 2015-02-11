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

+ (NSString *)docDirPath;
+ (NSString *)libDirPath;
+ (NSString *)inboxDirPath;

+ (void)processFilesWithManagedObjectContext:(NSManagedObjectContext *)context;
+ (void)moveZimFileFromDocumentDirectoryToLibraryDirectory; //Move all zim files in document dir to app support dir
//Add idString, book title, book original file name in 
+ (void)addAllFilesInLibraryDirToDatabaseInManagedObjectContext:(NSManagedObjectContext *)context;
+ (void)deleteBookWithID:(NSString *)idString inManagedObjectContext:(NSManagedObjectContext *)context; //Delete a book in Coredata DB and delete the relevent file on disk

+ (void)addNoiCloudBackupAttributeToAllZimFilesInLibraryDir;
+ (void)removeNoiCloudBackupAttributeFromAllZimFilesInLibraryDir;
+ (void)addNoiCloudBackupAttributeToZimFilesInLibraryDirWithZimFileID:(NSString *)fileID;
+ (void)removeNoiCloudBackupAttributeFromZimFilesInLibraryDirWithZimFileID:(NSString *)fileID;


@end
