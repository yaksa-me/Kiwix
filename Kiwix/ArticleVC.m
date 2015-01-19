//
//  ArticleVC.m
//  Kiwix
//
//  Created by Chris Li on 1/11/15.
//  Copyright (c) 2015 Chris Li. All rights reserved.
//

#import "ArticleVC.h"
#import "Preference.h"
#import "zimFileFinder.h"
#import "CoreDataTask.h"
#import "Book.h"
#import "Article+Create.h"
#import "AppDelegate.h"

@interface ArticleVC ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) Article *article;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

@implementation ArticleVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.managedObjectContext = ((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;
    
    if (self.articleTitle) {
        //If told which article to open, i.e. segued from search.
        [Preference setLastReadArticleInfoWithBookIDString:[Preference openingBookID] andArticleTitle:self.articleTitle];
        Book *book = [CoreDataTask bookWithIDString:[Preference openingBookID] inManagedObjectContext:self.managedObjectContext];
        self.article = [Article articleWithTitle:self.articleTitle andBook:book inManagedObjectContext:self.managedObjectContext];
        [self initializeZimReader];
    } else {
        if ([Preference hasOpeningBook]) {
            //If not told which article to open AND there is an opening book, open the last read article
            self.articleTitle = [Preference lastReadArticleTitle];
            [self initializeZimReader];
        } else {
            //If not told which article to open AND there is not an opening book, display message
        }
    }
    
    self.title = self.articleTitle;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initializeZimReader {
    NSString *zimFilePath = [zimFileFinder zimFilePathInAppSupportDirectoryFormFileID:[Preference openingBookID]];
    zimReader *reader = [[zimReader alloc] initWithZIMFileURL:[NSURL fileURLWithPath:zimFilePath]];
    NSString *htmlString = [reader htmlContentOfPageWithPagetitle:self.articleTitle];
    
    [self.webView loadHTMLString:htmlString baseURL:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.article.lastReadDate = [NSDate date];
    NSLog(@"%@", [self.article.title description]);
}


#pragma mark - Slide Menu Delegation
- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    if ([Preference currentMenuIndex] == 1) {
        return YES;
    } else {
        return NO;
    }
}

@end
