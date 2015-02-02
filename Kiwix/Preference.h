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

//+ (void)setOpeningBookID:(NSString *)idString andOpeningBookArticleCount:(NSUInteger)count; //file name is renamed to be the same as file ID
//+ (NSString *)openingBookID;
//+ (NSUInteger)openingBookArticleCount;
//+ (BOOL)hasOpeningBook;
//+ (void)noLongerHasAnOpeningBook;

//+ (void)setLastReadArticleInfoWithBookIDString:(NSString *)bookIDString andArticleTitle:(NSString *)articleTitle;
//+ (NSString *)lastReadBookIDString;
//+ (NSString *)lastReadArticleTitle;
//+ (BOOL)hasLastReadArticleInfo;

+ (BOOL)isBackingUpFilesToiCloud;
+ (void)setIsBackingUpFilesToiCloud:(BOOL)backupState;

+ (BOOL)openLastReadWhenLunch;
+ (void)setOpenLastReadWhenLunch:(BOOL)mainPageLunchOpenState;


@end
