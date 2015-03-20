//
//  Browser.h
//  Kiwix
//
//  Created by Chris Li on 3/4/15.
//  Copyright (c) 2015 Chris Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Book.h"
#import "Article.h"

@interface Browser : UIViewController <UIWebViewDelegate, UIScrollViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate>

@property (strong, nonatomic) Article *article;

@end
