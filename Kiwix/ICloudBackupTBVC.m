//
//  ICloudBackupTBVC.m
//  Kiwix
//
//  Created by Chris Li on 2/17/15.
//  Copyright (c) 2015 Chris Li. All rights reserved.
//

#import "ICloudBackupTBVC.h"
#import "Preference.h"
#import "FileCoordinator.h"

@interface ICloudBackupTBVC ()

@end

@implementation ICloudBackupTBVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"iCloud Backup";
    self.navigationController.toolbarHidden = YES;
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, 20.0f)];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"iCloudBackupStatusCell" forIndexPath:indexPath];
    
     UISwitch *swith = [[UISwitch alloc] initWithFrame:CGRectZero];
     [swith addTarget:self action:@selector(setiCloudBackupPreference:) forControlEvents:UIControlEventValueChanged];
     [swith setOn:[Preference isBackingUpFilesToiCloud]];
     cell.accessoryView = swith;
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return @"When turned off, none of your zim files will be backed up to iCloud. But your settings and reading history will still be backed up to iCloud.";
    }
    return nil;
}

#pragma mark - Table View Delegate
-(void)viewDidLayoutSubviews {
    for (int section = 0; section < [self.tableView numberOfSections]; section++)
    {
        [self.tableView footerViewForSection:section].textLabel.textAlignment = NSTextAlignmentCenter;
    }
}

#pragma mark - Target Action
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
