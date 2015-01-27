//
//  Book.h
//  Kiwix
//
//  Created by Chris Li on 1/23/15.
//  Copyright (c) 2015 Chris Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Article;

@interface Book : NSManagedObject

@property (nonatomic, retain) NSString * idString;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * fileName;
@property (nonatomic, retain) NSNumber * articleCount;
@property (nonatomic, retain) NSNumber * isOpening;
@property (nonatomic, retain) NSSet *hasArticles;
@end

@interface Book (CoreDataGeneratedAccessors)

- (void)addHasArticlesObject:(Article *)value;
- (void)removeHasArticlesObject:(Article *)value;
- (void)addHasArticles:(NSSet *)values;
- (void)removeHasArticles:(NSSet *)values;

@end
