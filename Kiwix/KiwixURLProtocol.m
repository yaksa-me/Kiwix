//
//  KiwixURLProtocol.m
//  Kiwix
//
//  Created by Chris Li on 1/19/15.
//  Copyright (c) 2015 Chris Li. All rights reserved.
//

#import "KiwixURLProtocol.h"
#import "NSURL+KiwixURLProtocol.h"
#import "zimReader.h"
#import <UIKit/UIKit.h>

@implementation KiwixURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    static NSUInteger requestCount = 0;
    NSLog(@"Request #%u: URL = %@", requestCount++, request.URL.absoluteString);
    
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
    
    zimReader *reader = [[zimReader alloc] initWithZIMFileURL:[requestURL zimFileURL]];
    NSString *htmlString = [reader htmlContentOfPageWithPageURL:[requestURL articleURL]];
    if ([[requestURL pathExtension] caseInsensitiveCompare:@"html"] == NSOrderedSame) {
        NSRange range = [htmlString rangeOfString:@"<body"];
        
        if(range.location != NSNotFound) {
            // Adjust style for mobile
            float inset = 40;
            NSString *style = [NSString stringWithFormat:@"<style>div {max-width: %fpx;}</style>", 320 - inset];
            htmlString = [NSString stringWithFormat:@"%@%@%@", [htmlString substringToIndex:range.location], style, [htmlString substringFromIndex:range.location]];
            //NSLog(@"%@", htmlString);
        }
    }
    
    if ([[requestURL pathExtension] caseInsensitiveCompare:@"css"] == NSOrderedSame) {
        NSLog(@"%@", htmlString);
    }
    NSData *htmlData = [htmlString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURLResponse *response = [[NSURLResponse alloc] initWithURL:requestURL MIMEType:[requestURL expectedMIMEType] expectedContentLength:[htmlData length] textEncodingName:nil];
    
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
    if (htmlData) {
        [self.client URLProtocol:self didLoadData:htmlData];
        [self.client URLProtocolDidFinishLoading:self];
    } else {
        [self.client URLProtocol:self didFailWithError:[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil]];
    }
}

- (void)stopLoading
{
    return;
}

@end
