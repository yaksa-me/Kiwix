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

@interface FileCoordinator ()

@property (strong, nonatomic)NSArray *filePaths;

@end

@implementation FileCoordinator

- (id)init {
    self = [super init];
    self.filePaths = [zimFileFinder zimFilePathsInDocumentDirectory];
    return self;
}

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    self = [self init];
    self.managedObjectContext = managedObjectContext;
    return self;
}

- (void)processAllBooks {
    for (NSString *filePath in self.filePaths) {
        NSURL *fileURL = [NSURL fileURLWithPath:filePath];
        zimReader *reader = [[zimReader alloc] initWithZIMFileURL:fileURL];
        NSString *idString = [reader getID];
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Book"];
        request.predicate = [NSPredicate predicateWithFormat:@"idString = %@", idString];
        
        NSError *error;
        NSArray *matches = [self.managedObjectContext executeFetchRequest:request error:&error];
        
        if (!matches || error || ([matches count] > 1)) {
            
        } else if ([matches count]) {
            //book exist, and only one exist
            //NSLog(@"Book exists and only one exists");
        } else {
            //book not exist
            NSMutableDictionary *infoDictionary = [[NSMutableDictionary alloc] init];
            [infoDictionary setValue:idString forKey:@"idString"];
            [infoDictionary setValue:[reader getTitle] forKey:@"title"];
            [infoDictionary setValue:[zimFileFinder zimFileNameFromZimFilePath:filePath] forKey:@"fileName"];
            
            NSArray *articleList = [Parser tableOfContentFromTOCHTMLString:[reader htmlContentOfMainPage]];
            
            [Book bookWithReaderInfo:infoDictionary inManagedObjectContext:self.managedObjectContext];
            
            for (NSString *articleTitle in articleList) {
                [Article insertArticleWithTitle:articleTitle andBookIDString:idString inManagedObjectContext:self.managedObjectContext];
            }
        }
    }
}

#pragma marks - Paths
+ (NSString *)docDirPath {
    NSArray *docPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirPath = ([docPaths count] > 0) ? [docPaths objectAtIndex:0] : nil;
    return documentDirPath;
}

+ (NSString *)appSupportDirPath {
    NSArray *appSupportPaths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *appSupportDirPath = ([appSupportPaths count] > 0) ? [appSupportPaths objectAtIndex:0] : nil;
    return appSupportDirPath;
}
+ (void)moveZimFileFromDocumentDirectoryToApplicationSupport {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //Create App Support Dir if not exist
    if (![fileManager fileExistsAtPath:[self appSupportDirPath]]) {
        [fileManager createDirectoryAtPath:[self appSupportDirPath] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    //Helper
    NSArray *allFileListInDocDir = [fileManager contentsOfDirectoryAtPath:[self docDirPath] error:nil];
    NSLog(@"%@", [allFileListInDocDir description]);
    
    //Move all zim file in Doc dir to App Support Dir
    for (NSString *fileName in allFileListInDocDir) {
        NSString *extention = [[[fileName componentsSeparatedByString:@"."] lastObject] lowercaseString];
        if ([extention isEqualToString:@"zim"]) {
            NSString *filePathInDocDir = [[[self docDirPath] stringByAppendingString:@"/"] stringByAppendingString:fileName];
            zimReader *reader = [[zimReader alloc] initWithZIMFileURL:[NSURL fileURLWithPath:filePathInDocDir]];
            NSString *idString = [reader getID];
            NSString *filePathInAppSupportDir = [[[[self appSupportDirPath] stringByAppendingString:@"/"] stringByAppendingString:idString] stringByAppendingString:@".zim"];
            NSError *error;
            [fileManager moveItemAtPath:filePathInDocDir toPath:filePathInAppSupportDir error:&error];
        }
    }
    
    //Helper
    NSArray *allFileListInAppSupportDir = [fileManager contentsOfDirectoryAtPath:[self appSupportDirPath] error:nil];
    NSLog(@"%@", [allFileListInAppSupportDir description]);
}

+ (void)addAllFilesInApplicationSupportDirToDatabaseInManagedObjectContext:(NSManagedObjectContext *)context {
    NSArray *appSupportPaths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *appSupportDirPath = ([appSupportPaths count] > 0) ? [appSupportPaths objectAtIndex:0] : nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *allFileListInDocDir = [fileManager contentsOfDirectoryAtPath:appSupportDirPath error:nil];
    
    for (NSString *fileName in allFileListInDocDir) {
        NSString *filePathInAppSupportDir = [[appSupportDirPath stringByAppendingString:@"/"] stringByAppendingString:fileName];
        
        zimReader *reader = [[zimReader alloc] initWithZIMFileURL:[NSURL fileURLWithPath:filePathInAppSupportDir]];
        NSMutableDictionary *infoDictionary = [[NSMutableDictionary alloc] init];
        [infoDictionary setValue:[reader getID] forKey:@"idString"];
        [infoDictionary setValue:[reader getTitle] forKey:@"title"];
        
        [Book bookWithReaderInfo:infoDictionary inManagedObjectContext:context];
    }
}

+ (void)deleteBookWithID:(NSString *)idString inManagedObjectContext:(NSManagedObjectContext *)context {
    //Delete in Coredata database
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Book"];
    request.predicate = [NSPredicate predicateWithFormat:@"idString = %@", idString];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || ([matches count] > 1)) {
        
    } else if ([matches count]) {
        //One book exist
        [context deleteObject:[matches firstObject]];
    } else {
        //book not exist
    }
    
    //Delete on disk
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePathInAppSupportDir = [[[[self appSupportDirPath] stringByAppendingString:@"/"] stringByAppendingString:idString] stringByAppendingString:@".zim"];
    [fileManager removeItemAtPath:filePathInAppSupportDir error:nil];
}


@end
