//
//  CollectionViewCellBoarderView.m
//  Kiwix
//
//  Created by Chris Li on 2/9/15.
//  Copyright (c) 2015 Chris Li. All rights reserved.
//

#import "CollectionViewCellBoarderView.h"

@implementation CollectionViewCellBoarderView

- (void)drawRect:(CGRect)rect {
    self.backgroundColor = [UIColor clearColor];
    CGFloat radius = rect.size.width/2-2;
    CGPoint center = CGPointMake(rect.size.width/2, rect.size.height/2);
    UIBezierPath *aPath = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:0 endAngle:2.0*M_PI clockwise:YES];
    
    // Set the render colors.
    [self.borderColor setStroke];
    [[UIColor colorWithRed:0.78 green:0.78 blue:0.78 alpha:1.0] setFill];
    
    CGContextRef aRef = UIGraphicsGetCurrentContext();
    
    // If you have content to draw after the shape,
    // save the current state before changing the transform.
    //CGContextSaveGState(aRef);
    
    // Adjust the view's origin temporarily. The oval is
    // now drawn relative to the new origin point.
    CGContextTranslateCTM(aRef, 0, 0);
    
    // Adjust the drawing options as needed.
    aPath.lineWidth = 2;
    
    // Fill the path before stroking it so that the fill
    // color does not obscure the stroked line.
    [aPath fill];
    [aPath stroke];
    
    // Restore the graphics state before drawing any other content.
    //CGContextRestoreGState(aRef);

}

@end
