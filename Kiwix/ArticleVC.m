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
#import "Article.h"

@interface ArticleVC ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation ArticleVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.articleTitle;
    
    Book *book = [CoreDataTask bookWithIDString:self.bookIDString inManagedObjectContext:self.managedObjectContext];
    Article *article = [CoreDataTask articleWithTitle:self.articleTitle fromBook:book inManagedObjectContext:self.managedObjectContext];
    article.lastReadDate = [NSDate date];
    
    NSString *fileName = book.fileName;
    zimReader *reader = [[zimReader alloc] initWithZIMFileURL:[zimFileFinder zimFileURLInDocumentDirectoryFormFileName:fileName]];
    NSString *htmlString = [reader htmlContentOfPageWithPagetitle:self.articleTitle];
    
    [Preference setLastReadArticleInfoWithBookIDString:self.bookIDString andArticleTitle:self.articleTitle];
    
    [self.webView loadHTMLString:htmlString baseURL:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Slide Menu Delegation
- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
