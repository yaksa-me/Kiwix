//
//  LeftMenuCollectionViewCell.h
//  Kiwix
//
//  Created by Chris Li on 2/9/15.
//  Copyright (c) 2015 Chris Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CollectionViewCellBoarderView.h"

@interface LeftMenuCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet CollectionViewCellBoarderView *borderView;

@end
