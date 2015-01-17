//
//  SearchTBVC.m
//  Kiwix
//
//  Created by Chris Li on 1/11/15.
//  Copyright (c) 2015 Chris Li. All rights reserved.
//

#import "SearchTBVC.h"
#import "CoreDataTask.h"
#import "Article.h"

@interface SearchTBVC ()
/*
@property (strong, nonatomic)UISearchBar *searchBar;
@property (strong, nonatomic)UISearchDisplayController *searchController;*/
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic)NSMutableArray *filteredArticleArray;

@end

@implementation SearchTBVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Search";
    /*
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.delegate = self;
    self.navigationItem.titleView = self.searchBar;
    self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.searchController.delegate = self;
    self.searchController.searchResultsDataSource = self;
    self.searchController.searchResultsDelegate = self;
    */
    self.filteredArticleArray = [[NSMutableArray alloc] initWithCapacity:[[CoreDataTask allArticlesInManagedObjectContext:self.managedObjectContext] count]];
    NSLog(@"Switched to Search.");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SlideMenuDelegation
- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 1;
    } else {
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        NSLog(@"%lu", (unsigned long)[self.filteredArticleArray count]);
        return [self.filteredArticleArray count];
    } else {
        return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"searchArticle"];
        Article *article = [self.filteredArticleArray objectAtIndex:indexPath.row];
        cell.textLabel.text = article.title;
    } else {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"searchArticle" forIndexPath:indexPath];
        //cell.textLabel.text = @"test";
    }
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - search filter
-(void)filterContentForSearchText:(NSString*)searchText{
    [self.filteredArticleArray removeAllObjects];
    NSArray *filteredArticles = [CoreDataTask articlesTitleFilteredBySearchText:searchText inManagedObjectContext:self.managedObjectContext];
    self.filteredArticleArray = [NSMutableArray arrayWithArray:filteredArticles];
    NSLog(@"Search text:%@, %lu items found in Database", searchText, (unsigned long)[self.filteredArticleArray count]);
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
/*
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    //[self.searchController setActive:YES animated:YES];
    [self.searchDisplayController setActive:YES animated:YES];
}*/
@end
