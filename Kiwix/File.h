//
//  File.h
//  Kiwix
//
//  Created by Chris Li on 3/4/15.
//  Copyright (c) 2015 Chris Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface File : NSObject

#pragma marks - File Paths & URLs
+ (NSString *)docDirPath;
+ (NSString *)libDirPath;
+ (NSString *)inboxDirPath;
+ (NSURL *)docDirURL;
+ (NSArray *)zimFileURLsInDocDir;
+ (NSUInteger)numberOfZimFilesInDocDir;

#pragma mark - File Position & Coredata
+ (void)processFilesWithManagedObjectContext:(NSManagedObjectContext *)context;
+ (void)moveZimFileFromDocumentDirectoryToLibraryDirectory; //Move all zim files in document dir to app support dir
//Add idString, book title, book original file name in
+ (void)addAllFilesInLibraryDirToDatabaseInManagedObjectContext:(NSManagedObjectContext *)context;
+ (void)deleteBookWithID:(NSString *)idString inManagedObjectContext:(NSManagedObjectContext *)context; //Delete a book in Coredata DB and delete the relevent file on disk

+ (void)addNoiCloudBackupAttributeToAllZimFilesInLibraryDir;
+ (void)removeNoiCloudBackupAttributeFromAllZimFilesInLibraryDir;
+ (void)addNoiCloudBackupAttributeToZimFilesInLibraryDirWithZimFileID:(NSString *)fileID;
+ (void)removeNoiCloudBackupAttributeFromZimFilesInLibraryDirWithZimFileID:(NSString *)fileID;

+ (NSArray *)zimFileIDsInLibraryDirectory;
+ (NSURL *)zimFileURLInLibraryDirectoryFormFileID:(NSString *)fileID;
+ (BOOL)zimFileExistInLibraryDirectoryWithFileID:(NSString *)fileID;



@end
