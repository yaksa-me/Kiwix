//
//  BookTableViewCell.h
//  Kiwix
//
//  Created by Chris Li on 4/5/15.
//  Copyright (c) 2015 Chris Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MRProgress.h"

typedef enum AccessoryViewStateTypes
{
    AccessoryViewStateOriginal,
    AccessoryViewStateInProgress,
    AccessoryViewStateFinished
} AccessoryViewState;

@protocol BookTableViewCellDelegate <NSObject>
- (void)didTapAccessoryViewAtIndexPath:(NSIndexPath *)indexPath;
@end

@interface BookTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *favIcon;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UIView *customAccesory;
@property (strong, nonatomic) UIImageView *originalImageView;
@property (strong, nonatomic) MRCircularProgressView *progressIndicator;
@property (strong, nonatomic) UIImageView *finishedImageView;

@property (weak, nonatomic) id<BookTableViewCellDelegate>delegate;
@property (nonatomic) AccessoryViewState state;
@property NSIndexPath *indexPath;

- (void)animateFromOriginalToInProgress;
- (void)animateFromInProgressToOriginal;
- (void)animateFromInProgressToFinish;
- (void)animateFromFinishToOriginal;
- (void)setState:(AccessoryViewState)state animated:(BOOL)animated withProgress:(CGFloat)progress;


@end
