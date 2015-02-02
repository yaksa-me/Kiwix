//
//  SearchTBVC.m
//  Kiwix
//
//  Created by Chris Li on 1/11/15.
//  Copyright (c) 2015 Chris Li. All rights reserved.
//

#import "SearchTBVC.h"
#import "ArticleVC.h"
#import "CoreDataTask.h"
#import "Article.h"
#import "Preference.h"
#import "zimFileFinder.h"
#import "zimReader.h"
#import "Book+Create.h"
#import "FileInfoView.h"
#import "AppDelegate.h"

@interface SearchTBVC ()

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSMutableArray *filteredArticleArray; // An array of article names
@property (strong, nonatomic) zimReader *reader;
@property (strong, nonatomic) Book *openingBook;
@property (strong, nonatomic) UIBarButtonItem *leftNavBarItem;
@end

@implementation SearchTBVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Search";
    
    self.managedObjectContext = ((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;
    self.filteredArticleArray = [[NSMutableArray alloc] init];
    self.openingBook = [[CoreDataTask openingBooksInManagedObjectContext:self.managedObjectContext] firstObject];
    if (self.openingBook) {
        self.reader = [[zimReader alloc] initWithZIMFileURL:[zimFileFinder zimFileURLInLibraryDirectoryFormFileID:self.openingBook.idString]];
    }
    
    self.searchBar.frame = CGRectMake(0, 70, 320, 44);
    self.navigationController.toolbarHidden = YES;
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    
    //self.searchDisplayController.displaysSearchBarInNavigationBar = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(toggleSearch)];

    
    NSLog(@"Switched to Search.");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.searchBar resignFirstResponder];
}

- (void)toggleSearch {
    // get the height of the search bar
    float delta = self.searchBar.frame.size.height;
    // check if toolbar was visible or hidden before the animation
    BOOL isHidden = [self.searchBar isHidden];
    
    // if search bar was visible set delta to negative value
    if (!isHidden) {
        delta *= -1;
    } else {
        // if search bar was hidden then make it visible
        self.searchBar.hidden = NO;
    }
    
    // run animation 0.7 second and no delay
    [UIView animateWithDuration:0.7 delay: 0.0 options: UIViewAnimationOptionCurveEaseIn animations:^{
        // move search bar delta units up or down
        self.searchBar.frame = CGRectOffset(self.searchBar.frame, 0.0, delta);
    } completion:^(BOOL finished) {
        //if the bar was visible then hide it
        if (!isHidden) {
            self.searchBar.hidden = YES;
        }
    }];
}

#pragma mark - SlideMenu Delegation
- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.openingBook) {
        //Has a opening Book
        if (tableView == self.searchDisplayController.searchResultsTableView) {
            return 1;
        } else {
            FileInfoView *messageView = [[[NSBundle mainBundle] loadNibNamed:@"FileInfoView" owner:self options:nil] firstObject];
            messageView.bookTitleLabel.text = self.openingBook.fileName;
            messageView.numberOfArticleLabel.text = [NSString stringWithFormat:@"%lu articles", (unsigned long)[self.reader getArticleCount]];
            self.tableView.backgroundView = messageView;
            self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            return 0;
        }
    } else {
        //Display message when no book is opening
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        messageLabel.text = @"Open a zim file please...";
        messageLabel.textColor = [UIColor blackColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        [messageLabel sizeToFit];
        
        self.tableView.backgroundView = messageLabel;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
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
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"SearchArticleCell"];
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        cell.textLabel.text = [self.filteredArticleArray objectAtIndex:indexPath.row];
    }
    
    return cell;
}


#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"SelectArticleFromSearch"]) {
        NSIndexPath *indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
        ArticleVC *destination = [segue destinationViewController];
        //destination.articleTitle = [self.filteredArticleArray objectAtIndex:indexPath.row];
    }
}

#pragma mark - Search Filter
-(void)filterContentForSearchText:(NSString*)searchText{
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

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    return YES;
}
@end
