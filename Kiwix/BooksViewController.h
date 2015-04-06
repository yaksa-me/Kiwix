//
//  BooksViewController.h
//  Kiwix
//
//  Created by Chris Li on 4/4/15.
//  Copyright (c) 2015 Chris Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface BooksViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@end
