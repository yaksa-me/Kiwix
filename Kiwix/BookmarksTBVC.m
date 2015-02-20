//
//  BookmarksTBVC.m
//  Kiwix
//
//  Created by Chris Li on 1/15/15.
//  Copyright (c) 2015 Chris Li. All rights reserved.
//

#import "BookmarksTBVC.h"
#import "CoreDataTask.h"
#import "Preference.h"
#import "Article.h"
#import "Book.h"
#import "AppDelegate.h"
#import "ArticleVC.h"

@interface BookmarksTBVC ()

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSArray *articleBookmarkedArray; //An array of articles
@property (strong, nonatomic) Book *openingBook;

@end

@implementation BookmarksTBVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Favorite";
    
    self.managedObjectContext = ((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;
    
    self.openingBook = [[CoreDataTask openingBooksInManagedObjectContext:self.managedObjectContext] firstObject];
    self.articleBookmarkedArray = [CoreDataTask articlesBookmarkedInBook:self.openingBook InManagedObjectContext:self.managedObjectContext];
    
    self.navigationController.toolbarHidden = YES;
    
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, 0.00001f)];
    self.tableView.tableFooterView = [self tableFooterView];
    
    self.navigationController.navigationBar.userInteractionEnabled = YES;
}

- (UIView *)tableFooterView {
    CGRect footerRect = CGRectMake(0, 0, 320, 40);
    UILabel *tableFooter = [[UILabel alloc] initWithFrame:footerRect];
    tableFooter.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    tableFooter.textColor = [UIColor darkGrayColor];
    tableFooter.opaque = NO;
    tableFooter.textAlignment = NSTextAlignmentCenter;
    if ([self.articleBookmarkedArray count] <=1) {
        tableFooter.text = [NSString stringWithFormat:@"There are %lu bookmarked article.", (unsigned long)[self.articleBookmarkedArray count]];
    } else {
        tableFooter.text = [NSString stringWithFormat:@"There are %lu bookmarked articles.", (unsigned long)[self.articleBookmarkedArray count]];
    }
    
    return tableFooter;
}

- (void)loadFileListFromInternet {
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.articleBookmarkedArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BookmarkArticleCell" forIndexPath:indexPath];
    
    Article *article = [self.articleBookmarkedArray objectAtIndex:indexPath.row];
    cell.textLabel.text = article.title;
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

#pragma mark - Table View Delagete
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    ArticleVC *articleVC = [mainStoryboard instantiateViewControllerWithIdentifier: @"ArticleVC"];
    Article *selectedArticle = [self.articleBookmarkedArray objectAtIndex:indexPath.row];
    articleVC.article = selectedArticle;
    [[SlideNavigationController sharedInstance] popAllAndSwitchToViewController:articleVC withSlideOutAnimation:YES andCompletion:nil];
    [Preference setCurrentMenuIndex:0];
}

#pragma mark - Slide Menu Delegation
- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"SelectArticleFromBookmark"]) {
        ArticleVC *destination = segue.destinationViewController;
        NSUInteger indexOfSelectedArticle = [self.tableView indexPathForCell:(UITableViewCell *)sender].row;
        Article *selectedArticle = [self.articleBookmarkedArray objectAtIndex:indexOfSelectedArticle];
        destination.article = selectedArticle;
        [Preference setCurrentMenuIndex:0];
    }
}

@end
