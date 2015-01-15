//
//  Book+Create.h
//  Kiwix
//
//  Created by Chris Li on 1/11/15.
//  Copyright (c) 2015 Chris Li. All rights reserved.
//

#import "Book.h"

@interface Book (Create)

+ (Book *)bookWithReaderInfo:(NSDictionary *)infoDictionary inManagedObjectContext:(NSManagedObjectContext *)context;
+ (Book *)bookWithBookIDNumber:(NSString *)idNumber inManagedObjectContext:(NSManagedObjectContext *)context;

@end
