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
    
    NSURL *zimFileURL = [zimFileFinder zimFileURLInLibraryDirectoryFormFileID:self.book.idString];
    self.reader = [[zimReader alloc] initWithZIMFileURL:zimFileURL];
    
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

@end
