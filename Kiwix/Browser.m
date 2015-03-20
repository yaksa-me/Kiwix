//
//  Browser.m
//  Kiwix
//
//  Created by Chris Li on 3/4/15.
//  Copyright (c) 2015 Chris Li. All rights reserved.
//

#import "Browser.h"
#import "AppDelegate.h"
#import "zimReader.h"
#import "CoreDataTask.h"
#import "File.h"
#import "NSURL+KiwixURLProtocol.h"
#import "Article+Create.h"
#import "CustomBarButtonItem.h"

#define ARTICLE_TITLE @"articleTitle"
#define ARTICLE_RELATIVE_URL @"articleRelativeURL"

@interface Browser ()

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) Book *openingBook;
@property (strong, nonatomic) zimReader *reader;
@property (strong, nonatomic) NSMutableArray *filteredArticleArray;
@property (strong, nonatomic) NSString *placeHolderText;

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property CGFloat previousScrollViewYOffset;
- (IBAction)webViewNavigation:(UIBarButtonItem *)sender;

@end

@implementation Browser

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Model Setup
    self.managedObjectContext = ((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;
    
    self.openingBook = [[CoreDataTask openingBooksInManagedObjectContext:self.managedObjectContext] firstObject]; // Currently only one book should be open (v1.0)
    
    if (self.openingBook) {
        //If have a opening book initialize the reader.
        self.reader = [[zimReader alloc] initWithZIMFileURL:[File zimFileURLInLibraryDirectoryFormFileID:self.openingBook.idString]];
        if (self.article) {
            //If told which article to open, i.e. segued from history.
            [self loadCurrentArticleIntoBrowser];
        } else {
            //Do not know which article to open yet, try find last read article, if no last read load main page
            self.article = [CoreDataTask lastReadArticleFromBook:self.openingBook inManagedObjectContext:self.managedObjectContext];
            [self loadCurrentArticleIntoBrowser];
        }
    }
    
    //View Setup
    self.webView.delegate = self;
    self.searchBar.delegate = self;
    //self.searchBar.layer.borderWidth = 10;
    self.searchDisplayController.delegate = self;
    self.webView.scrollView.delegate = self;
    self.searchDisplayController.displaysSearchBarInNavigationBar = YES;
    
    CustomBarButtonItem *tabButtonItem = [[CustomBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"tab"] andLabelText:@"2"];
    NSMutableArray *toolbarItems = [self.toolbarItems mutableCopy];
    //[toolbarItems removeObjectAtIndex:3];
    //[toolbarItems insertObject:tabButtonItem atIndex:3];
    toolbarItems[3] = tabButtonItem;
    self.toolbarItems = toolbarItems;
    ((UIBarButtonItem *)[self.toolbarItems objectAtIndex:0]).tintColor = [UIColor grayColor];
    ((UIBarButtonItem *)[self.toolbarItems objectAtIndex:1]).tintColor = [UIColor grayColor];
    ((UIBarButtonItem *)[self.toolbarItems objectAtIndex:3]).tintColor = [UIColor grayColor];
    ((UIBarButtonItem *)[self.toolbarItems objectAtIndex:5]).tintColor = [UIColor grayColor];
    ((UIBarButtonItem *)[self.toolbarItems objectAtIndex:7]).tintColor = [UIColor grayColor];
}

- (void)loadCurrentArticleIntoBrowser {
    NSString *articleURLInZimFile = [[NSString alloc] init];
    if (self.article) {
        articleURLInZimFile = self.article.relativeURL;
        self.searchBar.placeholder = self.article.title;
    } else {
        articleURLInZimFile = @"(main)";
        self.searchBar.placeholder = @"Search";
    }
    
    NSURL *url = [NSURL kiwixURLWithZIMFileIDString:self.openingBook.idString articleURL:articleURLInZimFile];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
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
        
        self.searchBar.placeholder = self.article.title;
        self.placeHolderText = self.article.title;
        /*
        if ([self.article.isBookmarked boolValue] != self.bookmarkButtonItem.isHightlighted) {
            [self.bookmarkButtonItem animateWithHighLightState:[self.article.isBookmarked boolValue]];
        }
        
        
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
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGRect frameNav = self.navigationController.navigationBar.frame;
    CGRect frameTool = self.navigationController.toolbar.frame;
    CGRect frameScroll = scrollView.frame;
    CGFloat sizeNav = frameNav.size.height - 21;
    CGFloat sizeScreen = [UIScreen mainScreen].bounds.size.height;
    CGFloat framePercentageHidden = ((20 - frameNav.origin.y) / (frameNav.size.height - 1));
    
    CGFloat scrollOffset = scrollView.contentOffset.y;
    CGFloat scrollDiff = scrollOffset - self.previousScrollViewYOffset;
    CGFloat scrollHeight = scrollView.frame.size.height;
    [scrollView setFrame:CGRectMake(frameScroll.origin.x, frameNav.origin.y -21, frameScroll.size.width, frameTool.origin.y + frameTool.size.height - frameNav.origin.y + 21)];
    //[scrollView setContentInset:UIEdgeInsetsMake(scrollView.contentInset.top, scrollView.contentInset.left, sizeScreen - frameTool.origin.y, scrollView.contentInset.right)];
    NSLog(@"%f", scrollView.contentInset.bottom);
    CGFloat scrollContentSizeHeight = scrollView.contentSize.height + scrollView.contentInset.bottom;
    
    if (scrollOffset <= -scrollView.contentInset.top) {
        //NSLog(@"show");
        frameNav.origin.y = 20;
    } else if ((scrollOffset + scrollHeight) >= scrollContentSizeHeight) {
        //NSLog(@"Hide");
        frameNav.origin.y = -sizeNav;
    } else {
        //NSLog(@"middle");
        frameNav.origin.y = MIN(20, MAX(-sizeNav, frameNav.origin.y - scrollDiff));
        frameTool.origin.y = MAX(sizeScreen - 44, MIN(sizeScreen, frameTool.origin.y + scrollDiff));
    }
    
    [self.navigationController.navigationBar setFrame:frameNav];
    [self.navigationController.toolbar setFrame:frameTool];
    [self updateBarButtonItems:(1 - framePercentageHidden)];
    self.previousScrollViewYOffset = scrollOffset;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self stoppedScrolling];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self stoppedScrolling];
    }
}

- (void)stoppedScrolling
{
    CGRect frame = self.navigationController.navigationBar.frame;
    if (frame.origin.y < 20) {
        [self animateNavBarTo:-(frame.size.height - 21)];
    }
}

- (void)updateBarButtonItems:(CGFloat)alpha
{
    [self.navigationItem.leftBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem* item, NSUInteger i, BOOL *stop) {
        item.customView.alpha = alpha;
    }];
    [self.navigationItem.rightBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem* item, NSUInteger i, BOOL *stop) {
        item.customView.alpha = alpha;
    }];
    self.navigationItem.titleView.alpha = alpha;
    self.navigationController.navigationBar.tintColor = [self.navigationController.navigationBar.tintColor colorWithAlphaComponent:alpha];
}

- (void)animateNavBarTo:(CGFloat)y
{
    [UIView animateWithDuration:0.2 animations:^{
        CGRect frame = self.navigationController.navigationBar.frame;
        CGFloat alpha = (frame.origin.y >= y ? 0 : 1);
        frame.origin.y = y;
        [self.navigationController.navigationBar setFrame:frame];
        [self updateBarButtonItems:alpha];
    }];
}

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
    [searchBar setShowsCancelButton:YES animated:YES];
    [self.navigationController setToolbarHidden:YES animated:YES];
    searchBar.placeholder = @"Search";
}


- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
}

#pragma mark - UISearchDisplayController Delegate Methods
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self filterContentForSearchText:searchString];
    return YES;
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    [controller.searchBar setShowsCancelButton:NO animated:YES];
    [self.navigationController setToolbarHidden:NO animated:YES];
    self.searchBar.placeholder = self.placeHolderText;
}

#pragma mark - Target Actions
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
@end
