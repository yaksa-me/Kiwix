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

@end
