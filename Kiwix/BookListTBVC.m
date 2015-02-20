//
//  BookListTBVC.m
//  Kiwix
//
//  Created by Chris Li on 2/19/15.
//  Copyright (c) 2015 Chris Li. All rights reserved.
//

#import "BookListTBVC.h"
#import "AppDelegate.h"
#import "Parser.h"

@interface BookListTBVC ()

@property (strong, nonatomic) NSArray *bookList; //Array of Dic with book Metadata
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;


@end

@implementation BookListTBVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Book List";
    self.navigationController.toolbarHidden = YES;
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, 0.00001f)];
    
    self.managedObjectContext = ((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;
    
    [self loadBookMetadataFromInternet];
    
}

- (void)loadBookMetadataFromInternet {
    NSURL *url = [NSURL URLWithString:@"http://www.kiwix.org/library.xml"];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.timeoutIntervalForRequest = 15.0;
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        self.bookList = [Parser arrayOfBookMetadataFromData:data];
        [self.tableView reloadData];
    }] resume];

}

#pragma mark - Slide Menu Delegation
- (BOOL)slideNavigationControllerShouldDisplayLeftMenu {
    return YES;
}

#pragma mark - UITableView Data Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.bookList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BookmarkArticleCell" forIndexPath:indexPath];
    
    NSDictionary *bookMetadata = [self.bookList objectAtIndex:indexPath.row];
    cell.textLabel.text = [bookMetadata objectForKey:@"title"];
    
    NSString *faviconString = [bookMetadata objectForKey:@"favicon"];
    if (faviconString) {
        NSData *faviconData = [[NSData alloc] initWithBase64EncodedString:faviconString options:NSDataBase64DecodingIgnoreUnknownCharacters];
        UIImage *favicon = [UIImage imageWithData:faviconData];
        cell.imageView.image = favicon;
        CGRect frame = cell.imageView.frame;
        frame.size.width = 10.0;
        cell.imageView.frame = frame;
        CGFloat scale = 1.2;
        cell.imageView.layer.contentsRect = CGRectMake((1-scale)/2, (1-scale)/2, scale, scale);
    }
    
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}
@end
