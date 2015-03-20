//
//  CustomBarButtonItem.m
//  Kiwix
//
//  Created by Chris Li on 2/14/15.
//  Copyright (c) 2015 Chris Li. All rights reserved.
//

#import "CustomBarButtonItem.h"

@interface CustomBarButtonItem ()

@property (strong, nonatomic) UIImageView *imageView;

@end


@implementation CustomBarButtonItem

- (id)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage andCurrentState:(BOOL)state {
    self.image = image;
    self.highlightedImage = highlightedImage;
    self.isHightlighted = state;
    
    self.imageView = [[UIImageView alloc] init];
    if (state) {
        self.imageView.image = [self.highlightedImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    } else {
        self.imageView.image = [self.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    self.imageView.autoresizingMask = UIViewAutoresizingNone;
    self.imageView.contentMode = UIViewContentModeCenter;
    
    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    self.button.frame = CGRectMake(0, 0, 40, 40);
    [self.button addSubview:self.imageView];
    if (state) {
        self.button.tintColor = [UIColor redColor];
    } else {
        self.button.tintColor = nil;
    }
    
    self.imageView.center = self.button.center;
    
    self = [super initWithCustomView:self.button];
    
    return self;
}

- (id)initWithImage:(UIImage *)image andLabelText:(NSString *)labelText {
    self.image = image;
    self.imageView = [[UIImageView alloc] initWithImage:[self.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    self.imageView.autoresizingMask = UIViewAutoresizingNone;
    self.imageView.contentMode = UIViewContentModeCenter;
    
    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    self.button.frame = CGRectMake(0, 0, 40, 40);
    [self.button addSubview:self.imageView];
    
    self.imageView.center = self.button.center;
    
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    messageLabel.center = CGPointMake(self.button.center.x-2, self.button.center.y+2);
    messageLabel.text = labelText;
    messageLabel.textColor = [UIColor darkGrayColor];
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    [self.button addSubview:messageLabel];
    
    self.button.tintColor = [UIColor grayColor];;
    self = [super initWithCustomView:self.button];
    
    return self;
}

- (void)animateWithHighLightState:(BOOL)state {
    self.button.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        CATransform3D t = CATransform3DIdentity;
        t = CATransform3DRotate(t, 90.0f * M_PI / 180.0f, 0, 1, 0);
        self.imageView.layer.transform = t;
    } completion:^(BOOL finished) {
        if (state) {
            //Now is highlighted
            self.isHightlighted = YES;
            self.imageView.image = [self.highlightedImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            self.button.tintColor = [UIColor redColor];
        } else {
            self.isHightlighted = NO;
            self.imageView.image = [self.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            self.button.tintColor = nil;
        }
        
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
            CATransform3D t = CATransform3DIdentity;
            t = CATransform3DRotate(t, 180.0f * M_PI / 180.0f, 0, 1, 0);
            self.imageView.layer.transform = t;
        } completion:^(BOOL finished) {
            self.button.userInteractionEnabled = YES;
        }];
    }];
}

@end
