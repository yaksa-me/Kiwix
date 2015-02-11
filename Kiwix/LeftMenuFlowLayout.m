//
//  LeftMenuFlowLayout.m
//  Kiwix
//
//  Created by Chris Li on 2/10/15.
//  Copyright (c) 2015 Chris Li. All rights reserved.
//

#import "LeftMenuFlowLayout.h"

@implementation LeftMenuFlowLayout

- (UICollectionViewLayoutAttributes*)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    UICollectionViewLayoutAttributes *attr = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
    
    attr.transform = CGAffineTransformScale(attr.transform, 0.5f, 0.5f);
    attr.center = CGPointMake(CGRectGetMidX(self.collectionView.bounds), CGRectGetMaxY(self.collectionView.bounds));
    
    return attr;
}

@end
