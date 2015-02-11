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
- (NSString *)htmlContentOfPageWithPageURLString:(NSString *)pageURLString {
    NSString *htmlContent = nil;
    
    string pageURLC = [pageURLString cStringUsingEncoding:NSUTF8StringEncoding];

    string content;
    string contentType;
    unsigned int contentLength = 0;
    if (_reader->getContentByUrl(pageURLC, content, contentLength, contentType)) {
        htmlContent = [NSString stringWithUTF8String:content.c_str()];
    }
    //NSLog(@"URL passed to getContentByUrl(): %@, getDataLength: %lu",pageURLString, (unsigned long)[htmlContent length]);
    return htmlContent;
}

- (NSString *)htmlContentOfPageWithPagetitle:(NSString *)title {
    return [self htmlContentOfPageWithPageURLString:[self pageURLFromTitle:title]];
}

- (NSData *)dataWithContentOfMainPage {
    return [self dataWithContentURLString:[self mainPageURL]];
}

- (NSData *)dataWithContentURLString:(NSString *)pageURLString {
    NSData *contentData;
    
    string pageURLC = [pageURLString cStringUsingEncoding:NSUTF8StringEncoding];
    string content;
    string contentType;
    unsigned int contentLength = 0;
    if (_reader->getContentByUrl(pageURLC, content, contentLength, contentType)) {
        contentData = [NSData dataWithBytes:content.data() length:contentLength];
    }
    //NSLog(@"URL passed to getContentByUrl(): %@, getDataLength: %lu",pageURLString, (unsigned long)[contentData length]);
    return contentData;
}

- (NSData *)dataWithArticleTitle:(NSString *)title {
    return [self dataWithContentURLString:[self pageURLFromTitle:title]];
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




#pragma mark - getCounts
- (NSUInteger)getArticleCount {
    return _reader->getArticleCount();
}
- (NSUInteger)getMediaCount {
    return _reader->getMediaCount();
}
- (NSUInteger)getGlobalCount {
    return _reader->getGlobalCount();
}

#pragma mark - get File Attributes
- (NSString *)getID {
    NSString *idString = nil;
    
    string idStringC;
    idStringC = _reader->getId();
    idString = [NSString stringWithCString:idStringC.c_str() encoding:NSUTF8StringEncoding];
    
    return idString;
}
- (NSString *)getTitle {
    NSString *title = nil;
    
    string titleC;
    titleC = _reader->getTitle();
    title = [NSString stringWithCString:titleC.c_str() encoding:NSUTF8StringEncoding];
    
    return title;
}
- (NSString *)getDesc {
    NSString *description = nil;
    
    string descriptionC;
    descriptionC = _reader->getDescription();
    description = [NSString stringWithCString:descriptionC.c_str() encoding:NSUTF8StringEncoding];
    
    return description;
}
- (NSString *)getLanguage {
    NSString *language = nil;
    
    string languageC;
    languageC = _reader->getLanguage();
    language = [NSString stringWithCString:languageC.c_str() encoding:NSUTF8StringEncoding];
    
    return language;
}
- (NSDate *)getDate {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    
    string dateC;
    dateC = _reader->getDate();
    NSString *dateString = [NSString stringWithCString:dateC.c_str() encoding:NSUTF8StringEncoding];
    
    return [dateFormatter dateFromString:dateString];
}
- (NSString *)getCreator {
    NSString *creator = nil;
    
    string creatorC;
    creatorC = _reader->getCreator();
    creator = [NSString stringWithCString:creatorC.c_str() encoding:NSUTF8StringEncoding];
    
    return creator;
}
- (NSString *)getPublisher {
    NSString *publisher = nil;
    
    string publisherC;
    publisherC = _reader->getOrigId();
    publisher = [NSString stringWithCString:publisherC.c_str() encoding:NSUTF8StringEncoding];
    
    return publisher;
}
- (NSString *)getOriginID {
    NSString *originID = nil;
    
    string originIDC;
    originIDC = _reader->getOrigId();
    originID = [NSString stringWithCString:originIDC.c_str() encoding:NSUTF8StringEncoding];
    
    return originID;
}
- (NSUInteger)getFileSize {
    return _reader->getFileSize();
}
- (NSData *)getFavicon {
    NSData *faviconData;
    string content;
    string mimeType;
    if (_reader->getFavicon(content, mimeType)) {
        faviconData = [NSData dataWithBytes:content.data() length:content.length()];
    }
    return faviconData;
}


#pragma mark - dealloc
- (void)dealloc {
    _reader->~Reader();
    //delete _reader;
    //should not call delete _reader; here since that will cause a error, probably because the instance of class Reader was dealloced at the end of ~Reader();
}

- (void)exceptionHandling {
    try
    {
        throw 20;
    }
    catch (int e)
    {
        cout << "An exception occurred. Exception Nr. " << e << '\n';
    }
}
@end
