//
//  Article+Create.h
//  Kiwix
//
//  Created by Chris Li on 1/11/15.
//  Copyright (c) 2015 Chris Li. All rights reserved.
//

#import "Article.h"

@interface Article (Create)

+ (Article *)articleWithTitle:(NSString *)title andBookIDNumber:(NSString *)idNumber inManagedObjectContext:(NSManagedObjectContext *)context;
+ (void)insertArticleWithTitle:(NSString *)title andBookIDNumber:(NSString *)idNumber inManagedObjectContext:(NSManagedObjectContext *)context;

@end
