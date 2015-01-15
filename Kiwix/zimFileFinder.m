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
@end
