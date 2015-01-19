//
//  FilePropertiesTBVC.m
//  Kiwix
//
//  Created by Chris Li on 1/18/15.
//  Copyright (c) 2015 Chris Li. All rights reserved.
//

#import "FilePropertiesTBVC.h"
#import "Preference.h"
#import "zimFileFinder.h"
#import "zimReader.h"

@interface FilePropertiesTBVC ()

@property (strong, nonatomic) zimReader *reader;
@property (strong, nonatomic) NSArray *propertyNames;
@property (strong, nonatomic) NSMutableDictionary *propertyValues;

@end

@implementation FilePropertiesTBVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([Preference hasOpeningBook]) {
        NSString *zimFilePath = [zimFileFinder zimFilePathInAppSupportDirectoryFormFileID:[Preference openingBookID]];
        self.reader = [[zimReader alloc] initWithZIMFileURL:[NSURL fileURLWithPath:zimFilePath]];
    }
    
    self.propertyNames = @[@"Title", @"ID"];
    self.propertyValues = [[NSMutableDictionary alloc] init];
    [self.propertyValues setObject:[self.reader getTitle] forKey:@"Title"];
    [self.propertyValues setObject:[self.reader getID] forKey:@"ID"];
    
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
    return [self.propertyNames count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FilePropertiesDetailCell" forIndexPath:indexPath];
    
    NSString *propertyName = [self.propertyNames objectAtIndex:indexPath.row];
    cell.textLabel.text = propertyName;
    cell.detailTextLabel.text = [self.propertyValues objectForKey:propertyName];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
