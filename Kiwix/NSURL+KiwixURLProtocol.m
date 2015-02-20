//
//  NSURL+KiwixURLProtocol.m
//  Kiwix
//
//  Created by Chris Li on 1/19/15.
//  Copyright (c) 2015 Chris Li. All rights reserved.
//

#import "NSURL+KiwixURLProtocol.h"
#import "zimFileFinder.h"
#import <MobileCoreServices/MobileCoreServices.h>

@implementation NSURL (KiwixURLProtocol)

// encoder
+ (instancetype)kiwixURLWithZIMFileIDString:(NSString *)idString articleURL:(NSString *)articleURL {
    NSURL *zimFileURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@", @"kiwix", idString]];
    articleURL = [articleURL stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    articleURL = [articleURL stringByReplacingOccurrencesOfString:@"!" withString:@"%21"];
    articleURL = [articleURL stringByReplacingOccurrencesOfString:@"#" withString:@"%23"];
    articleURL = [articleURL stringByReplacingOccurrencesOfString:@"$" withString:@"%24"];
    articleURL = [articleURL stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
    articleURL = [articleURL stringByReplacingOccurrencesOfString:@"–" withString:@"%E2%80%93"];
    NSURL *newURL = [NSURL URLWithString:articleURL relativeToURL:zimFileURL];
    return newURL;
}

////Decoder
- (NSURL *)zimFileURL {
    NSString *idString = [[self.host componentsSeparatedByString:@"/"] lastObject];
    NSURL *zimFileURL = [zimFileFinder zimFileURLInLibraryDirectoryFormFileID:idString];
    return zimFileURL;
}

- (NSString *)contentURLString {
    //NSLog(@"contentURLString is: %@", self.path);
    NSString *contentURLString = [self.path stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
    contentURLString = [contentURLString stringByReplacingOccurrencesOfString:@"%21" withString:@"!"];
    contentURLString = [contentURLString stringByReplacingOccurrencesOfString:@"%23" withString:@"#"];
    contentURLString = [contentURLString stringByReplacingOccurrencesOfString:@"%24" withString:@"$"];
    contentURLString = [contentURLString stringByReplacingOccurrencesOfString:@"%26" withString:@"&"];
    contentURLString = [contentURLString stringByReplacingOccurrencesOfString:@"%E2%80%93" withString:@"–"];
    return contentURLString;
}

// Infer the MIME type of the resource from itshttp://stackoverflow.com/a/9802467/452816 path extension
// Source:
- (NSString *)expectedMIMEType
{
    CFStringRef type = NULL;
    {
        CFStringRef pathExtension = (__bridge_retained CFStringRef)[[self contentURLString] pathExtension];
        
        type = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension, NULL);
        
        if (pathExtension != NULL) {
            CFRelease(pathExtension), pathExtension = NULL;
        }
    }
    
    NSString *MIMEType = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass(type, kUTTagClassMIMEType);
    
    if (type != NULL) {
        CFRelease(type), type = NULL;
    }
    
    return MIMEType;
}

@end
