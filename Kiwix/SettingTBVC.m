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
#import "FileCoordinator.h"
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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.openingBook = [[CoreDataTask openingBooksInManagedObjectContext:self.managedObjectContext] firstObject];
    [self.tableView reloadData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        //File choosing cell
        if (self.openingBook) {
            return 2;
        } else {
            return 1;
        }
    } else if (section == 1) {
        return 1;
    } else {
        return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cellDefault = [tableView dequeueReusableCellWithIdentifier:@"SettingBasicCell"];
    
    if (indexPath.section == 0) {
        //File choosing cell
        if (indexPath.row == 0) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OpeningFileCell"];
            cell.textLabel.text = @"Open a zim file...";
            return cell;
        } else {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FilePropertiesCell"];
            cell.textLabel.text = @"File Properties";
            return cell;
        }
    } else if (indexPath.section == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"iCloudBackupCell"];
        UISwitch *swith = [[UISwitch alloc] initWithFrame:CGRectZero];
        [swith addTarget:self action:@selector(setiCloudBackupPreference:) forControlEvents:UIControlEventValueChanged];
        [swith setOn:[Preference isBackingUpFilesToiCloud]];
        cell.accessoryView = swith;
        cell.textLabel.text = @"Zim File Backup to iCloud";
        return cell;
    }
    return cellDefault;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *string;
    if (section == 0) {
        string = @"File";
    } else if (section == 1) {
        string = @"iCloud Backup";
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
    } else if (section == 1) {
        string = @"When turned off, none of your zim files will be backed up to iCloud. But your settings and reading history will still be backed up to iCloud.";
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowBookDetail"]) {
        FilePropertiesTBVC *destination = segue.destinationViewController;
        destination.book = self.openingBook;
    }
}


#pragma mark - Slide Menu Delegation
- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}

#pragma mark - Target actions
- (void)setiCloudBackupPreference:(UISwitch *)backupStateSwitch {
    if (backupStateSwitch.on) {
        //should backup to iCloud
        [FileCoordinator removeNoiCloudBackupAttributeFromAllZimFilesInLibraryDir];
        [Preference setIsBackingUpFilesToiCloud:YES];
    } else {
        //should not backup to iCloud
        [FileCoordinator addNoiCloudBackupAttributeToAllZimFilesInLibraryDir];
        [Preference setIsBackingUpFilesToiCloud:NO];
    }
}

@end
