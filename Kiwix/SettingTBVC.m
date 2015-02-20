//
//  SettingTBVC.m
//  Kiwix
//
//  Created by Chris Li on 1/17/15.
//  Copyright (c) 2015 Chris Li. All rights reserved.
//

#import "SettingTBVC.h"
#import "Preference.h"
#import "CoreDataTask.h"
#import "AppDelegate.h"
#import "Book.h"
#import "FilePropertiesTBVC.h"

@interface SettingTBVC ()

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) Book *openingBook;

@end

@implementation SettingTBVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.managedObjectContext = ((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;
    self.navigationController.toolbarHidden = YES;
    self.title = @"Settings";
    
    self.navigationController.navigationBar.userInteractionEnabled = YES;
    self.navigationController.toolbar.userInteractionEnabled = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.openingBook = [[CoreDataTask openingBooksInManagedObjectContext:self.managedObjectContext] firstObject];
    [self.tableView reloadData];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 2;
        case 1:
            return 1;
        case 2:
            return 1;
        default:
            return 0;
            break;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cellDefault = [tableView dequeueReusableCellWithIdentifier:@"SettingBasicCell"];
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AllZimFilesCell"];
            cell.textLabel.text = @"All zim Files";
            return cell;
        } else if (indexPath.row == 1) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"iCloudBackupCell"];
            cell.textLabel.text = @"iCloud Backup";
            cell.detailTextLabel.text = [Preference isBackingUpFilesToiCloud] ? @"On" : @"Off";
            return cell;
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RememberLastReadPositionCell"];
            UISwitch *swith = [[UISwitch alloc] initWithFrame:CGRectZero];
            [swith addTarget:self action:@selector(setRememberLastReadingPositionPreference:) forControlEvents:UIControlEventValueChanged];
            [swith setOn:YES];
            cell.accessoryView = swith;
            cell.textLabel.text = @"Remember last read position";
            return cell;
        }
    } else if (indexPath.section == 2) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"About"];
        cell.textLabel.text = @"About";
        return cell;
    }
    return cellDefault;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *string;
    if (section == 0) {
        string = @"File";
    } else if (section == 1) {
        string = @"Reader";
    } else if (section == 2) {
        return @"Other";
    }
    return string;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    NSString *string;
    if (section == 0) {
        if (self.openingBook) {
            string = [NSString stringWithFormat:@"%@ is currently opened.", self.openingBook.title];
        } else {
            string = @"No Book is opened.";
        }
    }
    return string;
}

#pragma mark - Table View Delegate
-(void)viewDidLayoutSubviews {
    for (int section = 0; section < [self.tableView numberOfSections]; section++)
    {
        [self.tableView footerViewForSection:section].textLabel.textAlignment = NSTextAlignmentCenter;
    }
}

#pragma mark - Slide Menu Delegation
- (BOOL)slideNavigationControllerShouldDisplayLeftMenu {
    return YES;
}

#pragma mark - Target action
- (void)setRememberLastReadingPositionPreference:(UISwitch *)readingPositionRememberSwitch {
    
}

@end
