//
//  Article.h
//  Kiwix
//
//  Created by Chris Li on 1/14/15.
//  Copyright (c) 2015 Chris Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Book;

@interface Article : NSManagedObject

@property (nonatomic, retain) NSString * htmlContent;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * lastRead;
@property (nonatomic, retain) NSNumber * isBookmarked;
@property (nonatomic, retain) NSNumber * hasRead;
@property (nonatomic, retain) Book *belongsToBook;

@end
