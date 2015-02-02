//
//  LeftMenuTBVC.m
//  Kiwix
//
//  Created by Chris Li on 1/11/15.
//  Copyright (c) 2015 Chris Li. All rights reserved.
//

#import "LeftMenuTBVC.h"
#import "ArticleVC.h"
#import "SearchTBVC.h"
#import "HistoryTBVC.h"
#import "BookmarksTBVC.h"
#import "Preference.h"
#import "LeftMenuTableViewCell.h"
#import "CoreDataTask.h"
#import "Book+Create.h"
#import "Article.h"

@interface LeftMenuTBVC ()

@property BOOL showToolMenu;
@property (strong, nonatomic) Book *openingBook;
@property (strong, nonatomic) NSArray *articleReadHistoryArray; //An array of articles

- (IBAction)toolButton:(UIBarButtonItem *)sender;

@end

@implementation LeftMenuTBVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.openingBook = [[CoreDataTask openingBooksInManagedObjectContext:self.managedObjectContext] firstObject];
    self.articleReadHistoryArray = [CoreDataTask articlesReadHistoryInBook:self.openingBook InManagedObjectContext:self.managedObjectContext];
    //[[self.toolbarItems firstObject] setImage:[UIImage imageNamed:@"settings-64.png"] forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableViewConditioningOnNotificationMesssage:) name:SlideNavigationControllerDidReveal object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SlideNavigationControllerDidReveal object:nil];
}

- (void)reloadTableViewConditioningOnNotificationMesssage:(NSNotification *)notification{
    self.openingBook = [[CoreDataTask openingBooksInManagedObjectContext:self.managedObjectContext] firstObject];
    self.articleReadHistoryArray = [CoreDataTask articlesReadHistoryInBook:self.openingBook InManagedObjectContext:self.managedObjectContext];
    if ([[notification.userInfo objectForKey:@"menu"] isEqualToString:@"left"]) {
        [self.tableView reloadData];
    }
    
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
    // Return the number of rows in the section.
    return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *reuseIdentifier = @"LeftMenuTableViewCell";
    LeftMenuTableViewCell *cell = (LeftMenuTableViewCell *)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:reuseIdentifier owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    if (indexPath.row == 0) {
        cell.cellTitleLabel.text = @"Reading";
        Article *lastReadArticle = [CoreDataTask lastReadArticleFromBook:self.openingBook inManagedObjectContext:self.managedObjectContext];
        if (lastReadArticle) {
            cell.cellDetailLabel.text = [NSString stringWithFormat:@"Last read: %@", lastReadArticle.title];
        } else {
            cell.cellDetailLabel.text = @"Haven't opened an article yet!";
        }
        
    } else if (indexPath.row == 1){
        cell.cellTitleLabel.text = @"Bookmarks";
    } else {
        cell.cellTitleLabel.text = @"History";
        NSUInteger articleHistoryCount = [self.articleReadHistoryArray count];
        if (articleHistoryCount <= 1) {
            cell.cellDetailLabel.text = [NSString stringWithFormat:@"Read %d article", articleHistoryCount];
        } else {
            cell.cellDetailLabel.text = [NSString stringWithFormat:@"Read %d articles", articleHistoryCount];
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 66;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    
    UIViewController *viewController ;
    
    switch (indexPath.row)
    {
        case 0:
            viewController = [mainStoryboard instantiateViewControllerWithIdentifier: @"ArticleVC"];
            [Preference setCurrentMenuIndex:1];
            break;
            
        case 1:
            viewController = [mainStoryboard instantiateViewControllerWithIdentifier: @"BookmarksTBVC"];
            [Preference setCurrentMenuIndex:2];
            break;
            
        case 2:
            viewController = [mainStoryboard instantiateViewControllerWithIdentifier: @"HistoryTBVC"];
            [Preference setCurrentMenuIndex:3];
            break;
        case 7:
            [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
            [[SlideNavigationController sharedInstance] popToRootViewControllerAnimated:NO];
            return;
            break;
    }
    
    [[SlideNavigationController sharedInstance] popAllAndSwitchToViewController:viewController withSlideOutAnimation:NO andCompletion:nil];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [Preference setCurrentMenuIndex:indexPath.row];
}

- (IBAction)toolButton:(UIBarButtonItem *)sender {
    self.showToolMenu = YES;
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    UIViewController *viewController = [mainStoryboard instantiateViewControllerWithIdentifier: @"SettingTBVC"];
    [[SlideNavigationController sharedInstance] popAllAndSwitchToViewController:viewController withSlideOutAnimation:YES andCompletion:nil];
}
@end
