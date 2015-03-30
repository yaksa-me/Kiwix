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
#import "ZimMultiReader.h"
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
@property (strong, nonatomic) NSMutableArray *filteredArticleURLArray;
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
    /*
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
    }*/
    
    [self setupView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshBrowserWithNewArticle:) name:@"RefreshWebView" object:nil];
}

- (void)setupView {
    self.webView.delegate = self;
    self.searchBar.delegate = self;
    self.webView.opaque = NO;
    self.searchDisplayController.delegate = self;
    self.webView.scrollView.delegate = self;
    self.searchDisplayController.displaysSearchBarInNavigationBar = YES;
    self.navigationController.navigationBar.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
    
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
/*
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

- (void)refreshBrowserWithNewArticle:(NSNotification *)notification {
    self.article = [notification.userInfo objectForKey:@"newArticleObj"];
    [self loadCurrentArticleIntoBrowser];
}
 */

- (void)loadArticleWithURL:(NSURL *)url {
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
    /*
    CGRect frameNav = self.navigationController.navigationBar.frame;
    CGRect frameTool = self.navigationController.toolbar.frame;
    CGRect frameScroll = scrollView.frame;
    CGFloat sizeNav = frameNav.size.height - 21;
    CGFloat heightScreen = [UIScreen mainScreen].bounds.size.height;
    CGFloat framePercentageHidden = ((20 - frameNav.origin.y) / (frameNav.size.height - 1));
    
    CGFloat scrollOffset = scrollView.contentOffset.y;
    CGFloat scrollDiff = scrollOffset - self.previousScrollViewYOffset;
    CGFloat scrollHeight = scrollView.frame.size.height;
    //[scrollView setFrame:CGRectMake(frameScroll.origin.x, frameNav.origin.y -21, frameScroll.size.width, frameTool.origin.y + frameTool.size.height - frameNav.origin.y + 21)];
    
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
        frameTool.origin.y = MAX(heightScreen - 44, MIN(heightScreen, frameTool.origin.y + scrollDiff));
    }

    [scrollView setContentInset:UIEdgeInsetsMake(scrollView.contentInset.top, scrollView.contentInset.left, heightScreen - frameTool.origin.y, scrollView.contentInset.right)];
    [scrollView setScrollIndicatorInsets:UIEdgeInsetsMake(frameNav.size.height+frameNav.origin.y, scrollView.scrollIndicatorInsets.left, scrollView.contentInset.bottom, scrollView.scrollIndicatorInsets.right)];
    [self.navigationController.navigationBar setFrame:frameNav];
    [self.navigationController.toolbar setFrame:frameTool];
    [self updateNavBarButtonItems:(1 - framePercentageHidden)];
    self.previousScrollViewYOffset = scrollOffset;
    */
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
    if (frame.origin.y < 0) {
        //Animation hide
        [self animateNavBarTo:-(frame.size.height - 21)];
    } else {
        //Animation show
        [self animateNavBarTo:21];
    }
}

- (void)updateNavBarButtonItems:(CGFloat)alpha
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

- (void)animateNavBarTo:(CGFloat)yNav
{
    CGRect frameNav = self.navigationController.navigationBar.frame;
    CGRect frameTool = self.navigationController.toolbar.frame;
    CGPoint contentOffset = self.webView.scrollView.contentOffset;
    CGFloat heightScreen = [UIScreen mainScreen].bounds.size.height;
    CGFloat alpha = (frameNav.origin.y >= yNav ? 0 : 1);
    
    contentOffset.y += frameNav.origin.y - yNav;
    frameNav.origin.y = yNav;
    frameTool.origin.y = alpha == 1 ? heightScreen - frameTool.size.height : heightScreen;
    
    [UIView animateWithDuration:0.2 animations:^{
        [self.navigationController.navigationBar setFrame:frameNav];
        [self.navigationController.toolbar setFrame:frameTool];
        [self.webView.scrollView setContentOffset:contentOffset];
        [self updateNavBarButtonItems:alpha];
    }];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([File numberOfZimFilesInDocDir]) {
        //Have at least one zim file
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
    if ([File numberOfZimFilesInDocDir]) {
        //Have at least one zim file
        if (tableView == self.searchDisplayController.searchResultsTableView) {
            return [self.filteredArticleURLArray count];
        } else {
            return 0;
        }
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.searchDisplayController.searchResultsTableView dequeueReusableCellWithIdentifier:@"SearchArticleCell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SearchArticleCell"];
    }
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        cell.textLabel.text = [[self.filteredArticleURLArray objectAtIndex:indexPath.row] description];
    }
    
    return cell;
}

#pragma mark - Table View Delagate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        NSURL *selectedArticleURL = [self.filteredArticleURLArray objectAtIndex:indexPath.row];
        [self loadArticleWithURL:selectedArticleURL];
        /*
        UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
        NSString *articleTitle = selectedCell.textLabel.text;
        
        //Create an article if article doesn't exist, regradless of whether it is main page or not
        NSMutableDictionary *articleInfo = [[NSMutableDictionary alloc] init];
        [articleInfo setObject:articleTitle forKey:ARTICLE_TITLE];
        [articleInfo setObject:[self.reader pageURLFromTitle:articleTitle] forKey:ARTICLE_RELATIVE_URL];
        self.article = [Article articleWithTitleInfo:articleInfo andBook:self.openingBook inManagedObjectContext:self.managedObjectContext];
        [self loadCurrentArticleIntoBrowser];
         */
        //[self loadArticleOfTitle]
        [self.searchBar setShowsCancelButton:NO animated:YES];
        [self.searchDisplayController setActive:NO animated:YES];
    }
}

#pragma mark - Search Helper
- (void)filterContentForSearchText:(NSString*)searchText{
    [self.filteredArticleURLArray removeAllObjects];
    if ([File numberOfZimFilesInDocDir]) {
        NSArray *results = [[ZimMultiReader sharedInstance] universalSearchSuggestionWithSearchTerm:searchText];
        self.filteredArticleURLArray = [NSMutableArray arrayWithArray:results];
        NSLog(@"Search text:%@, %lu items found.", searchText, (unsigned long)[self.filteredArticleURLArray count]);
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
    [self.filteredArticleURLArray removeAllObjects];
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
