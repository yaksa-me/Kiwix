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
@property (strong, nonatomic) NSArray *openingBookList; // An array of Book Obj that is opening

@end

@implementation LibraryTBVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.managedObjectContext = ((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;
    
    [FileCoordinator processFilesWithManagedObjectContext:self.managedObjectContext];
    
    [self setFileLists];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setFileLists {
    self.fileList = [CoreDataTask allBooksInManagedObjectContext:self.managedObjectContext];
    self.openingBookList = [CoreDataTask openingBooksInManagedObjectContext:self.managedObjectContext];
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
    if ([self.fileList count]) {
        return [self.fileList count];
    } else {
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        messageLabel.text = @"Oh, no books...";
        messageLabel.textColor = [UIColor blackColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        [messageLabel sizeToFit];
        
        self.tableView.backgroundView = messageLabel;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BookCell" forIndexPath:indexPath];

    Book *book = [self.fileList objectAtIndex:indexPath.row];
    cell.textLabel.text = book.fileName;
    
    if ([self.openingBookList containsObject:book]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    //cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    // set all book to closed
    for (Book *bookToBeClosed in self.fileList) {
        bookToBeClosed.isOpening = [NSNumber numberWithBool:NO];
    }
    
    Book *book = [self.fileList objectAtIndex:indexPath.row];
    book.isOpening = [NSNumber numberWithBool:YES];
    [self setFileLists];
    
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
        [self setFileLists];
        /*
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
            [Preference noLongerHasAnOpeningBook];
        }
        */
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}
@end
