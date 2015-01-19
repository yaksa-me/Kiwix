//
//  Preference.m
//  Kiwix
//
//  Created by Chris Li on 1/15/15.
//  Copyright (c) 2015 Chris Li. All rights reserved.
//

#import "Preference.h"
#import "zimFileFinder.h"

#define OPENINING_BOOK @"Opening_Book"
#define OPENINING_BOOK_ID @"Opening_Book_ID"

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
}

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
+ (void)setOpeningBookID:(NSString *)idString {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *openingBookInfo = [[NSMutableDictionary alloc] init];
    [openingBookInfo setObject:idString forKey:OPENINING_BOOK_ID];
    [defaults setObject:openingBookInfo forKey:OPENINING_BOOK];
    [defaults synchronize];
}
+ (NSString *)openingBookID {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *openingBookInfo = [defaults objectForKey:OPENINING_BOOK];
    NSString *openingBookID = [openingBookInfo objectForKey:OPENINING_BOOK_ID];
    return openingBookID;
}

+ (BOOL)hasOpeningBook {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:OPENINING_BOOK]) {
        return YES;
    } else {
        return NO;
    }
}

+ (void)noLongerHasAnOpeningBook {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:OPENINING_BOOK];
    [defaults synchronize];
}

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

@end
