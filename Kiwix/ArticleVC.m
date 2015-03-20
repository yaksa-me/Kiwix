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
#import "zimReader.h"
#import "SlideNavigationController.h"
#import "CustomBarButtonItem.h"
#import "MessageView.h"
#import <QuartzCore/QuartzCore.h>

#define ARTICLE_TITLE @"articleTitle"
#define ARTICLE_RELATIVE_URL @"articleRelativeURL"

@interface ArticleVC ()

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) Book *openingBook;
@property (strong, nonatomic) zimReader *reader;
@property (strong, nonatomic) NSMutableArray *filteredArticleArray;


@property CGFloat previousScrollViewYOffset;
@property BOOL isShowingToolMenu;
@property (strong, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;

@property (strong, nonatomic) ToolMenuView *toolMenu;
@property (strong, nonatomic) MessageView *messageView;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) CustomBarButtonItem *bookmarkButtonItem;

- (IBAction)testButton:(UIBarButtonItem *)sender;
- (IBAction)webViewNavigation:(UIBarButtonItem *)sender;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

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
    
    if (self.openingBook) {
        self.reader = [[zimReader alloc] initWithZIMFileURL:[zimFileFinder zimFileURLInLibraryDirectoryFormFileID:self.openingBook.idString]];
    }
    
    if (self.openingBook) {
        if (self.article) {
            //If told which article to open, i.e. segued from history.
            [self loadCurrentArticleIntoBrowser];
        } else {
            //Do not know which article to open yet, try find last read article, if no last read load main page
            self.article = [CoreDataTask lastReadArticleFromBook:self.openingBook inManagedObjectContext:self.managedObjectContext];
            [self loadCurrentArticleIntoBrowser];
        }
    }
    
    //If not opening book display message
    if (!self.openingBook) {
        [self.webView removeFromSuperview];
        UIView *messageView =[self noBookMessageLabel];
        [self.view addSubview:messageView];
        messageView.center = self.view.center;
    }
    
    self.webView.delegate = self;
    self.searchBar.delegate = self;
    self.searchBar.layer.borderWidth = 10;
    self.searchDisplayController.delegate = self;
    self.searchDisplayController.displaysSearchBarInNavigationBar = YES;
    [self.searchDisplayController.navigationItem setLeftBarButtonItem:[[SlideNavigationController sharedInstance] barButtonItemForMenu:MenuLeft]];
    self.isShowingToolMenu = NO;
    
    /*
    for (UIView *subView in self.searchBar.subviews)
    {
        for (UIView *secondLevelSubview in subView.subviews){
            if ([secondLevelSubview isKindOfClass:[UITextField class]])
            {
                UITextField *searchBarTextField = (UITextField *)secondLevelSubview;
                [searchBarTextField setBorderStyle:UITextBorderStyleRoundedRect];
                
                break;
            }
        }
    }*/
    
    ((UIBarButtonItem *)[self.toolbarItems objectAtIndex:0]).tintColor = [UIColor grayColor];
    ((UIBarButtonItem *)[self.toolbarItems objectAtIndex:1]).tintColor = [UIColor grayColor];
    [self initializeBookmarkButton];
    [self changeToolBarItemsOperatingStatus];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.toolbarHidden = NO;
    self.navigationController.toolbar.translucent = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.article.lastReadDate = [NSDate date];
    self.article.lastPosition = [NSNumber numberWithFloat:self.webView.scrollView.contentOffset.y];
    self.navigationController.toolbarHidden = YES;
}

- (void)loadCurrentArticleIntoBrowser {
    NSString *articleURLInZimFile = [[NSString alloc] init];
    if (self.article) {
        articleURLInZimFile = self.article.relativeURL;
    } else {
        articleURLInZimFile = @"(main)";
    }
    
    NSURL *url = [NSURL kiwixURLWithZIMFileIDString:self.openingBook.idString articleURL:articleURLInZimFile];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    
    [self changeToolBarItemsOperatingStatus];
}

- (UIView *)noBookMessageLabel {
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    messageLabel.text = @"Please open a book or import a book using iTunes";
    messageLabel.textColor = [UIColor blackColor];
    messageLabel.numberOfLines = 0;
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    [messageLabel sizeToFit];
    return messageLabel;
}

