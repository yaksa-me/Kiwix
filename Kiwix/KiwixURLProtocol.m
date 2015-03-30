//
//  KiwixURLProtocol.m
//  Kiwix
//
//  Created by Chris Li on 1/19/15.
//  Copyright (c) 2015 Chris Li. All rights reserved.
//

#import "KiwixURLProtocol.h"
#import "NSURL+KiwixURLProtocol.h"
#import "ZimMultiReader.h"
#import <UIKit/UIKit.h>

@implementation KiwixURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    //static NSUInteger requestCount = 0;
    //NSLog(@"Request #%u: URL = %@", requestCount++, request.URL.absoluteString);
    
    if ([[[request URL] scheme] caseInsensitiveCompare:@"Kiwix"] == NSOrderedSame) {
        return YES;
    }
    return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}

- (void)startLoading
{
    NSURL *requestURL = [self.request URL];
    NSData *contentData;
    
    if ([[requestURL path] containsString:@"(main)"]) {
        //contentData = [reader dataWithContentOfMainPage];
    } else {
        contentData = [[ZimMultiReader sharedInstance] dataWithZimFileID:[requestURL zimFileID] andContentURLString:[requestURL contentURLString]];
    }
    /*
    if ([[requestURL pathExtension] caseInsensitiveCompare:@"html"] == NSOrderedSame) {
        if ([[requestURL path] containsString:@"(null)"]) {
            contentData = [reader dataWithContentOfMainPage];
        } else {
            contentData = [reader dataWithContentURLString:[requestURL contentURLString]];
        }
    } else {
        contentData = [reader dataWithContentURLString:[requestURL contentURLString]];
    }*/
    
    NSURLResponse *response = [[NSURLResponse alloc] initWithURL:requestURL MIMEType:[requestURL expectedMIMEType] expectedContentLength:[contentData length] textEncodingName:nil];
    
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
    if (contentData) {
        //NSLog(@"Load %@ success, length: %ld", [requestURL contentURLString], (unsigned long)[contentData length]);
        [self.client URLProtocol:self didLoadData:contentData];
        [self.client URLProtocolDidFinishLoading:self];
    } else {
        //NSLog(@"Load %@ failed, length: %ld", [requestURL contentURLString], (unsigned long)[contentData length]);
        [self.client URLProtocol:self didFailWithError:[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil]];
    }
}

- (void)stopLoading
{
    return;
}

@end
