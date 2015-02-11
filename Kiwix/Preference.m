//
//  Preference.m
//  Kiwix
//
//  Created by Chris Li on 1/15/15.
//  Copyright (c) 2015 Chris Li. All rights reserved.
//

#import "Preference.h"
#import "zimFileFinder.h"

#define OPENING_BOOK @"Opening_Book"
#define OPENING_BOOK_ID @"Opening_Book_ID"
#define OPENING_BOOK_ARTICLE_COUNT @"openingBookArticleCount"

#define IS_BACKINGUP_FILES_TO_ICLOUD @"isBackingUpFilesToiCloud"
#define OPEN_LAST_READ_WHEN_LUNCH @"openLastReadWhenLunch"

#define READING_MODE @"readingMode"

@implementation Preference

+ (BOOL)isFirstLunch {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"isFirstLunch"]) {
        return NO;
    } else {
        return YES;
    }
}

+ (void)initializeUserDefaults {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:NO forKey:@"isFirstLunch"];
    [defaults setInteger:1 forKey:@"currentMenuIndex"];
    [defaults setBool:NO forKey:IS_BACKINGUP_FILES_TO_ICLOUD];
    [defaults removeObjectForKey:OPENING_BOOK];
    [defaults synchronize];
}

#pragma mark - Current Menu Index
+ (void)setCurrentMenuIndex:(NSUInteger)index {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:index forKey:@"currentMenuIndex"];
    [defaults synchronize];
}

+ (NSUInteger)currentMenuIndex {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSUInteger index = [defaults integerForKey:@"currentMenuIndex"];
    return index;
}

#pragma mark - Book Opening Info
+ (void)setOpeningBookID:(NSString *)idString andOpeningBookArticleCount:(NSUInteger)count{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *openingBookInfo = [[NSMutableDictionary alloc] init];
    [openingBookInfo setObject:idString forKey:OPENING_BOOK_ID];
    [openingBookInfo setObject:[NSNumber numberWithUnsignedInt:count] forKey:OPENING_BOOK_ARTICLE_COUNT];
    [defaults setObject:openingBookInfo forKey:OPENING_BOOK];
    [defaults synchronize];
}
+ (NSString *)openingBookID {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *openingBookInfo = [defaults objectForKey:OPENING_BOOK];
    NSString *openingBookID = [openingBookInfo objectForKey:OPENING_BOOK_ID];
    return openingBookID;
}

+ (NSUInteger)openingBookArticleCount {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *openingBookInfo = [defaults objectForKey:OPENING_BOOK];
    NSUInteger openingBookArticleCount = [[openingBookInfo objectForKey:OPENING_BOOK_ARTICLE_COUNT] integerValue];
    return openingBookArticleCount;
}

+ (BOOL)hasOpeningBook {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:OPENING_BOOK]) {
        return YES;
    } else {
        return NO;
    }
}

+ (void)noLongerHasAnOpeningBook {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:OPENING_BOOK];
    [defaults synchronize];
}

#pragma mark - last read article info
+ (void)setLastReadArticleInfoWithBookIDString:(NSString *)bookIDString andArticleTitle:(NSString *)articleTitle {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *lastReadArticleInfo = [[NSMutableDictionary alloc] init];
    [lastReadArticleInfo setObject:bookIDString forKey:@"bookIDString"];
    [lastReadArticleInfo setObject:articleTitle forKey:@"articleTitle"];
    [defaults setObject:lastReadArticleInfo forKey:@"lastReadArticleInfo"];
    [defaults synchronize];
}

+ (NSString *)lastReadBookIDString {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *lastReadArticleInfo = [defaults objectForKey:@"lastReadArticleInfo"];
    NSString *bookIDString = [lastReadArticleInfo objectForKey:@"bookIDString"];
    return bookIDString;
}

+ (NSString *)lastReadArticleTitle {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *lastReadArticleInfo = [defaults objectForKey:@"lastReadArticleInfo"];
    NSString *articleTitle = [lastReadArticleInfo objectForKey:@"articleTitle"];
    return articleTitle;
}

+ (BOOL)hasLastReadArticleInfo {
    if ([self lastReadArticleTitle]) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - settings
+ (BOOL)isBackingUpFilesToiCloud {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults objectForKey:IS_BACKINGUP_FILES_TO_ICLOUD]) {
        [defaults setBool:NO forKey:IS_BACKINGUP_FILES_TO_ICLOUD];
        [defaults synchronize];
    }
    return [[defaults objectForKey:IS_BACKINGUP_FILES_TO_ICLOUD] boolValue];
}

+ (void)setIsBackingUpFilesToiCloud:(BOOL)backupState {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:backupState forKey:IS_BACKINGUP_FILES_TO_ICLOUD];
    [defaults synchronize];
}

#pragma mark - Open Last Read When Lunch
+ (BOOL)openLastReadWhenLunch {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults boolForKey:OPEN_LAST_READ_WHEN_LUNCH]) {
        [defaults setBool:NO forKey:OPEN_LAST_READ_WHEN_LUNCH];
        [defaults synchronize];
    }
    return [defaults boolForKey:OPEN_LAST_READ_WHEN_LUNCH];
}

+ (void)setOpenLastReadWhenLunch:(BOOL)mainPageLunchOpenState {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:mainPageLunchOpenState forKey:OPEN_LAST_READ_WHEN_LUNCH];
    [defaults synchronize];
}

+ (NSUInteger)readingMode {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults integerForKey:READING_MODE]) {
        [defaults setInteger:0 forKey:READING_MODE];
        [defaults synchronize];
    }
    return [defaults integerForKey:READING_MODE];
}
+ (void)setReadingMode:(NSUInteger)mode {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:mode forKey:READING_MODE];
    [defaults synchronize];
}

@end
