//
//  Article.h
//  Kiwix
//
//  Created by Chris Li on 4/4/15.
//  Copyright (c) 2015 Chris Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Book;

@interface Article : NSManagedObject

@property (nonatomic, retain) NSNumber * isBookmarked;
@property (nonatomic, retain) NSNumber * lastPosition;
@property (nonatomic, retain) NSDate * lastReadDate;
@property (nonatomic, retain) NSString * relativeURL;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) Book *belongsToBook;

@end
