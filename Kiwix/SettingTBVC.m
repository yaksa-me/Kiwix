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

@interface SettingTBVC ()

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

@implementation SettingTBVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.managedObjectContext = ((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
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
        //File choosing cell
        if ([Preference hasOpeningBook]) {
            return 2;
        } else {
            return 1;
        }
    } else {
        return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cellDefault = [tableView dequeueReusableCellWithIdentifier:@"SettingBasic"];
    
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
    }
    return cellDefault;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *string;
    if (section == 0) {
        string = @"File";
    }
    return string;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    NSString *string;
    if (section == 0) {
        if ([Preference hasOpeningBook]) {
            NSString *idString = [Preference openingBookID];
            Book *book = [CoreDataTask bookWithIDString:idString inManagedObjectContext:self.managedObjectContext];
            string = [NSString stringWithFormat:@"%@ is currently opened.", book.title];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Slide Menu Delegation
- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}

@end
