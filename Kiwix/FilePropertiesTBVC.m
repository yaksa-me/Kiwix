//
//  FilePropertiesTBVC.m
//  Kiwix
//
//  Created by Chris Li on 1/18/15.
//  Copyright (c) 2015 Chris Li. All rights reserved.
//

#import "FilePropertiesTBVC.h"
#import "CoreDataTask.h"
#import "Book.h"
#import "AppDelegate.h"

@interface FilePropertiesTBVC ()

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) Book *book;
@property (strong, nonatomic) NSArray *propertyNameA;
@property (strong, nonatomic) NSMutableArray *propertyValueA;

@end

@implementation FilePropertiesTBVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.managedObjectContext = ((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;
    //self.book = [[CoreDataTask openingBooksInManagedObjectContext:self.managedObjectContext] firstObject];
    
    self.propertyNameA = @[@"Title", @"Language", @"Date", @"Creator", @"Publisher"];
    self.propertyValueA = [[NSMutableArray alloc] init];
    [self.propertyValueA addObject:self.book.title];
    [self.propertyValueA addObject:self.book.language];
    [self.propertyValueA addObject:self.book.date];
    [self.propertyValueA addObject:self.book.creator];
    [self.propertyValueA addObject:self.book.publisher];
    
    
    //View setup
    self.title = @"Properties";
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
    if (section == 0) {
        return [self.propertyValueA count];
    } else {
        return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FilePropertiesDetailCell" forIndexPath:indexPath];
    
    if (indexPath.section == 0) {
        NSString *property = [self.propertyNameA objectAtIndex:indexPath.row];
        if ([property isEqual:@"Date"]) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"yyyy-MM-dd";
            NSDate *propertyValue = [self.propertyValueA objectAtIndex:indexPath.row];
            NSString *dateString = [dateFormatter stringFromDate:propertyValue];
            
            cell.textLabel.text = property;
            cell.detailTextLabel.text = dateString;
        } else {
            NSString *propertyValue = [self.propertyValueA objectAtIndex:indexPath.row];
            cell.textLabel.text = property;
            cell.detailTextLabel.text = propertyValue;
        }
    }
    
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return self.book.fileName;
    } else {
        return @"";
    }
}

#pragma mark - Table View Delegate
-(void)viewDidLayoutSubviews {
    [self.tableView headerViewForSection:0].textLabel.textAlignment = NSTextAlignmentCenter;
}
@end
