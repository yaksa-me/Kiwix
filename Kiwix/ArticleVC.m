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

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
- (IBAction)changeFontSize:(UIBarButtonItem *)sender;
- (IBAction)test:(UIBarButtonItem *)sender;
@property (strong, nonatomic) Book *openingBook;
@property (strong, nonatomic) Article *article;

@end

@implementation ArticleVC
NSUInteger textFontSize = 100;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.managedObjectContext = ((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;
    
    /* v1.1+ code
    //BookID setter should before the next if section
    if (!self.bookID) {
        Book *book = [[CoreDataTask openingBooksInManagedObjectContext:self.managedObjectContext] firstObject];
        self.bookID = book.idString;
    }*/
    
    self.openingBook = [[CoreDataTask openingBooksInManagedObjectContext:self.managedObjectContext] firstObject]; // Currently only one book should be open (v1.0)
    
    if (self.articleTitle) {
        //If told which article to open, i.e. segued from search.
        self.article = [Article articleWithTitle:self.articleTitle andBook:self.openingBook inManagedObjectContext:self.managedObjectContext];
        [self initializeZimReader];
    } else {
        if (self.openingBook) {
            //If not told which article to open AND there is an opening book, see if there is a last read article from the opening book
            self.article = [CoreDataTask lastReadArticleFromBook:self.openingBook inManagedObjectContext:self.managedObjectContext];
            if (self.article) {
                // There is a last read article
                self.articleTitle = self.article.title;
                [self initializeZimReader];
            } else {
                // There is not a last read article
            }
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
    NSURL *url = [NSURL kiwixURLWithZIMFileIDString:self.openingBook.idString articleTitle:self.articleTitle];
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
