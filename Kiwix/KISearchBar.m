//
//  KISearchBar.m
//  Kiwix
//
//  Created by Chris Li on 3/15/15.
//  Copyright (c) 2015 Chris Li. All rights reserved.
//

#import "KISearchBar.h"

@interface KISearchBar ()

@property (strong, nonatomic) UITextField *searchTextField;
@property (strong, nonatomic) UIButton *cancelButton;

@end

@implementation KISearchBar

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // find textfield in subviews
    for (UIView *subView in self.subviews) {
        if ([subView.class isSubclassOfClass:[UITextField class]]) {
            self.searchTextField = (UITextField *)subView;
        }
    }
}

- (void)setFrame:(CGRect)frame {
    frame.size.height = 10;
    [super setFrame:frame];
}

@end
