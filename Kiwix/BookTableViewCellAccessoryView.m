//
//  BookTableViewCellAccessoryView.m
//  Kiwix
//
//  Created by Chris Li on 4/6/15.
//  Copyright (c) 2015 Chris Li. All rights reserved.
//

#import "BookTableViewCellAccessoryView.h"

@implementation BookTableViewCellAccessoryView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect frame = CGRectInset(self.bounds, -5, -5);
    return CGRectContainsPoint(frame, point) ? self : nil;
}

@end
