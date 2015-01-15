//
//  ArticleListTBVC.m
//  Kiwix
//
//  Created by Chris Li on 1/11/15.
//  Copyright (c) 2015 Chris Li. All rights reserved.
//

#import "ArticleListTBVC.h"
#import "ArticleVC.h"
#import "zimReader.h"
#import "Parser.h"

@interface ArticleListTBVC ()

@property(strong, nonatomic)NSURL *fileURL;
@property(strong, nonatomic)zimReader *reader;
@property(strong, nonatomic)NSArray *articleList;

@end

@implementation ArticleListTBVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirPath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    NSString *fileLocation = [documentDirPath stringByAppendingString:@"/"];
    fileLocation = [fileLocation stringByAppendingString:self.bookURLAppend];
    self.fileURL = [NSURL fileURLWithPath:fileLocation];
    
    self.reader = [[zimReader alloc] initWithZIMFileURL:self.fileURL];
    [self.reader searchSuggestionSmart:@"Boe"];
    
    self.title = [self.reader getTitle];
    self.articleList = [Parser tableOfContentFromTOCHTMLString:[self.reader htmlContentOfMainPage]];
    
    NSLog(@"%@", [self.reader getID]);
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
    return [self.articleList count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ArticleTitle" forIndexPath:indexPath];
    
    cell.textLabel.text = [self.articleList objectAtIndex:indexPath.row];
    
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


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"SelectArticleFromBook"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        ArticleVC *destination = [segue destinationViewController];
        destination.articleTitle = [self.articleList objectAtIndex:indexPath.row];
        destination.fileURL = self.fileURL;
    }
}


@end
