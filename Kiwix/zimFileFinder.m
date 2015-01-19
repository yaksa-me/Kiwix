//
//  zimFilePathFinder.m
//  Kiwix
//
//  Created by Chris Li on 1/14/15.
//  Copyright (c) 2015 Chris Li. All rights reserved.
//

#import "zimFileFinder.h"

@implementation zimFileFinder

+ (NSArray *)zimFileNamesInDocumentDirectory {
    NSMutableArray *fileListToReturn = [[NSMutableArray alloc] init];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirPath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    NSArray *allFileList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentDirPath error:nil];

    for (NSString *file in allFileList) {
        NSString *extention = [[file componentsSeparatedByString:@"."] lastObject];
        if ([extention isEqualToString:@"zim"]) {
            NSString *fileName = [[file componentsSeparatedByString:@"."] firstObject];
            [fileListToReturn addObject:fileName];
        }
    }
    return fileListToReturn;
}

+ (NSArray *)zimFilePathsInDocumentDirectory {
    NSMutableArray *fileListToReturn = [[NSMutableArray alloc] init];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirPath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    NSArray *allFileList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentDirPath error:nil];
    
    for (NSString *file in allFileList) {
        NSString *extention = [[file componentsSeparatedByString:@"."] lastObject];
        if ([extention isEqualToString:@"zim"]) {
            NSString *filePath = [[documentDirPath stringByAppendingString:@"/"] stringByAppendingString:file];
            [fileListToReturn addObject:filePath];
        }
    }
    return fileListToReturn;
}

+ (NSString *)zimFilePathInDocumentDirectoryFormFileName:(NSString *)fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirPath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    documentDirPath = [documentDirPath stringByAppendingString:@"/"];
    NSString *filepath= [[documentDirPath stringByAppendingString:fileName] stringByAppendingString:@".zim"];
    return filepath;
}

+ (NSURL *)zimFileURLInDocumentDirectoryFormFileName:(NSString *)fileName {
    NSURL *fileURL = [NSURL fileURLWithPath:[self zimFilePathInDocumentDirectoryFormFileName:fileName]];
    return fileURL;
}

+ (NSString *)zimFileNameFromZimFilePath:(NSString *)zimFilePath {
    NSString *fileNameWithExtention = [[zimFilePath componentsSeparatedByString:@"/"] lastObject];
    NSString *fileName = [[fileNameWithExtention componentsSeparatedByString:@"."] firstObject];
    return fileName;
}

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
@end
