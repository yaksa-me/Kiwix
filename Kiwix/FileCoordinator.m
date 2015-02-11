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

#define ARTICLE_COUNT @"articleCount"
#define MEDIA_COUNT @"mediaCount"
#define GLOBAL_COUNT @"globalCount"

#define ID_STRING @"idString"
#define TITLE @"title"
#define DESCRIPTION @"desc"
#define LANGUAGE @"language"
#define DATE @"date"
#define CREATOR @"creator"
#define PUBLISHER @"publisher"
#define ORIGIN_ID @"originID"
#define FILE_SIZE @"fileSize"
#define FAVICON @"favicon"

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

+ (NSString *)inboxDirPath {
    NSString *docDirPath = [self docDirPath];
    NSString *inboxDirPath = [docDirPath stringByAppendingPathComponent:@"Inbox"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:inboxDirPath]) {
        [fileManager createDirectoryAtPath:inboxDirPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return inboxDirPath;
}

#pragma mark - File Position & Coredata
+ (void)processFilesWithManagedObjectContext:(NSManagedObjectContext *)context {
    [self moveZimFileFromDocumentDirectoryToLibraryDirectory];
    [self addAllFilesInLibraryDirToDatabaseInManagedObjectContext:context];
    [self renameZimFilesInLibDir];
    
    if ([Preference isBackingUpFilesToiCloud]) {
        [self removeNoiCloudBackupAttributeFromAllZimFilesInLibraryDir];
    } else {
        [self addNoiCloudBackupAttributeToAllZimFilesInLibraryDir];
    }
}

+ (void)moveZimFileFromDocumentDirectoryToLibraryDirectory {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    /*
    //Create App Support Dir if not exist
    if (![fileManager fileExistsAtPath:[self libDirPath]]) {
        [fileManager createDirectoryAtPath:[self libDirPath] withIntermediateDirectories:YES attributes:nil error:nil];
    }*/
    
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
    
    NSArray *allFileListInInboxDir = [fileManager contentsOfDirectoryAtPath:[self inboxDirPath] error:nil];
    for (NSString *fileName in allFileListInInboxDir) { //fileName has extention
        NSString *extention = [[[fileName componentsSeparatedByString:@"."] lastObject] lowercaseString];
        if ([extention isEqualToString:@"zim"]) {
            NSString *filePathInInboxDir = [[[self inboxDirPath] stringByAppendingString:@"/"] stringByAppendingString:fileName];
            NSString *filePathInLibDir = [[[self libDirPath] stringByAppendingString:@"/"] stringByAppendingString:fileName];
            NSError *error;
            [fileManager moveItemAtPath:filePathInInboxDir toPath:filePathInLibDir error:&error];
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
            
            [infoDictionary setObject:fileName forKey:@"fileName"];
            
            [infoDictionary setObject:[NSNumber numberWithUnsignedInteger:[reader getArticleCount]] forKey:ARTICLE_COUNT];
            [infoDictionary setObject:[NSNumber numberWithUnsignedInteger:[reader getMediaCount]] forKey:MEDIA_COUNT];
            [infoDictionary setObject:[NSNumber numberWithUnsignedInteger:[reader getGlobalCount]] forKey:GLOBAL_COUNT];
            
            [infoDictionary setObject:[reader getID] forKey:ID_STRING];
            [infoDictionary setObject:[reader getTitle] forKey:TITLE];
            [infoDictionary setObject:[reader getDesc] forKey:DESCRIPTION];
            [infoDictionary setObject:[reader getLanguage] forKey:LANGUAGE];
            [infoDictionary setObject:[reader getDate] forKey:DATE];
            [infoDictionary setObject:[reader getCreator] forKey:CREATOR];
            [infoDictionary setObject:[reader getPublisher] forKey:PUBLISHER];
            [infoDictionary setObject:[reader getOriginID] forKey:ORIGIN_ID];
            [infoDictionary setObject:[NSNumber numberWithUnsignedInteger:[reader getFileSize]] forKey:FILE_SIZE];
            [infoDictionary setObject:[reader getFavicon] forKey:FAVICON];
            
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
+ (void)addNoiCloudBackupAttributeToAllZimFilesInLibraryDir {
    NSArray *fileIDArray = [zimFileFinder zimFileIDsInLibraryDirectory];
    for (NSString *fileID in fileIDArray) {
        [self addNoiCloudBackupAttributeToZimFilesInLibraryDirWithZimFileID:fileID];
    }
}

+ (void)removeNoiCloudBackupAttributeFromAllZimFilesInLibraryDir {
    NSArray *fileIDArray = [zimFileFinder zimFileIDsInLibraryDirectory];
    for (NSString *fileID in fileIDArray) {
        [self removeNoiCloudBackupAttributeFromZimFilesInLibraryDirWithZimFileID:fileID];
    }
}

+ (void)addNoiCloudBackupAttributeToZimFilesInLibraryDirWithZimFileID:(NSString *)fileID {
    NSURL *fileURL = [zimFileFinder zimFileURLInLibraryDirectoryFormFileID:fileID];
    assert([[NSFileManager defaultManager] fileExistsAtPath: [fileURL path]]);
    
    NSError *error = nil;
    BOOL success = [fileURL setResourceValue: [NSNumber numberWithBool: YES] forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [fileURL lastPathComponent], error);
    }
}

+ (void)removeNoiCloudBackupAttributeFromZimFilesInLibraryDirWithZimFileID:(NSString *)fileID {
    NSURL *fileURL = [zimFileFinder zimFileURLInLibraryDirectoryFormFileID:fileID];
    assert([[NSFileManager defaultManager] fileExistsAtPath: [fileURL path]]);
    
    NSError *error = nil;
    BOOL success = [fileURL setResourceValue: [NSNumber numberWithBool: NO] forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [fileURL lastPathComponent], error);
    }
}

@end