- (void)initializeBookmarkButton {
    NSMutableArray *toolBarItems = [self.toolbarItems mutableCopy];
    [toolBarItems removeObjectAtIndex:3];
    self.bookmarkButtonItem = [[CustomBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bookmark"]
                                                            highlightedImage:[UIImage imageNamed:@"bookmark_highlighted"]
                                                             andCurrentState:[self.article.isBookmarked boolValue]];
    [self.bookmarkButtonItem.button addTarget:self action:@selector(changeBookmarkStatus) forControlEvents:UIControlEventTouchUpInside];
    [toolBarItems insertObject:self.bookmarkButtonItem atIndex:3];
    self.toolbarItems = toolBarItems;
}

- (void)changeToolBarItemsOperatingStatus {
}

- (void)changeBookmarkStatus {
    self.article.isBookmarked = [NSNumber numberWithBool:![self.article.isBookmarked boolValue]];
    [self.bookmarkButtonItem animateWithHighLightState:[self.article.isBookmarked boolValue]];
}

#pragma mark - UIWebView Delegate
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    UIBarButtonItem *itemBack = [self.toolbarItems objectAtIndex:0];
    UIBarButtonItem *itemForward = [self.toolbarItems objectAtIndex:1];
    
    if (webView.canGoBack) {
        itemBack.tintColor = [[[[UIApplication sharedApplication] delegate] window] tintColor];
    } else {
        itemBack.tintColor = [UIColor grayColor];
    }
    
    if (webView.canGoForward) {
        itemForward.tintColor = [[[[UIApplication sharedApplication] delegate] window] tintColor];
    } else {
        itemForward.tintColor = [UIColor grayColor];
    }
    
    // If a page is not main article and is a "Kiwix://" page, create/update Article obj in Coredata
    NSString *articleTitle = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    if (![articleTitle isEqualToString:@"Main Page"] && [[webView.request.URL scheme] isEqualToString:@"kiwix"]) {
        NSMutableDictionary *articleInfo = [[NSMutableDictionary alloc] init];
        [articleInfo setObject:articleTitle forKey:ARTICLE_TITLE];
        [articleInfo setObject:[self.reader pageURLFromTitle:articleTitle] forKey:ARTICLE_RELATIVE_URL];
        self.article = [Article articleWithTitleInfo:articleInfo andBook:self.openingBook inManagedObjectContext:self.managedObjectContext];
        self.article.lastReadDate = [NSDate date];
        
        if (self.article.lastPosition) {
            CGFloat lastReadPosition = [self.article.lastPosition floatValue];
            [self.webView.scrollView setContentOffset:CGPointMake(0, lastReadPosition) animated:YES];
        } else {
            self.article.lastPosition = [NSNumber numberWithFloat:webView.scrollView.contentOffset.y];
        }
        
        if ([self.article.isBookmarked boolValue] != self.bookmarkButtonItem.isHightlighted) {
            [self.bookmarkButtonItem animateWithHighLightState:[self.article.isBookmarked boolValue]];
        }
        
        // Message View
        if ([self.article.lastPosition floatValue] >= 0) {
            [self displayMessageViewWithMessage:self.article.title];
        }
        /*
        [self.webView setBackgroundColor:[UIColor greenColor]];
        [self.webView setOpaque:NO];
        
        NSString *javaScriptString = @"document.body.style.background = '#000000';";
        NSString *result = [self.webView stringByEvaluatingJavaScriptFromString:javaScriptString];
        NSString *html = [NSString stringWithContentsOfURL:[[self.webView request] URL] encoding:NSUTF8StringEncoding error:nil];
        */
        
        
        
        NSLog(@"Load finish: %@", articleTitle);
    } else {
        self.article = nil;
    }
    [self changeBookmarkStatus];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    // Set the last read history before the web view start load new content
    if ([[[request URL] pathExtension] caseInsensitiveCompare:@"html"] == NSOrderedSame) {
        self.article.lastReadDate = [NSDate date];
        //self.article.lastPosition = [NSNumber numberWithFloat:webView.scrollView.contentOffset.y];
    }

    return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"%@", [error description]);
}

