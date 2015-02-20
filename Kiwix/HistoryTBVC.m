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
#import "EditingToolbar.h"

@interface HistoryTBVC ()

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSArray *articleReadHistoryArray; //An array of articles
@property (strong, nonatomic) Book *openingBook;
@property (strong, nonatomic) EditingToolbar *editingToolBar;
- (IBAction)markAllButtonItem:(UIBarButtonItem *)sender;
- (IBAction)trashButtonItem:(UIBarButtonItem *)sender;

@end

@implementation HistoryTBVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Recent";
    
    self.managedObjectContext = ((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;
    self.openingBook = [[CoreDataTask openingBooksInManagedObjectContext:self.managedObjectContext] firstObject];
    [self setTableViewDataSource];
    
    NSTimer* timer = [NSTimer timerWithTimeInterval:60.0f target:self selector:@selector(reloadTableView) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    
    self.navigationController.toolbarHidden = YES;
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, 0.00001f)];
    self.tableView.tableFooterView = [self tableFooterView];
    
    self.navigationController.navigationBar.userInteractionEnabled = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endEditing) name:SlideNavigationControllerDidOpen object:nil];
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SlideNavigationControllerDidOpen object:nil];
}

- (void)endEditing {
    [self.tableView setEditing:NO animated:YES];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    if (editing) {
        [self.navigationController setToolbarHidden:NO animated:YES];
    } else {
        [self.navigationController setToolbarHidden:YES animated:YES];
    }
}

- (void)reloadTableView {
    [self.tableView reloadData];
}

- (void)setTableViewDataSource {
    self.articleReadHistoryArray = [CoreDataTask articlesReadHistoryInBook:self.openingBook InManagedObjectContext:self.managedObjectContext];
}

- (UIView *)tableFooterView {
    CGRect footerRect = CGRectMake(0, 0, 320, 40);
    UILabel *tableFooter = [[UILabel alloc] initWithFrame:footerRect];
    tableFooter.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    tableFooter.textColor = [UIColor darkGrayColor];
    tableFooter.opaque = NO;
    tableFooter.textAlignment = NSTextAlignmentCenter;
    if ([self.articleReadHistoryArray count] <=1) {
        tableFooter.text = [NSString stringWithFormat:@"There are %lu recent article.", (unsigned long)[self.articleReadHistoryArray count]];
    } else {
        tableFooter.text = [NSString stringWithFormat:@"There are %lu recent articles.", (unsigned long)[self.articleReadHistoryArray count]];
    }
    
    return tableFooter;
}


- (void)deleteArticleAtIndexPathArray:(NSArray *)indexPathArray {
    for (NSIndexPath *indexPath in indexPathArray) {
        Article *article = [self.articleReadHistoryArray objectAtIndex:indexPath.row];
        [CoreDataTask deleteArticle:article inManagedObjectContext:self.managedObjectContext];
    }
    [self setTableViewDataSource];
    
    [self.tableView deleteRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationAutomatic];
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
    if ([article.isBookmarked boolValue]) {
        cell.imageView.image = [[UIImage imageNamed:@"bookmark_highlighted"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        cell.imageView.tintColor = [UIColor redColor];
        cell.imageView.alpha = 0.75;
    } else {
        cell.imageView.image = [[UIImage imageNamed:@"bookmark"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        cell.imageView.tintColor = [UIColor grayColor];
        cell.imageView.alpha = 0.8;
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self deleteArticleAtIndexPathArray:@[indexPath]];
    }
}

#pragma mark - Slide Menu Delegation
- (BOOL)slideNavigationControllerShouldDisplayLeftMenu {
    return YES;
}

#pragma mark - Navigation 
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if (self.tableView.editing) {
        return NO;
    } else {
        return YES;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"SelectArticleFromHistory"]) {
        ArticleVC *destination = segue.destinationViewController;
        NSUInteger indexOfSelectedArticle = [self.tableView indexPathForCell:(UITableViewCell *)sender].row;
        Article *selectedArticle = [self.articleReadHistoryArray objectAtIndex:indexOfSelectedArticle];
        destination.article = selectedArticle;
        [Preference setCurrentMenuIndex:0];
    }
}

#pragma mark - Target Action
- (IBAction)markAllButtonItem:(UIBarButtonItem *)sender {
    if ([sender.title isEqualToString:@"Mark All"]) {
        for (int row = 0; row < [self.tableView numberOfRowsInSection:0]; row ++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
            [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        }
        sender.title = @"Mark None";
    } else {
        for (int row = 0; row < [self.tableView numberOfRowsInSection:0]; row ++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
        sender.title = @"Mark All";
    }
}

- (IBAction)trashButtonItem:(UIBarButtonItem *)sender {
    NSMutableArray *selectedCellIndexPaths = [[NSMutableArray alloc] init];
    for (int row = 0; row < [self.tableView numberOfRowsInSection:0]; row ++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if (cell.isSelected) {
            [selectedCellIndexPaths addObject:indexPath];
        }
    }
    [self deleteArticleAtIndexPathArray:selectedCellIndexPaths];
}
@end
