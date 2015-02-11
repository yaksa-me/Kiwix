//
//  PopupView.h
//  Kiwix
//
//  Created by Chris Li on 1/29/15.
//  Copyright (c) 2015 Chris Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ToolMenuControl <NSObject>

- (void)fontSizeAdjustIncrease:(BOOL)isIncreasing;
- (void)readingModeChange:(NSUInteger)mode;

@end

@interface ToolMenuView : UIView <UIGestureRecognizerDelegate>

@property (weak) id <ToolMenuControl> delegate;

@end
