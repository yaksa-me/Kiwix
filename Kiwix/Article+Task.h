//
//  Article+Task.h
//  Kiwix
//
//  Created by Chris Li on 4/2/15.
//  Copyright (c) 2015 Chris Li. All rights reserved.
//

#import "Article.h"

@interface Article (Task)

+ (Article *)articleWithTitleInfo:(NSDictionary *)articleInfo andBook:(Book *)book inManagedObjectContext:(NSManagedObjectContext *)context;

+ (NSArray *)articlesHaveBeenReadInManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray *)articlesBookmarkedInManagedObjectContext:(NSManagedObjectContext *)context;

+ (void)deleteArticle:(Article *)article inManagedObjectContext:(NSManagedObjectContext *)context;
@end
