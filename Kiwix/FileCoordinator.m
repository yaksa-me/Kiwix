//
//  FileProcessor.m
//  Kiwix
//
//  Created by Chris Li on 1/11/15.
//  Copyright (c) 2015 Chris Li. All rights reserved.
//

#import "FileCoordinator.h"
#import "Book+Create.h"
#import "Article+Create.h"
#import "zimReader.h"
#import "Parser.h"
#import "zimFileFinder.h"
#import "Preference.h"

@interface FileCoordinator ()

@property (strong, nonatomic)NSArray *filePaths;

@end

@implementation FileCoordinator

#pragma marks - File Paths
+ (NSString *)docDirPath {
    NSArray *docPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirPath = ([docPaths count] > 0) ? [docPaths objectAtIndex:0] : nil;
    return documentDirPath;
}

+ (NSString *)libDirPath {
    NSArray *libDirPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libDirPath = ([libDirPaths count] > 0) ? [libDirPaths objectAtIndex:0] : nil;
    return libDirPath;
}

#pragma mark - File Position & Coredata
+ (void)processFilesWithManagedObjectContext:(NSManagedObjectContext *)context {
    [self moveZimFileFromDocumentDirectoryToLibraryDirectory];
    [self addAllFilesInLibraryDirToDatabaseInManagedObjectContext:context];
    [self renameZimFilesInLibDir];
    
    if ([Preference isBackingUpFilesToiCloud]) {
        [self removeNoiCloudBackupAttributeFromAllZimFilesInAppSupportDir];
    } else {
        [self addNoiCloudBackupAttributeToAllZimFilesInAppSupportDir];
    }
}

