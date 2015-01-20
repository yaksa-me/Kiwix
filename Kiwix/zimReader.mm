//
//  zimReader.m
//  KiwixTest
//
//  Created by Chris Li on 8/1/14.
//  Copyright (c) 2014 Chris. All rights reserved.
//

#import "zimReader.h"
#include "reader.h"

#define SEARCH_SUGGESTIONS_COUNT 100

@interface zimReader () {
    kiwix::Reader *_reader;
}
@end

@implementation zimReader

- (instancetype)initWithZIMFileURL:(NSURL *)url {
    self = [super init];
    if (self) {
        _reader = new kiwix::Reader([url fileSystemRepresentation]);
    }
    
    return self;
}

#pragma mark - htmlContents
- (NSString *)htmlContentOfPageWithPageURL:(NSString *)pageURL {
    NSString *htmlContent = nil;
    //NSLog(@"URL passed to reader: %@",pageURL);
    
    string pageURLC = [pageURL cStringUsingEncoding:NSUTF8StringEncoding];
    string content;
    string contentType;
    unsigned int contentLength = 0;
    if (_reader->getContentByUrl(pageURLC, content, contentLength, contentType)) {
        htmlContent = [NSString stringWithUTF8String:content.c_str()];
    }
    
    return htmlContent;
}

- (NSString *)htmlContentOfPageWithPagetitle:(NSString *)title {
    return [self htmlContentOfPageWithPageURL:[self pageURLFromTitle:title]];
}

- (NSString *)htmlContentOfMainPage {
    return [self htmlContentOfPageWithPageURL:self.mainPageURL];
}

#pragma mark - getURLs
- (NSString *)pageURLFromTitle:(NSString *)title {
    NSString *pageURL = nil;
    
    string url;
    if (_reader->getPageUrlFromTitle([title cStringUsingEncoding:NSUTF8StringEncoding], url)) {
        pageURL = [NSString stringWithUTF8String:url.c_str()];
    }
    
    return pageURL;
}

- (NSString *)mainPageURL {
    NSString *mainPageURL = nil;
    
    string mainPageURLC;
    mainPageURLC = _reader->getMainPageUrl();
    mainPageURL = [NSString stringWithCString:mainPageURLC.c_str() encoding:NSUTF8StringEncoding];
    
    return mainPageURL;
}

- (NSString *)getRandomPageUrl {
    string url = _reader->getRandomPageUrl();
    return [NSString stringWithUTF8String:url.c_str()];
}

#pragma mark - search
- (NSArray *)searchSuggestionsSmart:(NSString *)searchTerm {
    string searchTermC = [searchTerm cStringUsingEncoding:NSUTF8StringEncoding];
    int count = SEARCH_SUGGESTIONS_COUNT;
    NSMutableArray *searchSuggestionsArray = [[NSMutableArray alloc] init];
    
    if(_reader->searchSuggestionsSmart(searchTermC, count)) {
        //NSLog(@"%s, %d", searchTermC.c_str(), count);
        string titleC;
        while (_reader->getNextSuggestion(titleC)) {
            NSString *title = [NSString stringWithUTF8String:titleC.c_str()];
            [searchSuggestionsArray addObject:title];
        }
    }
    return searchSuggestionsArray;
}

#pragma mark - getZimFileProperties
- (NSString *)getTitle {
    NSString *title = nil;
    
    string titleC;
    titleC = _reader->getTitle();
    title = [NSString stringWithCString:titleC.c_str() encoding:NSUTF8StringEncoding];
    
    return title;
}

- (NSString *)getDate {
    NSString *date = nil;
    
    string dateC;
    dateC = _reader->getDate();
    date = [NSString stringWithCString:dateC.c_str() encoding:NSUTF8StringEncoding];
    
    return date;
}

- (NSString *)getID {
    NSString *id = nil;
    
    string idC;
    idC = _reader->getId();
    id = [NSString stringWithCString:idC.c_str() encoding:NSUTF8StringEncoding];
    
    return id;
}

#pragma mark - getCount
- (NSUInteger)getArticleCount {
    return _reader->getArticleCount();
}

- (NSUInteger)getMediaCount {
    return _reader->getMediaCount();
}

- (NSUInteger)getGlobalCount {
    return _reader->getGlobalCount();
}

#pragma mark -
- (void)dealloc {
    _reader->~Reader();
    //delete _reader;
    //should not call delete _reader; here since that will cause a error, probably because the instance of class Reader was deleted at the end of ~Reader();
}
@end
