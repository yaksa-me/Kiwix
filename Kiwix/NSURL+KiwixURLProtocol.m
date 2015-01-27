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

// Create a new URL by encoding archiveURL as the `host` and `entryFileName` as the `path`
+ (instancetype)kiwixURLWithZIMFileIDString:(NSString *)idString articleTitle:(NSString *)articleTitle
{
    NSString *articleURL = [articleTitle stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    articleURL = [NSString stringWithFormat:@"A/%@.html", articleURL];
    NSURL *newArchiveURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@", @"kiwix", idString]];
    NSURL *newURL = [NSURL URLWithString:articleURL relativeToURL:newArchiveURL];
    return newURL;
}

// Decode the zim file URL from the `host` property
- (NSURL *)zimFileURL {
    NSString *idString = [[self.host componentsSeparatedByString:@"/"] lastObject];
    NSURL *zimFileURL = [zimFileFinder zimFileURLInLibraryDirectoryFormFileID:idString];
    return zimFileURL;
}

// Decode the article name from the `path` property
- (NSString *)contentURLString {
    //NSLog(@"contentURLString is: %@", self.path);
    NSString *contentURLString = [self.path stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
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
