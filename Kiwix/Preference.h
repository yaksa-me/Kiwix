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

//+ (void)setLastReadArticleInfoWithBookIDString:(NSString *)bookIDString andArticleTitle:(NSString *)articleTitle;
//+ (NSString *)lastReadBookIDString;
//+ (NSString *)lastReadArticleTitle;
//+ (BOOL)hasLastReadArticleInfo;

+ (BOOL)isBackingUpFilesToiCloud;
+ (void)setIsBackingUpFilesToiCloud:(BOOL)backupState;

+ (BOOL)openLastReadWhenLunch;
+ (void)setOpenLastReadWhenLunch:(BOOL)mainPageLunchOpenState;

+ (NSUInteger)readingMode;
+ (void)setReadingMode:(NSUInteger)mode;

+ (NSUInteger)readingFontSize;
+ (void)setReadingFontSize:(NSUInteger)fontSize;

+ (NSDate *)lastRefreshCatalogueTime;
+ (void)setLastRefreshCatalogueTime:(NSDate *)date;

@end
