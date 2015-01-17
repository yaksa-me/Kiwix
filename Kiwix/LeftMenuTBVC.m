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
#import "Preference.h"

@interface LeftMenuTBVC ()

@property BOOL showToolMenu;
- (IBAction)bookmarkButton:(UIBarButtonItem *)sender;
- (IBAction)toolButton:(UIBarButtonItem *)sender;

@end

@implementation LeftMenuTBVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    return 5;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LeftMenuCell" forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LeftMenuCell"];
    }
    
    if (indexPath.row == 0) {
        cell.textLabel.text = @"Book Case";
    } else if (indexPath.row == 1) {
        cell.textLabel.text = @"Search";
    } else if (indexPath.row == 2){
        cell.textLabel.text = @"Reading";
    } else if (indexPath.row == 3) {
        cell.textLabel.text = @"Bookmarks";
    } else {
        cell.textLabel.text = @"History";
    }
    
    // Configure the cell...
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    
    UIViewController *viewController ;
    
    switch (indexPath.row)
    {
        case 0:
            viewController = [mainStoryboard instantiateViewControllerWithIdentifier: @"LibraryTBVC"];
            break;
            
        case 1:
            viewController = [mainStoryboard instantiateViewControllerWithIdentifier: @"SearchTBVC"];
            ((SearchTBVC *)viewController).managedObjectContext = self.managedObjectContext;
            break;
            
        case 2:
            viewController = [mainStoryboard instantiateViewControllerWithIdentifier: @"ArticleVC"];
            ((ArticleVC *)viewController).bookIDString = [Preference lastReadArticleIDString];
            ((ArticleVC *)viewController).articleTitle = [Preference lastReadArticleTitle];
            NSLog(@"%@, %@", [Preference lastReadArticleIDString], [Preference lastReadArticleTitle]);
            break;
            
        case 3:
            viewController = [mainStoryboard instantiateViewControllerWithIdentifier: @"BookmarksTBVC"];
            break;
            
        case 4:
            viewController = [mainStoryboard instantiateViewControllerWithIdentifier: @"HistoryTBVC"];
            ((HistoryTBVC *)viewController).managedObjectContext = self.managedObjectContext;
            break;
        case 7:
            [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
            [[SlideNavigationController sharedInstance] popToRootViewControllerAnimated:YES];
            return;
            break;
    }
    
    [[SlideNavigationController sharedInstance] popAllAndSwitchToViewController:viewController withSlideOutAnimation:YES andCompletion:nil];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [Preference setCurrentMenuIndex:indexPath.row];
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

- (IBAction)bookmarkButton:(UIBarButtonItem *)sender {
    self.showToolMenu = NO;
    [self.tableView reloadData];
}

- (IBAction)toolButton:(UIBarButtonItem *)sender {
    self.showToolMenu = YES;
    [self.tableView reloadData];
}
@end
