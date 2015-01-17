//
//  Article+Create.h
//  Kiwix
//
//  Created by Chris Li on 1/11/15.
//  Copyright (c) 2015 Chris Li. All rights reserved.
//

#import "Article.h"

@interface Article (Create)

+ (Article *)articleWithTitle:(NSString *)title andBookIDString:(NSString *)idString inManagedObjectContext:(NSManagedObjectContext *)context;
+ (void)insertArticleWithTitle:(NSString *)title andBookIDString:(NSString *)idString inManagedObjectContext:(NSManagedObjectContext *)context;

@end
