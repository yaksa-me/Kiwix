//
//  zimReader.m
//  KiwixTest
//
//  Created by Chris Li on 8/1/14.
//  Copyright (c) 2014 Chris. All rights reserved.
//

#import "zimReader.h"
#include "reader.h"

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

- (NSString *)htmlContentOfPageWithPageURL:(NSString *)pageURL {
    NSString *htmlContent = nil;
    
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

- (NSString *)searchSuggestionSmart:(NSString *)searchTerm {
    string str = [searchTerm cStringUsingEncoding:NSUTF8StringEncoding];
    int count;
    if(_reader->searchSuggestionsSmart(str, count)) {
        NSLog(@"%s, %d", str.c_str(), count);
        return [NSString stringWithUTF8String:str.c_str()];
    }
    return nil;
}

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

- (NSUInteger)getArticleCount {
    return _reader->getArticleCount();
}

- (NSUInteger)getMediaCount {
    return _reader->getMediaCount();
}

- (NSUInteger)getGlobalCount {
    return _reader->getGlobalCount();
}

- (void)dealloc {
    _reader->~Reader();
    //delete _reader;
    //should not call delete _reader; here since that will cause a error, probably because the instance of class Reader was deleted at the end of ~Reader();
}
@end
