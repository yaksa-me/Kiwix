//
//  HistoryTBVC.m
//  Kiwix
//
//  Created by Chris Li on 1/15/15.
//  Copyright (c) 2015 Chris Li. All rights reserved.
//

#import "HistoryTBVC.h"
#import "Article.h"
#import "Book.h"
#import "CoreDataTask.h"
#import "Preference.h"
#import "Parser.h"
#import "ArticleVC.h"
#import "AppDelegate.h"

@interface HistoryTBVC ()

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSArray *articleReadHistoryArray; //An array of articles
@property (strong, nonatomic) Book *openingBook;

@end

@implementation HistoryTBVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"History";
    
    self.managedObjectContext = ((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;
    self.openingBook = [[CoreDataTask openingBooksInManagedObjectContext:self.managedObjectContext] firstObject];
    [self setTableViewDataSource];
    
    NSTimer* timer = [NSTimer timerWithTimeInterval:60.0f target:self selector:@selector(updateTableView) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    
    self.navigationController.toolbarHidden = YES;
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)updateTableView {
    [self.tableView reloadData];
}

- (void)setTableViewDataSource {
    self.articleReadHistoryArray = [CoreDataTask articlesReadHistoryInBook:self.openingBook InManagedObjectContext:self.managedObjectContext];
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
    return [self.articleReadHistoryArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HistoryArticleCell" forIndexPath:indexPath];
    
    Article *article = [self.articleReadHistoryArray objectAtIndex:indexPath.row];
    cell.textLabel.text = article.title;
    cell.detailTextLabel.text = [Parser timeDifferenceStringBetweenNowAnd:article.lastReadDate];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Article *article = [self.articleReadHistoryArray objectAtIndex:indexPath.row];
        [CoreDataTask deleteArticle:article inManagedObjectContext:self.managedObjectContext];
        [self setTableViewDataSource];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - Slide Menu Delegation
- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}

#pragma mark - Navigation 
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"SelectArticleFromHistory"]) {
        ArticleVC *destination = segue.destinationViewController;
        NSUInteger indexOfSelectedArticle = [self.tableView indexPathForCell:(UITableViewCell *)sender].row;
        Article *selectedArticle = [self.articleReadHistoryArray objectAtIndex:indexOfSelectedArticle];
        destination.article = selectedArticle;
    }
}
@end
