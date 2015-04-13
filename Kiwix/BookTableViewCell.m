//
//  BookTableViewCell.m
//  Kiwix
//
//  Created by Chris Li on 4/5/15.
//  Copyright (c) 2015 Chris Li. All rights reserved.
//

#import "BookTableViewCell.h"

#define ANIMATION_DURATION 0.1
@interface BookTableViewCell ()

@property (strong, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;

@end
@implementation BookTableViewCell

- (void)awakeFromNib {
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(customAccessoryStatusChanged)];
    [self.customAccesory addGestureRecognizer:self.tapGestureRecognizer];
    self.state = AccessoryViewStateOriginal;
}

- (void)customAccessoryStatusChanged {
    [self.delegate didTapAccessoryViewAtIndexPath:self.indexPath];
}

- (void)setState:(AccessoryViewState)state animated:(BOOL)animated withProgress:(CGFloat)progress {
    if (animated) {
        switch (state) {
            case AccessoryViewStateOriginal:
                if (self.state == AccessoryViewStateInProgress) {
                    [self animateFromInProgressToOriginal];
                } else if (self.state == AccessoryViewStateFinished) {
                    [self animateFromFinishToOriginal];
                }
                [self.progressIndicator setProgress:progress animated:NO];
                break;
                
            case AccessoryViewStateInProgress:
                if (self.state != AccessoryViewStateInProgress) {
                    [self animateFromOriginalToInProgress];
                }
                [self.progressIndicator setProgress:progress animated:NO];
                break;
                
            case AccessoryViewStateFinished:
                [self animateFromInProgressToFinish];
                [self.progressIndicator setProgress:progress animated:NO];
                break;
                
            default:
                break;
        }
    } else {
        switch (state) {
            case AccessoryViewStateOriginal:
                [self.progressIndicator removeFromSuperview];
                [self.finishedImageView removeFromSuperview];
                self.originalImageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                [self.customAccesory addSubview:self.originalImageView];
                [self.progressIndicator setProgress:progress animated:NO];
                break;
                
            case AccessoryViewStateInProgress:
                [self.originalImageView removeFromSuperview];
                [self.finishedImageView removeFromSuperview];
                [self.progressIndicator setProgress:progress animated:NO];
                self.progressIndicator.transform = CGAffineTransformMakeScale(1.0, 1.0);
                [self.customAccesory addSubview:self.progressIndicator];
                break;
                
            case AccessoryViewStateFinished:
                [self.originalImageView removeFromSuperview];
                [self.progressIndicator removeFromSuperview];
                self.finishedImageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                [self.customAccesory addSubview:self.finishedImageView];
                [self.progressIndicator setProgress:progress animated:NO];
                break;
                
            default:
                break;
        }
    }
    self.state = state;
}

#pragma mark - Lazy Instantiation
- (UIImageView *)originalImageView {
    if (!_originalImageView) {
        _originalImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
        _originalImageView.image = [[UIImage imageNamed:@"CloudDown"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _originalImageView.transform = CGAffineTransformMakeScale(1.0 , 1.0);
    }
    return _originalImageView;
}

- (MRCircularProgressView *)progressIndicator {
    if (!_progressIndicator) {
        _progressIndicator = [[MRCircularProgressView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
        _progressIndicator.mayStop = YES;
        _progressIndicator.transform = CGAffineTransformMakeScale(1.0, 1.0);
    }
    return _progressIndicator;
}

- (UIImageView *)finishedImageView {
    if (!_finishedImageView) {
        _finishedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
        _finishedImageView.image = [[UIImage imageNamed:@"Trash"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _finishedImageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
    }
    return _finishedImageView;
}

#pragma mark - Animations
- (void)animateFromOriginalToInProgress {
    [self.finishedImageView removeFromSuperview];
    [UIView animateWithDuration:ANIMATION_DURATION delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.originalImageView.transform = CGAffineTransformMakeScale(0.1, 0.1);
    } completion:^(BOOL finished) {
        [self.originalImageView removeFromSuperview];
        self.progressIndicator.transform = CGAffineTransformMakeScale(0.1, 0.1);
        [self.customAccesory addSubview:self.progressIndicator];
        [UIView animateWithDuration:ANIMATION_DURATION delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.progressIndicator.transform = CGAffineTransformMakeScale(1.0, 1.0);
        } completion:^(BOOL finished) {

        }];
    }];
}

- (void)animateFromInProgressToOriginal {
    [self.finishedImageView removeFromSuperview];
    [UIView animateWithDuration:ANIMATION_DURATION delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.progressIndicator.transform = CGAffineTransformMakeScale(0.1, 0.1);
    } completion:^(BOOL finished) {
        [self.progressIndicator removeFromSuperview];
        self.originalImageView.transform = CGAffineTransformMakeScale(0.1, 0.1);
        [self.customAccesory addSubview:self.originalImageView];
        [UIView animateWithDuration:ANIMATION_DURATION delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.originalImageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
        } completion:^(BOOL finished) {

        }];
    }];
}

- (void)animateFromInProgressToFinish {
    [self.originalImageView removeFromSuperview];
    [UIView animateWithDuration:ANIMATION_DURATION delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.progressIndicator.transform = CGAffineTransformMakeScale(0.1, 0.1);
    } completion:^(BOOL finished) {
        [self.progressIndicator removeFromSuperview];
        self.finishedImageView.transform = CGAffineTransformMakeScale(0.1, 0.1);
        [self.customAccesory addSubview:self.finishedImageView];
        [UIView animateWithDuration:ANIMATION_DURATION delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.finishedImageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
        } completion:^(BOOL finished) {

        }];
    }];
}

- (void)animateFromFinishToOriginal {
    [self.progressIndicator removeFromSuperview];
    [UIView animateWithDuration:ANIMATION_DURATION delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.finishedImageView.transform = CGAffineTransformMakeScale(0.1, 0.1);
    } completion:^(BOOL finished) {
        [self.finishedImageView removeFromSuperview];
        self.originalImageView.transform = CGAffineTransformMakeScale(0.1, 0.1);
        [self.customAccesory addSubview:self.originalImageView];
        [UIView animateWithDuration:ANIMATION_DURATION delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.originalImageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
        } completion:^(BOOL finished) {

        }];
    }];
}

#pragma mark - Others

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
}


@end
