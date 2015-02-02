//
//  zimFilePathFinder.m
//  Kiwix
//
//  Created by Chris Li on 1/14/15.
//  Copyright (c) 2015 Chris Li. All rights reserved.
//

#import "zimFileFinder.h"
#import "FileCoordinator.h"

@implementation zimFileFinder

#pragma mark -App Support
+ (NSArray *)zimFileIDsInAppSupportDirectory {
    NSArray *appSupportPaths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *appSupportDirPath = ([appSupportPaths count] > 0) ? [appSupportPaths objectAtIndex:0] : nil;
    NSArray *allFileNamesList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:appSupportDirPath error:nil];
    NSMutableArray *idStringList = [[NSMutableArray alloc] init];
    
    for (NSString *fileName in allFileNamesList) {
        NSString *extention = [[fileName componentsSeparatedByString:@"."] lastObject];
        if ([extention isEqualToString:@"zim"]) {
            NSString *idString = [[fileName componentsSeparatedByString:@"."] firstObject];
            [idStringList addObject:idString];
        }
    }
    return idStringList;
}

+ (NSString *)zimFilePathInAppSupportDirectoryFormFileID:(NSString *)fileID {
    NSArray *appSupportPaths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *appSupportDirPath = ([appSupportPaths count] > 0) ? [appSupportPaths objectAtIndex:0] : nil;
    NSString *filePathInAppSupportDir = [[[appSupportDirPath stringByAppendingString:@"/"] stringByAppendingString:fileID] stringByAppendingString:@".zim"];
    return filePathInAppSupportDir;
}

+ (NSURL *)zimFileURLInAppSupportDirectoryFormFileID:(NSString *)fileID {
    NSString *filePath = [self zimFilePathInAppSupportDirectoryFormFileID:fileID];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    return fileURL;
}


#pragma mark - Library Dir

+ (NSArray *)zimFileIDsInLibraryDirectory {
    NSString *libDirPath = [FileCoordinator libDirPath];
    NSArray *allFileNamesList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:libDirPath error:nil];
    NSMutableArray *idStringList = [[NSMutableArray alloc] init];
    
    for (NSString *fileName in allFileNamesList) {
        NSString *extention = [[fileName componentsSeparatedByString:@"."] lastObject];
        if ([extention isEqualToString:@"zim"]) {
            NSString *idString = [[fileName componentsSeparatedByString:@"."] firstObject];
            [idStringList addObject:idString];
        }
    }
    return idStringList;
}

+ (NSString *)zimFilePathInLibraryDirectoryFormFileID:(NSString *)fileID {
    NSString *libDirPath = [FileCoordinator libDirPath];
    return [[[libDirPath stringByAppendingString:@"/"] stringByAppendingString:fileID] stringByAppendingString:@".zim"];
}

+ (NSURL *)zimFileURLInLibraryDirectoryFormFileID:(NSString *)fileID {
    NSString *filePathInLibDir = [self zimFilePathInLibraryDirectoryFormFileID:fileID];
    NSURL *fileURL = [NSURL fileURLWithPath:filePathInLibDir];
    return fileURL;
}

+ (BOOL)zimFileExistInLibraryDirectoryWithFileID:(NSString *)fileID {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [self zimFilePathInLibraryDirectoryFormFileID:fileID];
    return [fileManager fileExistsAtPath:filePath];
}

@end
