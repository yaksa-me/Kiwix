//
//  FileInfoView.h
//  Kiwix
//
//  Created by Chris Li on 1/21/15.
//  Copyright (c) 2015 Chris Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FileInfoView : UIView

@property (weak, nonatomic) IBOutlet UILabel *bookTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOfArticleLabel;

@end
