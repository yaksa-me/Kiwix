//
//  BooksViewController.m
//  Kiwix
//
//  Created by Chris Li on 4/4/15.
//  Copyright (c) 2015 Chris Li. All rights reserved.
//

#import "BooksViewController.h"
#import "Parser.h"
#import "AppDelegate.h"
#import "Book+Task.h"
#import "Marco.h"
#import "Preference.h"
#import "File.h"
#import "ZimMultiReader.h"

#define PICKER_HEIGHT 162

@interface BooksViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)dismiss:(UIBarButtonItem *)sender;
- (IBAction)filter:(UIBarButtonItem *)sender;
- (IBAction)refresh:(UIBarButtonItem *)sender;
@property (strong, nonatomic) UIPickerView *picker;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSMutableArray *indexPathsShouldDisplayDetailArray;
@property (strong, nonatomic) NSMutableDictionary *urlSessionDic;
@property (strong, nonatomic) NSMutableDictionary *bookDownloadProgesssDic;

@end

@implementation BooksViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Books";
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = 44.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;

    self.managedObjectContext = ((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;
    self.indexPathsShouldDisplayDetailArray = [[NSMutableArray alloc] init];
    [self configureFetchedResultsController];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.bookDownloadProgesssDic = [Book bookDownloadProgesssDicInManagedObjectContext:self.managedObjectContext];
    NSTimeInterval interval = [[Preference lastRefreshCatalogueTime] timeIntervalSinceNow];
    if (interval < -60 * 60) {
        [self fetchBookData];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    for (NSString *idString in [self.bookDownloadProgesssDic allKeys]) {
        Book *book = [Book bookWithBookIDString:idString inManagedObjectContext:self.managedObjectContext];
        book.downloadProgress = [self.bookDownloadProgesssDic objectForKey:idString];
    }
    [[ZimMultiReader sharedInstance] updateZimReaderArray];
}

- (void)fetchBookData {
    [Book deleteAllBooksNonLocalInManagedObjectContext:self.managedObjectContext];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSString *catalogueURLString = @"http://www.kiwix.org/library.xml";
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:[NSURL URLWithString:catalogueURLString] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [Preference setLastRefreshCatalogueTime:[NSDate date]];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray *result = [Parser arrayOfBookMetadataFromData:data];
            [Book bookMetadataToCoreDataWithMetadataArray:result inManagedObjectContext:self.managedObjectContext];
        });
    }] resume];
}
- (void)configureFetchedResultsController {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Book"];
    NSSortDescriptor *langDescriptor = [[NSSortDescriptor alloc] initWithKey:@"language" ascending:YES];
    NSSortDescriptor *titleDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
    NSArray *sortDescriptors = @[langDescriptor, titleDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"language" cacheName:nil];
    self.fetchedResultsController.delegate = self;
    
    NSError *error;
    [self.fetchedResultsController performFetch:&error];
}

- (NSMutableDictionary *)urlSessionDic {
    if (!_urlSessionDic) {
        _urlSessionDic = [[NSMutableDictionary alloc] init];
    }
    return _urlSessionDic;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[[self fetchedResultsController] sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([[self.fetchedResultsController sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        return [sectionInfo numberOfObjects];
    } else
        return 0;
}

- (BookTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BookTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"BookCell"];
    
    [self configureCell:cell atIndexPath:indexPath animated:NO];
    
    return cell;
}

- (void)configureCell:(BookTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated {
    Book *book = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    UIImage *image = [UIImage imageWithData:book.favIcon];
    cell.favIcon.image = image;
    cell.titleLabel.text = book.title;
    NSString *fileSizeFormatted = [NSByteCountFormatter stringFromByteCount:[book.fileSize longLongValue]*1000 countStyle:NSByteCountFormatterCountStyleFile];
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    dateFormater.dateFormat = @"MM-dd-yyyy";
    dateFormater.dateStyle = NSDateFormatterMediumStyle;
    NSString *fileDateFormatted = [dateFormater stringFromDate:book.date];
    NSString *detailString = [NSString stringWithFormat:@"%@, %@", fileDateFormatted, fileSizeFormatted];
    if ([self.indexPathsShouldDisplayDetailArray containsObject:indexPath]) {
        NSString *additionalDetailString = [NSString stringWithFormat:@"\n%@\nCreator: %@  Publisher: %@", book.desc, book.creator, book.publisher];
        detailString = [detailString stringByAppendingString:additionalDetailString];
    }
    cell.detailLabel.text = detailString;
    cell.delegate = self;
    cell.indexPath = indexPath;
    
    NSNumber *progress = [self.bookDownloadProgesssDic objectForKey:book.idString];
    if (!progress) { //Book is not downloading, is not local/finished downloading
        [cell setState:AccessoryViewStateOriginal animated:animated withProgress:0.0];
    } else if ([progress isEqualToNumber:[NSNumber numberWithFloat:1.0]]) { // Book finished downloading
        [cell setState:AccessoryViewStateFinished animated:animated withProgress:1.0];
    } else { // Book is downloading, but not finished, should stop downloading and return to original
        [cell setState:AccessoryViewStateInProgress animated:animated withProgress:[progress floatValue]];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *sectionName = [[[self.fetchedResultsController sections] objectAtIndex:section] name];
    return sectionName;
}

- (NSArray *) sectionIndexTitlesForTableView: (UITableView *) tableView {
    return [self.fetchedResultsController sectionIndexTitles];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
}

#pragma mark - TableView Delagate 
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.indexPathsShouldDisplayDetailArray containsObject:indexPath]) {
        [self.indexPathsShouldDisplayDetailArray removeObject:indexPath];
    } else {
        [self.indexPathsShouldDisplayDetailArray addObject:indexPath];
    }
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - BookTableViewCellDelagate
- (void)didTapAccessoryViewAtIndexPath:(NSIndexPath *)indexPath {
    Book *book = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSNumber *progress = [self.bookDownloadProgesssDic objectForKey:book.idString];
    if (!progress) { //Book is not downloading, is not local/finished downloading, should start download
        [self startDownloadBook:book];
        [self.bookDownloadProgesssDic setObject:[NSNumber numberWithFloat:0.0] forKey:book.idString];
    } else if ([progress isEqualToNumber:[NSNumber numberWithFloat:1.0]]) { // Book finished downloading, is trying to delete
        [self deleteBook:book];
        [self.bookDownloadProgesssDic removeObjectForKey:book.idString];
    } else { // Book is downloading, but not finished, should stop downloading and return to original
        [self cancelDownloadBook:book];
        [self.bookDownloadProgesssDic removeObjectForKey:book.idString];
    }
    BookTableViewCell *cell = (BookTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath animated:YES];
}

#pragma mark - Downloader 
- (void)startDownloadBook:(Book *)book {
    NSString *identifier = book.idString;
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:identifier];
    configuration.timeoutIntervalForRequest = 15.0;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    NSString *urlString = [book.meta4URL stringByReplacingOccurrencesOfString:@".meta4" withString:@""];
    NSURLSessionDownloadTask *task = [session downloadTaskWithURL:[NSURL URLWithString:urlString]];
    [task resume];
    [self.urlSessionDic setObject:session forKey:book.idString];
}

- (void)cancelDownloadBook:(Book *)book {
    NSString *idString = book.idString;
    NSURLSession *session = [self.urlSessionDic objectForKey:idString];
    [session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        NSURLSessionDownloadTask *task = [downloadTasks firstObject];
        [task cancel];
    }];
    [self.urlSessionDic removeObjectForKey:idString];
    book.downloadProgress = nil;
}

