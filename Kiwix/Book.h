//
//  Book.h
//  Kiwix
//
//  Created by Chris Li on 4/4/15.
//  Copyright (c) 2015 Chris Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Article;

@interface Book : NSManagedObject

@property (nonatomic, retain) NSNumber * articleCount;
@property (nonatomic, retain) NSString * creator;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSNumber * downloadProgress;
@property (nonatomic, retain) NSData * favIcon;
@property (nonatomic, retain) NSString * fileName;
@property (nonatomic, retain) NSNumber * fileSize;
@property (nonatomic, retain) NSNumber * globalCount;
@property (nonatomic, retain) NSString * idString;
@property (nonatomic, retain) NSNumber * isDownloading;
@property (nonatomic, retain) NSNumber * isLocal;
@property (nonatomic, retain) NSString * language;
@property (nonatomic, retain) NSNumber * mediaCount;
@property (nonatomic, retain) NSString * publisher;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * meta4URL;
@property (nonatomic, retain) NSSet *hasArticles;
@end

@interface Book (CoreDataGeneratedAccessors)

- (void)addHasArticlesObject:(Article *)value;
- (void)removeHasArticlesObject:(Article *)value;
- (void)addHasArticles:(NSSet *)values;
- (void)removeHasArticles:(NSSet *)values;

@end