#pragma mark - Slide Menu Delegation
- (BOOL)slideNavigationControllerShouldDisplayLeftMenu {
    return YES;
}
/*
#pragma mark - Scroll View Delegate 
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGRect frame = self.navigationController.navigationBar.frame;
    CGFloat size = frame.size.height - 21;
    CGFloat framePercentageHidden = ((20 - frame.origin.y) / (frame.size.height - 1));
    CGFloat scrollOffset = scrollView.contentOffset.y;
    CGFloat scrollDiff = scrollOffset - self.previousScrollViewYOffset;
    CGFloat scrollHeight = scrollView.frame.size.height;
    CGFloat scrollContentSizeHeight = scrollView.contentSize.height + scrollView.contentInset.bottom;
    
    if (scrollOffset <= -scrollView.contentInset.top) {
        frame.origin.y = 20;
    } else if ((scrollOffset + scrollHeight) >= scrollContentSizeHeight) {
        frame.origin.y = -size;
    } else {
        frame.origin.y = MIN(20, MAX(-size, frame.origin.y - scrollDiff));
    }
    
    [self.navigationController.navigationBar setFrame:frame];
    //[self updateBarButtonItems:(1 - framePercentageHidden)];
    self.previousScrollViewYOffset = scrollOffset;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
*/

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.openingBook) {
        //Has a opening Book
        if (tableView == self.searchDisplayController.searchResultsTableView) {
            return 1;
        } else {
            return 0;
        }
    } else {
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.openingBook) {
        //Has a opening Book
        if (tableView == self.searchDisplayController.searchResultsTableView) {
            return [self.filteredArticleArray count];
        } else {
            return 0;
        }
    } else {
        //No book is opening
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.searchDisplayController.searchResultsTableView dequeueReusableCellWithIdentifier:@"SearchArticleCell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SearchArticleCell"];
    }
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        cell.textLabel.text = [self.filteredArticleArray objectAtIndex:indexPath.row];
    }
    
    return cell;
}

#pragma mark - Table View Delagate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
        NSString *articleTitle = selectedCell.textLabel.text;
        
        //Create an article if article doesn't exist, regradless of whether it is main page or not
        NSMutableDictionary *articleInfo = [[NSMutableDictionary alloc] init];
        [articleInfo setObject:articleTitle forKey:ARTICLE_TITLE];
        [articleInfo setObject:[self.reader pageURLFromTitle:articleTitle] forKey:ARTICLE_RELATIVE_URL];
        self.article = [Article articleWithTitleInfo:articleInfo andBook:self.openingBook inManagedObjectContext:self.managedObjectContext];
        [self loadCurrentArticleIntoBrowser];
        [self.searchBar setShowsCancelButton:NO animated:YES];
        [self.searchDisplayController setActive:NO animated:YES];
    }
}

#pragma mark - Search Helper
- (void)filterContentForSearchText:(NSString*)searchText{
    [self.filteredArticleArray removeAllObjects];
    if (self.openingBook) {
        NSArray *filteredArticles = [self.reader searchSuggestionsSmart:searchText];
        self.filteredArticleArray = [NSMutableArray arrayWithArray:filteredArticles];
        NSLog(@"Search text:%@, %lu items found in zimfile", searchText, (unsigned long)[self.filteredArticleArray count]);
    }
}

#pragma mark - UISearchBar delegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self hideToolMenu];
    self.navigationItem.leftBarButtonItem = nil;
    [searchBar setShowsCancelButton:YES animated:YES];
    [self.navigationController setToolbarHidden:YES animated:YES];
}


- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.navigationItem.leftBarButtonItem = [[SlideNavigationController sharedInstance] barButtonItemForMenu:MenuLeft];
    [searchBar setShowsCancelButton:NO animated:YES];
}

#pragma mark - UISearchDisplayController Delegate Methods
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self filterContentForSearchText:searchString];
    return YES;
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    self.navigationItem.leftBarButtonItem = [[SlideNavigationController sharedInstance] barButtonItemForMenu:MenuLeft];
    [controller.searchBar setShowsCancelButton:NO animated:YES];
    [self.navigationController setToolbarHidden:NO animated:YES];
}

