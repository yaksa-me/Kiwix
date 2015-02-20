//
//  CustomBarButtonItem.h
//  Kiwix
//
//  Created by Chris Li on 2/14/15.
//  Copyright (c) 2015 Chris Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomBarButtonItem : UIBarButtonItem

@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) UIImage *highlightedImage;
@property (strong, nonatomic) UIButton *button;
@property BOOL isHightlighted;

- (id)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage andCurrentState:(BOOL)state;
- (void)animateWithHighLightState:(BOOL)state; //State is the state that should be changed to 
    
@end
