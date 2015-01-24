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
#import "NSURL+KiwixURLProtocol.h"
#import "AppDelegate.h"

@interface ArticleVC ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;
- (IBAction)changeFontSize:(UIBarButtonItem *)sender;
- (IBAction)test:(UIBarButtonItem *)sender;
@property (strong, nonatomic) Article *article;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

@implementation ArticleVC
NSUInteger textFontSize = 100;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.managedObjectContext = ((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;
    
    //BookID setter should before the next if section
    if (!self.bookID) {
        self.bookID = [Preference openingBookID];
    }
    
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
    self.navigationController.toolbarHidden = NO;
    self.navigationController.toolbar.translucent = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initializeZimReader {
    /*
    NSString *zimFilePath = [zimFileFinder zimFilePathInAppSupportDirectoryFormFileID:self.bookID];
    zimReader *reader = [[zimReader alloc] initWithZIMFileURL:[NSURL fileURLWithPath:zimFilePath]];
    NSString *htmlString = [reader htmlContentOfPageWithPagetitle:self.articleTitle];*/
    
    NSURL *url = [NSURL kiwixURLWithZIMFileIDString:self.bookID articleTitle:self.articleTitle];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.article.lastReadDate = [NSDate date];
    self.navigationController.toolbarHidden = YES;
    //NSLog(@"Reading Article: %@", [self.article.title description]);
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

- (IBAction)changeFontSize:(UIBarButtonItem *)sender {
    switch ([sender tag]) {
        case 1: // A-
            textFontSize = (textFontSize > 50) ? textFontSize -5 : textFontSize;
            break;
        case 2: // A+
            textFontSize = (textFontSize < 160) ? textFontSize +5 : textFontSize;
            break;
    }
    
    NSString *jsString = [[NSString alloc] initWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '%d%%'", textFontSize];
    [self.webView stringByEvaluatingJavaScriptFromString:jsString];
}

- (IBAction)test:(UIBarButtonItem *)sender {
    [self.webView stringByEvaluatingJavaScriptFromString:@"var myNode = document.getElementsByTagName('table')[0];"
     "myNode.parentNode.removeChild(myNode);"];
}
@end
