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

@interface ArticleVC ()

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) Book *openingBook;
@property (strong, nonatomic) NSMutableArray *filteredArticleArray;
@property (strong, nonatomic) zimReader *reader;
@property CGFloat previousScrollViewYOffset;
@property BOOL isShowingToolMenu;

@property (strong, nonatomic) UIView *popupView;
@property (strong, nonatomic) UIView *loadingView;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
- (IBAction)changeFontSize:(UIBarButtonItem *)sender;
- (IBAction)test:(UIBarButtonItem *)sender;
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
    
    self.webView.delegate = self;
    self.navigationController.toolbarHidden = NO;
    self.navigationController.toolbar.translucent = NO;
    self.isShowingToolMenu = NO;
    
    self.searchDisplayController.displaysSearchBarInNavigationBar = YES;
    
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
    }
    
    self.searchBar.delegate = self;
    self.searchDisplayController.delegate = self;
    
    ((UIBarButtonItem *)[self.toolbarItems objectAtIndex:0]).tintColor = [UIColor grayColor];
    ((UIBarButtonItem *)[self.toolbarItems objectAtIndex:1]).tintColor = [UIColor grayColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.toolbarHidden = NO;
    self.navigationController.toolbar.translucent = NO;
}

- (void)loadCurrentArticleIntoBrowser {
    NSString *articleURLInZimFile;
    if (self.article) {
        articleURLInZimFile = [self.reader pageURLFromTitle:self.article.title];
    } else {
        articleURLInZimFile = @"(main)";
    }
    
    NSURL *url = [NSURL kiwixURLWithZIMFileIDString:self.openingBook.idString articleURL:articleURLInZimFile];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.article.lastReadDate = [NSDate date];
    self.article.lastPosition = [NSNumber numberWithFloat:self.webView.scrollView.contentOffset.y];
    self.navigationController.toolbarHidden = YES;
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
        self.article = [Article articleWithTitle:articleTitle andBook:self.openingBook inManagedObjectContext:self.managedObjectContext];
        
        if (self.article.lastPosition) {
            CGFloat lastReadPosition = [self.article.lastPosition floatValue];
            [self.webView.scrollView setContentOffset:CGPointMake(0, lastReadPosition) animated:NO];
        } else {
            self.article.lastPosition = [NSNumber numberWithFloat:webView.scrollView.contentOffset.y];
        }
        //NSLog(@"%@", [NSNumber numberWithFloat:webView.scrollView.contentOffset.y]);
        
        NSLog(@"Load finish: %@", articleTitle);
    } else {
        self.article = nil;
    }
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    // Set the last read history before the web view start load new content
    if ([[[request URL] pathExtension] caseInsensitiveCompare:@"html"] == NSOrderedSame) {
        self.article.lastReadDate = [NSDate date];
        self.article.lastPosition = [NSNumber numberWithFloat:webView.scrollView.contentOffset.y];
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
        NSString *articleTitle = selectedCell.textLabel.text;;
        self.article = [Article articleWithTitle:articleTitle andBook:self.openingBook inManagedObjectContext:self.managedObjectContext];
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
    [searchBar setShowsCancelButton:YES animated:YES];
    [self.navigationItem setHidesBackButton:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
    [self.navigationItem setHidesBackButton:NO];
}

#pragma mark - UISearchDisplayController Delegate Methods
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self filterContentForSearchText:searchString];
    return YES;
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    [controller.searchBar setShowsCancelButton:NO animated:YES];
}

#pragma mark - UIAnimations



#pragma mark - Target Actions
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

- (IBAction)testButton:(UIBarButtonItem *)sender {
    if (self.isShowingToolMenu) {
        [UIView animateWithDuration:.25 animations:^{
            self.popupView.alpha = 0.0;
        } completion:^(BOOL finished) {
            if (finished) {
                [self.popupView removeFromSuperview];
            }
        }];
        self.isShowingToolMenu = NO;
    } else {
        // Show menu
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ToolMenuView" owner:self options:nil];
        self.popupView = [nib objectAtIndex:0];
        self.popupView.
        self.popupView.frame = CGRectMake(20, 340, 280, 170);
        self.popupView.alpha = 0.0;
        [self.view addSubview:self.popupView];
        
        [UIView animateWithDuration:0.05 animations:^{
            self.popupView.alpha = 1.0;
        } completion:^(BOOL finished) {
            
        }];
        
        self.isShowingToolMenu = YES;
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
