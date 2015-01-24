//
//  zimFilePathFinder.h
//  Kiwix
//
//  Created by Chris Li on 1/14/15.
//  Copyright (c) 2015 Chris Li. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface zimFileFinder : NSObject

+ (NSArray *)zimFileNamesInDocumentDirectory; //Names doesn't contain .zim extention
+ (NSArray *)zimFilePathsInDocumentDirectory;
+ (NSString *)zimFilePathInDocumentDirectoryFormFileName:(NSString *)fileName;
+ (NSURL *)zimFileURLInDocumentDirectoryFormFileName:(NSString *)fileName;
+ (NSString *)zimFileNameFromZimFilePath:(NSString *)zimFilePath;

+ (NSArray *)zimFileIDsInAppSupportDirectory;
+ (NSString *)zimFilePathInAppSupportDirectoryFormFileID:(NSString *)fileID;
+ (NSURL *)zimFileURLInAppSupportDirectoryFormFileID:(NSString *)fileID;
@end
