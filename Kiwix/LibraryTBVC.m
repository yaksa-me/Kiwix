//
//  LibraryTBVC.m
//  Kiwix
//
//  Created by Chris Li on 1/11/15.
//  Copyright (c) 2015 Chris Li. All rights reserved.
//

#import "LibraryTBVC.h"
#import "ArticleListTBVC.h"
#import "CoreDataTask.h"
#import "FileCoordinator.h"
#import "zimFileFinder.h"
#import "Preference.h"
#import "AppDelegate.h"
#import "Book.h"

@interface LibraryTBVC ()

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSArray *fileList; // An array of Book Obj
@property (strong, nonatomic) NSString *openingBookID;

@end

@implementation LibraryTBVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.managedObjectContext = ((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;
    
    [FileCoordinator moveZimFileFromDocumentDirectoryToApplicationSupport];
    [FileCoordinator addAllFilesInApplicationSupportDirToDatabaseInManagedObjectContext:self.managedObjectContext];
    
    [self setFileListAndOpeningBookID];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Slide Menu Delegation
- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return NO;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([[zimFileFinder zimFileIDsInAppSupportDirectory] count]) {
        return [self.fileList count];
    } else {
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        messageLabel.text = @"no books...";
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BookCell" forIndexPath:indexPath];

    Book *book = [self.fileList objectAtIndex:indexPath.row];
    cell.textLabel.text = book.title;
    
    if ([book.idString isEqualToString:self.openingBookID]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)setFileListAndOpeningBookID {
    self.fileList = [CoreDataTask allBooksInManagedObjectContext:self.managedObjectContext];
    
    if ([Preference hasOpeningBook]) {
        self.openingBookID = [Preference openingBookID];
    } else {
        self.openingBookID = nil;
    }
}
#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    Book *book = [self.fileList objectAtIndex:indexPath.row];
    self.openingBookID = book.idString;
    [Preference setOpeningBookID:self.openingBookID];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [tableView reloadData];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Book *book = [self.fileList objectAtIndex:indexPath.row];
        [FileCoordinator deleteBookWithID:book.idString inManagedObjectContext:self.managedObjectContext];
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
            [Preference noLongerHasAnOpeningBook];
        }
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}


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
    if ([segue.identifier isEqualToString:@"ArticleList"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        ArticleListTBVC *destination = [segue destinationViewController];
        destination.bookIDString = ((Book *)[self.fileList objectAtIndex:indexPath.row]).idString;
        destination.managedObjectContext = self.managedObjectContext;
    }
}
*/

@end
