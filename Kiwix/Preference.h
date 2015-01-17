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

+ (void)setLastReadArticleInfoWithBookIDString:(NSString *)bookIDString andArticleTitle:(NSString *)articleTitle;
+ (NSString *)lastReadArticleIDString;
+ (NSString *)lastReadArticleTitle;

@end
