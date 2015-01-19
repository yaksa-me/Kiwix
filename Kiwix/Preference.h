//
//  Preference.h
//  Kiwix
//
//  Created by Chris Li on 1/15/15.
//  Copyright (c) 2015 Chris Li. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Preference : NSObject

+ (BOOL)isFirstLunch;
+ (void)initializeUserDefaults;

+ (void)setCurrentMenuIndex:(NSUInteger)index;
+ (NSUInteger)currentMenuIndex;

+ (void)setOpeningBookID:(NSString *)idString; //file name is renamed to be the same as file ID
+ (NSString *)openingBookID;
+ (BOOL)hasOpeningBook;
+ (void)noLongerHasAnOpeningBook;


+ (void)setLastReadArticleInfoWithBookIDString:(NSString *)bookIDString andArticleTitle:(NSString *)articleTitle;
+ (NSString *)lastReadBookIDString;
+ (NSString *)lastReadArticleTitle;

@end
