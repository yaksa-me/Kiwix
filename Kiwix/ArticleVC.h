//
//  ArticleVC.h
//  Kiwix
//
//  Created by Chris Li on 1/11/15.
//  Copyright (c) 2015 Chris Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "zimReader.h"

@interface ArticleVC : UIViewController

@property(strong, nonatomic)NSString *articleTitle;
@property(strong, nonatomic)NSURL *fileURL;

@end
