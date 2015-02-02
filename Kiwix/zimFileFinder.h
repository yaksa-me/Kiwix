//
//  zimFilePathFinder.h
//  Kiwix
//
//  Created by Chris Li on 1/14/15.
//  Copyright (c) 2015 Chris Li. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface zimFileFinder : NSObject

//+ (NSArray *)zimFileIDsInAppSupportDirectory;
//+ (NSString *)zimFilePathInAppSupportDirectoryFormFileID:(NSString *)fileID;
//+ (NSURL *)zimFileURLInAppSupportDirectoryFormFileID:(NSString *)fileID;

+ (NSArray *)zimFileIDsInLibraryDirectory;
+ (NSURL *)zimFileURLInLibraryDirectoryFormFileID:(NSString *)fileID;
+ (BOOL)zimFileExistInLibraryDirectoryWithFileID:(NSString *)fileID;

@end
