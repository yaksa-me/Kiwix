//
//  PopupView.m
//  Kiwix
//
//  Created by Chris Li on 1/29/15.
//  Copyright (c) 2015 Chris Li. All rights reserved.
//

#import "ToolMenuView.h"
#import <QuartzCore/QuartzCore.h>

@interface ToolMenuView ()


@property (weak, nonatomic) IBOutlet UIButton *dimButton;
@property (weak, nonatomic) IBOutlet UIButton *brightButton;
- (IBAction)dimBrightSlider:(UISlider *)sender;
@property (weak, nonatomic) IBOutlet UISlider *dimBrightSlider;
@property (weak, nonatomic) IBOutlet UIImageView *separaterA;
//@property (weak, nonatomic) IBOutlet UIImageView *separaterB;
@property (weak, nonatomic) IBOutlet UIButton *fontPlus;
@property (weak, nonatomic) IBOutlet UIButton *fontMinus;
- (IBAction)fontPlus:(UIButton *)sender;
- (IBAction)fontMinus:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIImageView *fontSeparater;
//@property (weak, nonatomic) IBOutlet UIButton *dayMode;
//- (IBAction)dayMode:(UIButton *)sender;




@end

@implementation ToolMenuView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    UIImage *image = [self imageWithColor:[[UIColor grayColor] colorWithAlphaComponent:0.125]];
    // Create a transparent view
    [self setBackgroundColor:[UIColor clearColor]];
    
    // Mask Path
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(10.0f, 10.0f)];
    
    // Create the shadow layer
    CAShapeLayer *shadowLayer = [CAShapeLayer layer];
    [shadowLayer setFrame:rect];
    [shadowLayer setMasksToBounds:NO];
    [shadowLayer setShadowPath:maskPath.CGPath];
    [shadowLayer setShadowColor:[UIColor blackColor].CGColor];
    [shadowLayer setShadowOffset:CGSizeMake(0.0f, 5.0f)];
    [shadowLayer setShadowOpacity:0.5f];
    [shadowLayer setBackgroundColor:(__bridge CGColorRef)([UIColor clearColor])];
    
    // Create the rounded layer, and mask it
    CALayer *roundedLayer = [CALayer layer];
    [roundedLayer setFrame:rect];
    [roundedLayer setContents:(id)image.CGImage];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    [maskLayer setFrame:rect];
    [maskLayer setPath:maskPath.CGPath];
    
    //roundedLayer.mask = maskLayer;
    self.layer.mask = maskLayer;
    
    // Add these two layers as sublayers to the view
    //[self.layer addSublayer:shadowLayer];
    [self.layer addSublayer:roundedLayer];
    
    [self bringSubviewToFront:self.dimButton];
    [self bringSubviewToFront:self.brightButton];
    [self bringSubviewToFront:self.dimBrightSlider];
    self.dimBrightSlider.value = [[UIScreen mainScreen] brightness];
    
    //[self bringSubviewToFront:self.separaterB];
    [self bringSubviewToFront:self.fontSeparater];
    [self bringSubviewToFront:self.fontPlus];
    [self bringSubviewToFront:self.fontMinus];
    //[self bringSubviewToFront:self.dayMode];
    
    CALayer *topBorderLayer = [CALayer layer];
    CGRect topBorderFrame = CGRectMake(0, 0, (self.separaterA.frame.size.width), 0.5);
    [topBorderLayer setBackgroundColor:[[UIColor grayColor] CGColor]];
    [topBorderLayer setFrame:topBorderFrame];
    [self.separaterA.layer addSublayer:topBorderLayer];
    CALayer *buttomBorderLayer = [CALayer layer];
    CGRect buttomBorderFrame = CGRectMake(0, self.separaterA.frame.size.height - 0.5, (self.separaterA.frame.size.width), 0.5);
    [buttomBorderLayer setBackgroundColor:[[UIColor grayColor] CGColor]];
    [buttomBorderLayer setFrame:buttomBorderFrame];
    [self.separaterA.layer addSublayer:buttomBorderLayer];
    [self bringSubviewToFront:self.separaterA];
    
}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 400, 400);
    // Create a 1 by 1 pixel context
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [color setFill];
    UIRectFill(rect);   // Fill it with your color
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (IBAction)dimBrightSlider:(UISlider *)sender {
    [[UIScreen mainScreen] setBrightness:sender.value];
}

- (IBAction)fontPlus:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(fontSizeAdjustIncrease:)]) {
        [self.delegate fontSizeAdjustIncrease:YES];
    }
}

- (IBAction)fontMinus:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(fontSizeAdjustIncrease:)]) {
        [self.delegate fontSizeAdjustIncrease:NO];
    }
}
- (IBAction)dayMode:(UIButton *)sender {
    [self.delegate readingModeChange:0];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGPoint touchPoint = [touch locationInView:self.superview];
    return !CGRectContainsPoint(self.frame, touchPoint);
}
@end
