//
//  NSURL+KiwixURLProtocol.h
//  Kiwix
//
//  Created by Chris Li on 1/19/15.
//  Copyright (c) 2015 Chris Li. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (KiwixURLProtocol)

+ (instancetype)kiwixURLWithZIMFileIDString:(NSString *)idString contentURLString:(NSString *)contentURLString;
- (NSString *)zimFileID;
- (NSString *)contentURLString;
- (NSString *)expectedMIMEType;

@end
