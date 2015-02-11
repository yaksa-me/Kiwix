//
//  LoadingMessageView.h
//  Kiwix
//
//  Created by Chris Li on 2/1/15.
//  Copyright (c) 2015 Chris Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadingMessageView : UIView

@property (weak, nonatomic) IBOutlet UILabel *redirectMessage;
@property (weak, nonatomic) IBOutlet UILabel *articleTitle;
@property (weak, nonatomic) IBOutlet UILabel *loadingMessage;

@end
