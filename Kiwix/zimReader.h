//
//  zimReader.h
//  KiwixTest
//
//  Created by Chris Li on 8/1/14.
//  Copyright (c) 2014 Chris. All rights reserved.
//
//  This is the wrapper class that converts all C++ functions in reader.h to Objective-C methods

#import <Foundation/Foundation.h>

@interface zimReader : NSObject 

- (instancetype)initWithZIMFileURL:(NSURL *)url;

- (NSString *)htmlContentOfPageWithPageURLString:(NSString *)pageURLString;//Will return nil if there is no page with that specific URL
- (NSString *)htmlContentOfPageWithPagetitle:(NSString *)title;
- (NSString *)htmlContentOfMainPage;
- (NSData *)dataWithContentURLString:(NSString *)pageURLString;
- (NSData *)dataWithArticleTitle:(NSString *)title;

- (NSString *)pageURLFromTitle:(NSString *)title;//Will return nil if there is no such page with the specific title
- (NSString *)mainPageURL;//Will return nil if the zim file have no main page, not sure if this will ever happen(Does every zim file have a main page?)
- (NSString *)getRandomPageUrl;

- (NSArray *)searchSuggestionsSmart:(NSString *)searchTerm;

- (NSString *)getTitle;
- (NSString *)getDate;
- (NSString *)getID;

- (NSUInteger)getArticleCount;
- (NSUInteger)getMediaCount;
- (NSUInteger)getGlobalCount;

- (void)dealloc;
- (void)exceptionHandling;


@end
