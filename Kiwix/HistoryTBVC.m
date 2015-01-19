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

@interface HistoryTBVC ()

@property (strong, nonatomic) NSArray *articleReadHistoryArray; //An array of articles

@end

@implementation HistoryTBVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"History";
    
    self.articleReadHistoryArray = [CoreDataTask articlesReadHistoryInManagedObjectContext:self.managedObjectContext];
    
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
    
    return cell;
}

#pragma mark - Slide Menu Delegation
- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}

@end
