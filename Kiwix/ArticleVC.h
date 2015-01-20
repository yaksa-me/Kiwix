//
//  ArticleVC.h
//  Kiwix
//
//  Created by Chris Li on 1/11/15.
//  Copyright (c) 2015 Chris Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "zimReader.h"
#import "SlideNavigationController.h"

@interface ArticleVC : UIViewController <SlideNavigationControllerDelegate, UIWebViewDelegate>

@property (strong, nonatomic)NSString *articleTitle;
@property (strong, nonatomic)NSString *bookID;

@end
