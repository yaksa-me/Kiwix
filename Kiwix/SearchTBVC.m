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

@interface SearchTBVC ()

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSMutableArray *filteredArticleArray; // An array of article names
@property (strong, nonatomic) zimReader *reader;

@end

@implementation SearchTBVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Search";

    self.filteredArticleArray = [[NSMutableArray alloc] init];
    
    if ([Preference hasOpeningBook]) {
        NSString *openingBookPath = [zimFileFinder zimFilePathInAppSupportDirectoryFormFileID:[Preference openingBookID]];
        self.reader = [[zimReader alloc] initWithZIMFileURL:[NSURL fileURLWithPath:openingBookPath]];
    }
    NSLog(@"Switched to Search.");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SlideMenu Delegation
- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([Preference hasOpeningBook]) {
        if (tableView == self.searchDisplayController.searchResultsTableView) {
            return 1;
        } else {
            UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
            messageLabel.text = [NSString stringWithFormat:@"%@ is opening, has %lu articles", [self.reader getTitle], (unsigned long)[self.reader getArticleCount]];
            self.tableView.backgroundView = messageLabel;
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
        messageLabel.font = [UIFont fontWithName:@"Palatino-Italic" size:20];
        [messageLabel sizeToFit];
        
        self.tableView.backgroundView = messageLabel;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([Preference hasOpeningBook]) {
        if (tableView == self.searchDisplayController.searchResultsTableView) {
            return [self.filteredArticleArray count];
        } else {
            return 0;
        }
    } else {
        //Display message when no book is opening
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
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        ArticleVC *destination = [segue destinationViewController];
        destination.articleTitle = [self.filteredArticleArray objectAtIndex:indexPath.row];
    }
}

#pragma mark - Search Filter
-(void)filterContentForSearchText:(NSString*)searchText{
    [self.filteredArticleArray removeAllObjects];
    if ([Preference hasOpeningBook]) {
        NSArray *filteredArticles = [self.reader searchSuggestionsSmart:searchText];
        self.filteredArticleArray = [NSMutableArray arrayWithArray:filteredArticles];
        NSLog(@"Search text:%@, %lu items found in zimfile", searchText, (unsigned long)[self.filteredArticleArray count]);
    }
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