- (void)deleteBook:(Book *)book {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSURL *fileLocation = [[File docDirURL] URLByAppendingPathComponent:[Book fileNameOfBook:book]];
    [fileManager removeItemAtURL:fileLocation error:&error];
    if (error) {
        //Handle error
    }
    book.downloadProgress = nil;
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    NSString *idString = session.configuration.identifier;
    CGFloat progress = 1.0*totalBytesWritten/totalBytesExpectedToWrite;
    Book *book = [Book bookWithBookIDString:idString inManagedObjectContext:self.managedObjectContext];
    NSIndexPath *indexPath = [self.fetchedResultsController indexPathForObject:book];
    BookTableViewCell *cell = (BookTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    [self.bookDownloadProgesssDic setObject:[NSNumber numberWithFloat:progress] forKey:idString];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self configureCell:cell atIndexPath:indexPath animated:YES];
    });
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    NSString *idString = session.configuration.identifier;
    Book *book = [Book bookWithBookIDString:idString inManagedObjectContext:self.managedObjectContext];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSURL *targetLocation = [[File docDirURL] URLByAppendingPathComponent:[Book fileNameOfBook:book]];
    [fileManager moveItemAtURL:location toURL:targetLocation error:&error];
    if (error) {
        // Handle Error
    }
    [session finishTasksAndInvalidate];
    [self.urlSessionDic removeObjectForKey:idString];
    [self.bookDownloadProgesssDic setObject:[NSNumber numberWithFloat:1.0] forKey:idString];
    NSIndexPath *indexPath = [self.fetchedResultsController indexPathForObject:book];
    BookTableViewCell *cell = (BookTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self configureCell:cell atIndexPath:indexPath animated:YES];
    });
}

#pragma mark - NSFetchedResultsControllerDelegate
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:(BookTableViewCell *)[tableView cellForRowAtIndexPath:indexPath]
                    atIndexPath:indexPath animated:NO];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)dismiss:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)filter:(UIBarButtonItem *)sender {
    if (sender.tag == 0) {
        if (!self.picker) {
            self.picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, PICKER_HEIGHT)];
            self.picker.delegate = self;
            self.picker.dataSource = self;
            self.picker.backgroundColor = [UIColor lightGrayColor];
        }
        
        [self.view addSubview:self.picker];
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
            CGFloat yDest = [UIScreen mainScreen].bounds.size.height - self.navigationController.toolbar.frame.size.height - PICKER_HEIGHT;
            self.picker.frame = CGRectMake(0, yDest, [UIScreen mainScreen].bounds.size.width, PICKER_HEIGHT);
        } completion:^(BOOL finished) {
            
        }];
        sender.tag = 1;
    } else {
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            CGFloat yDest = [UIScreen mainScreen].bounds.size.height;
            self.picker.frame = CGRectMake(0, yDest, [UIScreen mainScreen].bounds.size.width, PICKER_HEIGHT);
        } completion:^(BOOL finished) {
            
        }];
        sender.tag = 0;
    }
}

- (IBAction)refresh:(UIBarButtonItem *)sender {
    [self fetchBookData];
}
@end
