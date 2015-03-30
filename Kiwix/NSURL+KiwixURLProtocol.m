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
+ (instancetype)kiwixURLWithZIMFileIDString:(NSString *)idString articleString:(NSString *)articleString {
    NSURL *zimFileURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@", @"kiwix", idString]];
    articleString = [articleString stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    articleString = [articleString stringByReplacingOccurrencesOfString:@"!" withString:@"%21"];
    articleString = [articleString stringByReplacingOccurrencesOfString:@"#" withString:@"%23"];
    articleString = [articleString stringByReplacingOccurrencesOfString:@"$" withString:@"%24"];
    articleString = [articleString stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
    articleString = [articleString stringByReplacingOccurrencesOfString:@"–" withString:@"%E2%80%93"];
    NSURL *newURL = [NSURL URLWithString:articleString relativeToURL:zimFileURL];
    return newURL;
}

////Decoder
- (NSString *)zimFileID {
    NSString *idString = [[self.host componentsSeparatedByString:@"/"] lastObject];
    return idString;
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

// Infer the MIME type of the resource from its http://stackoverflow.com/a/9802467/452816 path extension
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
