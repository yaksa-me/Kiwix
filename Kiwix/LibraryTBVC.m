//
//  LibraryTBVC.m
//  Kiwix
//
//  Created by Chris Li on 1/11/15.
//  Copyright (c) 2015 Chris Li. All rights reserved.
//

#import "LibraryTBVC.h"
#import "CoreDataTask.h"
#import "FileCoordinator.h"
#import "zimFileFinder.h"
#import "Preference.h"
#import "AppDelegate.h"
#import "Book.h"
#import "Parser.h"

@interface LibraryTBVC ()

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSArray *fileList; // An array of Book Obj
@property (strong, nonatomic) NSArray *openingBookList; // An array of Book Obj that is opening
@property (strong, nonatomic) NSTimer *timer;

@end

@implementation LibraryTBVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.rightBarButtonItem.title = @"Delete";
    
    self.managedObjectContext = ((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;
    [FileCoordinator processFilesWithManagedObjectContext:self.managedObjectContext];
    [self setFileLists];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    [self startTimer];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.timer invalidate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setFileLists {
    self.fileList = [CoreDataTask allBooksInManagedObjectContext:self.managedObjectContext];
    //self.openingBookList = [CoreDataTask openingBooksInManagedObjectContext:self.managedObjectContext];
}

- (void)updateBookList {
    [FileCoordinator processFilesWithManagedObjectContext:self.managedObjectContext];
    [self setFileLists];
    [self.tableView reloadData];
}

- (void)startTimer {
    self.timer = [NSTimer timerWithTimeInterval:1.0f target:self selector:@selector(updateBookList) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    if (editing) {
        //start editing
        [self.timer invalidate];
        self.editButtonItem.title = NSLocalizedString(@"Done", @"Done");
    } else {
        //finish editing
        [self startTimer];
        self.editButtonItem.title = NSLocalizedString(@"Delete", @"Delete");
    }
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
    /*
    NSString *fileSizeFormatted = [NSByteCountFormatter stringFromByteCount:[book.fileSize longLongValue]*1000 countStyle:NSByteCountFormatterCountStyleFile];
    NSString *detailText = [[@"Size: " stringByAppendingString:fileSizeFormatted] stringByAppendingString:@", "];
    detailText = [[[detailText stringByAppendingString:@"Language: "] stringByAppendingString:book.language] stringByAppendingString:@", "];
    detailText = [[detailText stringByAppendingString:@"Article: "] stringByAppendingString:[Parser articleCountString:[book.articleCount integerValue]]];
    cell.detailTextLabel.text = detailText;*/
    
    if ([self.openingBookList containsObject:book]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Book *book = [self.fileList objectAtIndex:indexPath.row];
        [FileCoordinator deleteBookWithID:book.idString inManagedObjectContext:self.managedObjectContext];
        [self setFileLists];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 49;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // set all book to closed
    for (Book *bookToBeClosed in self.fileList) {
        //bookToBeClosed.isOpening = [NSNumber numberWithBool:NO];
    }
    
    Book *book = [self.fileList objectAtIndex:indexPath.row];
    //book.isOpening = [NSNumber numberWithBool:YES];
    [self setFileLists];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [tableView reloadData];
}
@end