+ (void)moveZimFileFromDocumentDirectoryToLibraryDirectory {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //Create App Support Dir if not exist
    if (![fileManager fileExistsAtPath:[self libDirPath]]) {
        [fileManager createDirectoryAtPath:[self libDirPath] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSArray *allFileListInDocDir = [fileManager contentsOfDirectoryAtPath:[self docDirPath] error:nil];
    
    //Helper
    NSLog(@"%@", [allFileListInDocDir description]);
    
    //Move all zim file in Doc dir to App Support Dir
    for (NSString *fileName in allFileListInDocDir) { //fileName has extention
        NSString *extention = [[[fileName componentsSeparatedByString:@"."] lastObject] lowercaseString];
        if ([extention isEqualToString:@"zim"]) {
            NSString *filePathInDocDir = [[[self docDirPath] stringByAppendingString:@"/"] stringByAppendingString:fileName];
            NSString *filePathInLibDir = [[[self libDirPath] stringByAppendingString:@"/"] stringByAppendingString:fileName];
            NSError *error;
            [fileManager moveItemAtPath:filePathInDocDir toPath:filePathInLibDir error:&error];
        }
    }
    
    //Helper
    NSArray *allFileListInLibDir = [fileManager contentsOfDirectoryAtPath:[self libDirPath] error:nil];
    NSLog(@"%@", [allFileListInLibDir description]);
}

+ (void)addAllFilesInLibraryDirToDatabaseInManagedObjectContext:(NSManagedObjectContext *)context {
    NSString *libDirPath = [self libDirPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *allFileListInLibDir = [fileManager contentsOfDirectoryAtPath:libDirPath error:nil];
    
    for (NSString *fileName in allFileListInLibDir) { // fileName has extentions
        NSString *extention = [[[fileName componentsSeparatedByString:@"."] lastObject] lowercaseString];
        if ([extention isEqualToString:@"zim"]) {
            NSString *filePathInLibDir = [[libDirPath stringByAppendingString:@"/"] stringByAppendingString:fileName];
            
            zimReader *reader = [[zimReader alloc] initWithZIMFileURL:[NSURL fileURLWithPath:filePathInLibDir]];
            NSMutableDictionary *infoDictionary = [[NSMutableDictionary alloc] init];
            [infoDictionary setObject:[reader getID] forKey:@"idString"];
            [infoDictionary setObject:[reader getTitle] forKey:@"title"];
            [infoDictionary setObject:fileName forKey:@"fileName"];
            [infoDictionary setObject:[NSNumber numberWithUnsignedInteger:[reader getArticleCount]] forKey:@"articleCount"];
            
            [Book bookWithReaderInfo:infoDictionary inManagedObjectContext:context];
        }
    }
}

+ (void)renameZimFilesInLibDir {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *allFileListInLibDir = [fileManager contentsOfDirectoryAtPath:[self libDirPath] error:nil];
    for (NSString *fileName in allFileListInLibDir) {
        NSString *extention = [[[fileName componentsSeparatedByString:@"."] lastObject] lowercaseString];
        if ([extention isEqualToString:@"zim"]) {
            NSString *oldFilePath = [[[self libDirPath] stringByAppendingString:@"/"] stringByAppendingString:fileName];
            NSURL *oldFIleURl = [NSURL fileURLWithPath:oldFilePath];
            NSString *idString  =[[[zimReader alloc] initWithZIMFileURL:oldFIleURl] getID];
            NSString *newFilePath = [[[[self libDirPath] stringByAppendingString:@"/"] stringByAppendingString:idString] stringByAppendingString:@".zim"];
            NSError *error;
            [fileManager moveItemAtPath:oldFilePath toPath:newFilePath error:&error];
        }
    }
}

+ (void)deleteBookWithID:(NSString *)idString inManagedObjectContext:(NSManagedObjectContext *)context {
    //Delete in Coredata database
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Book"];
    request.predicate = [NSPredicate predicateWithFormat:@"idString = %@", idString];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || ([matches count] > 1)) {
        //Should never get here, something is wrong.
    } else if ([matches count]) {
        //One book exist
        [context deleteObject:[matches firstObject]];
    } else {
        //book not exist
    }
    
    //Delete on disk
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePathInLibDir = [[[[self libDirPath] stringByAppendingString:@"/"] stringByAppendingString:idString] stringByAppendingString:@".zim"];
    [fileManager removeItemAtPath:filePathInLibDir error:nil];
}

#pragma mark - File Attribute Management
+ (void)addNoiCloudBackupAttributeToAllZimFilesInAppSupportDir {
    NSArray *fileIDArray = [zimFileFinder zimFileIDsInAppSupportDirectory];
    for (NSString *fileID in fileIDArray) {
        [self addNoiCloudBackupAttributeToZimFilesInAppSupportDirWithZimFileID:fileID];
    }
}

+ (void)removeNoiCloudBackupAttributeFromAllZimFilesInAppSupportDir {
    NSArray *fileIDArray = [zimFileFinder zimFileIDsInAppSupportDirectory];
    for (NSString *fileID in fileIDArray) {
        [self removeNoiCloudBackupAttributeFromZimFilesInAppSupportDirWithZimFileID:fileID];
    }
}

+ (void)addNoiCloudBackupAttributeToZimFilesInAppSupportDirWithZimFileID:(NSString *)fileID {
    NSURL *fileURL = [zimFileFinder zimFileURLInAppSupportDirectoryFormFileID:fileID];
    assert([[NSFileManager defaultManager] fileExistsAtPath: [fileURL path]]);
    
    NSError *error = nil;
    BOOL success = [fileURL setResourceValue: [NSNumber numberWithBool: YES] forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [fileURL lastPathComponent], error);
    }
}

+ (void)removeNoiCloudBackupAttributeFromZimFilesInAppSupportDirWithZimFileID:(NSString *)fileID {
    NSURL *fileURL = [zimFileFinder zimFileURLInAppSupportDirectoryFormFileID:fileID];
    assert([[NSFileManager defaultManager] fileExistsAtPath: [fileURL path]]);
    
    NSError *error = nil;
    BOOL success = [fileURL setResourceValue: [NSNumber numberWithBool: NO] forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [fileURL lastPathComponent], error);
    }
}

@end
