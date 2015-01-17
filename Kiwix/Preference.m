//
//  Preference.m
//  Kiwix
//
//  Created by Chris Li on 1/15/15.
//  Copyright (c) 2015 Chris Li. All rights reserved.
//

#import "Preference.h"
#import "zimFileFinder.h"

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

+ (void)setLastReadArticleInfoWithBookIDString:(NSString *)bookIDString andArticleTitle:(NSString *)articleTitle {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *lastReadArticleInfo = [[NSMutableDictionary alloc] init];
    [lastReadArticleInfo setObject:bookIDString forKey:@"bookIDString"];
    [lastReadArticleInfo setObject:articleTitle forKey:@"articleTitle"];
    [defaults setObject:lastReadArticleInfo forKey:@"lastReadArticleInfo"];
    [defaults synchronize];
}

+ (NSString *)lastReadArticleIDString {
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
