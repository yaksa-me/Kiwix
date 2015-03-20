//
//  KISearchBar.h
//  Kiwix
//
//  Created by Chris Li on 3/15/15.
//  Copyright (c) 2015 Chris Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KISearchBar : UISearchBar

// Called from The SearchDisplayController Delegate
- (void)showCancelButton:(BOOL)show;
- (void)cancelSearchField;

@end
