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

#define PICKER_HEIGHT 162

@interface BooksViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)dismiss:(UIBarButtonItem *)sender;
- (IBAction)filter:(UIBarButtonItem *)sender;
@property (strong, nonatomic) UIPickerView *picker;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSMutableDictionary *pickerDataDictionary;

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
    self.pickerDataDictionary = [[NSMutableDictionary alloc] init];
    
    [self configureFetchedResultsController];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSTimeInterval interval = [[Preference lastRefreshCatalogueTime] timeIntervalSinceNow];
    if (interval < -60 *60) {
        [self fetchBookData];
    }
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSLog(@"%d", [[[self fetchedResultsController] sections] count]);
    return [[[self fetchedResultsController] sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([[self.fetchedResultsController sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        return [sectionInfo numberOfObjects];
    } else
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"BookCell"];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Book *book = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = book.title;
    cell.detailTextLabel.text = book.desc;
    UIImage *image = [UIImage imageWithData:book.favIcon];
    cell.imageView.image = image;
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
            
        case NSFetchedResultsChangeUpdate:/*
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath]
                    atIndexPath:indexPath];*/
            [tableView reloadRowsAtIndexPaths:@[indexPath]
                             withRowAnimation:UITableViewRowAnimationAutomatic];
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

#pragma mark - PickerViewDataSource
- (int)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return self.pickerDataDictionary.allKeys.count;
}

- (int)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSArray *keys = @[BOOK_LANGUAGE];
    NSArray *values = [self.pickerDataDictionary objectForKey:[keys objectAtIndex:component]];
    return values.count;
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSArray *keys = @[BOOK_LANGUAGE];
    NSArray *values = [self.pickerDataDictionary objectForKey:[keys objectAtIndex:component]];
    return [values objectAtIndex:row];
}

#pragma mark - PickerViewDelegate 
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
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
@end
