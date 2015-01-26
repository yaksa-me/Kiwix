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

@interface BookmarksTBVC ()

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSArray *articleBookmarkedArray; //An array of articles
@property (strong, nonatomic) Book *openingBook;

@end

@implementation BookmarksTBVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Bookmark";
    
    self.openingBook = [[CoreDataTask openingBooksInManagedObjectContext:self.managedObjectContext] firstObject];
    self.articleBookmarkedArray = [CoreDataTask articlesReadHistoryInBook:self.openingBook InManagedObjectContext:self.managedObjectContext];
    
    self.navigationController.toolbarHidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark - Slide Menu Delegation
- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}

@end
