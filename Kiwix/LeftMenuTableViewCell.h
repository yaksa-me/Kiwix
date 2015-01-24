//
//  LeftMenuTableViewCell.h
//  Kiwix
//
//  Created by Chris Li on 1/22/15.
//  Copyright (c) 2015 Chris Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LeftMenuTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *cellTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *cellDetailLabel;

@end