#pragma mark - UIAnimation
- (void)showToolMenu {
    if (!self.toolMenu) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ToolMenuView" owner:self options:nil];
        self.toolMenu = [nib objectAtIndex:0];
        self.toolMenu.delegate = self;
    }
    
    CGFloat frameX = self.navigationController.toolbar.frame.size.width - 20 - self.toolMenu.frame.size.width;
    CGFloat frameY = self.navigationController.toolbar.frame.origin.y - 20 - self.toolMenu.frame.size.height;
    self.toolMenu.frame = CGRectMake(frameX, frameY, self.toolMenu.frame.size.width, self.toolMenu.frame.size.height);
    self.toolMenu.alpha = 0.0;
    [self.view addSubview:self.toolMenu];
    
    [UIView animateWithDuration:0.05 animations:^{
        self.toolMenu.alpha = 1.0;
    } completion:^(BOOL finished) {
        self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideToolMenu)];
        self.tapGestureRecognizer.delegate = self.toolMenu;
        
        self.webView.userInteractionEnabled = NO;
        [self.view addGestureRecognizer:self.tapGestureRecognizer];
        
    }];
    
    self.isShowingToolMenu = YES;
}

- (void)hideToolMenu {
    [UIView animateWithDuration:.25 animations:^{
        //self.toolMenu.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self.toolMenu removeFromSuperview];
            [self.view removeGestureRecognizer:self.tapGestureRecognizer];
            self.webView.userInteractionEnabled = YES;
        }
    }];
    self.isShowingToolMenu = NO;
}

- (void)displayMessageViewWithMessage:(NSString *)message {
    if (!self.messageView) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MessageView" owner:self options:nil];
        self.messageView = [nib objectAtIndex:0];
    }
    
    CGFloat frameX = 0;
    CGFloat frameY = self.navigationController.navigationBar.frame.size.height + self.navigationController.navigationBar.frame.origin.y;
    self.messageView.frame = CGRectMake(frameX, frameY, self.navigationController.navigationBar.frame.size.width, self.messageView.frame.size.height);
    self.messageView.alpha = 0.0;
    self.messageView.messageLabel.text = message;
    [self.view addSubview:self.messageView];
    
    [UIView animateWithDuration:0.05 animations:^{
        self.messageView.alpha = 0.8;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 delay:1.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.messageView.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self.messageView removeFromSuperview];
        }];
    }];
}

#pragma mark - ToolMenuControl Delegate
- (void)fontSizeAdjustIncrease:(BOOL)isIncreasing {
    if (isIncreasing) {
        textFontSize = (textFontSize < 120) ? textFontSize +20 : textFontSize;
    } else {
        textFontSize = (textFontSize > 80) ? textFontSize -20 : textFontSize;
    }
    NSString *jsString = [[NSString alloc] initWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '%lu%%'", (unsigned long)textFontSize];
    [self.webView stringByEvaluatingJavaScriptFromString:jsString];
}

- (void)readingModeChange:(NSUInteger)mode {
    [self.view setBackgroundColor:[UIColor blackColor]];
    NSString *setJavaScript = [[NSString alloc] initWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextFillColor= 'white'; document.getElementsByTagName('body')[0].style = 'background:  red'; DOMReady();"];
    [self.webView setOpaque:NO];
    [self.webView stringByEvaluatingJavaScriptFromString:setJavaScript];
    [self.webView.scrollView setBackgroundColor:[UIColor blackColor]];
}


#pragma mark - Target Actions
- (IBAction)testButton:(UIBarButtonItem *)sender {
    if (self.isShowingToolMenu) {
        [self hideToolMenu];
    } else {
        // Show menu
        [self showToolMenu];
    }
}

- (IBAction)webViewNavigation:(UIBarButtonItem *)sender {
    switch ([sender tag]) {
        case 0: //Back
            [self.webView goBack];
            break;
        case 1: //Forward
            [self.webView goForward];
            break;
    }
}

- (IBAction)test:(UIBarButtonItem *)sender {
    [self.webView stringByEvaluatingJavaScriptFromString:@"var myNode = document.getElementsByTagName('table')[0];"
     "myNode.parentNode.removeChild(myNode);"];
}
@end
