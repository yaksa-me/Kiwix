//
//  LeftMenuVC.m
//  Kiwix
//
//  Created by Chris Li on 2/8/15.
//  Copyright (c) 2015 Chris Li. All rights reserved.
//

#import "LeftMenuVC.h"
#import "LeftMenuCollectionViewCell.h"
#import "SlideNavigationController.h"
#import "Preference.h"
#import "LeftMenuFlowLayout.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define CELL_REUSE_INDENTIFIER @"LeftMenuCell"

@interface LeftMenuVC ()
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSArray *labelArray;
@property (strong, nonatomic) NSArray *iconNameArray;
@property (strong, nonatomic) NSArray *iconHighlightedArray;
@property (strong, nonatomic) NSArray *scaleFactorArray;
@property (strong, nonatomic) NSArray *colorArray;
@property (strong, nonatomic) UILongPressGestureRecognizer *longPressGestureRecognizer;

@end

@implementation LeftMenuVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINib *nib = [UINib nibWithNibName:@"LeftMenuCollectionViewCell" bundle:[NSBundle mainBundle]];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:CELL_REUSE_INDENTIFIER];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.collectionViewLayout = [[LeftMenuFlowLayout alloc] init];
    self.collectionView.backgroundColor = [UIColor lightGrayColor];
    
    self.labelArray = @[@"Reading", @"BookList", @"Recent", @"Settings"];
    self.iconNameArray = @[@"reading", @"star", @"recent", @"settings"];
    self.iconHighlightedArray = @[@"reading_highlighted", @"star_highlighted", @"recent_highlighted", @"settings_highlighted"];
    
    self.scaleFactorArray = @[[NSNumber numberWithFloat:1.2], [NSNumber numberWithFloat:0.8], [NSNumber numberWithFloat:1.2], [NSNumber numberWithFloat:1.1]];
    self.colorArray = @[UIColorFromRGB(0x00AE00), UIColorFromRGB(0xFF3824), UIColorFromRGB(0xFF9600), UIColorFromRGB(0x0076FF)];
    
    /*
    self.longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    self.longPressGestureRecognizer.minimumPressDuration = 0.0;
    self.longPressGestureRecognizer.delegate = self;
    self.longPressGestureRecognizer.delaysTouchesBegan = NO;
    [self.collectionView addGestureRecognizer:self.longPressGestureRecognizer];*/
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadCollectionView) name:SlideNavigationControllerDidReveal object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SlideNavigationControllerDidReveal object:nil];
}

- (void)reloadCollectionView {
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)longPressGestureRecognizer {
    CGPoint point = [longPressGestureRecognizer locationInView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:point];
    LeftMenuCollectionViewCell *cell = (LeftMenuCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    
    if (longPressGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [self shrinkContentInCell:cell];
    } else if (longPressGestureRecognizer.state == UIGestureRecognizerStateFailed) {
        [self restoreContentInCell:cell];
    }
    
}

- (void)shrinkContentInCell:(LeftMenuCollectionViewCell *)cell {
    UIView *icon = cell.icon;
    UIView *border = cell.borderView;
    [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        icon.transform = CGAffineTransformMakeScale(0.8, 0.8);
        border.transform = CGAffineTransformMakeScale(0.8, 0.8);
    } completion:^(BOOL finished) {
        
    }];
    
}

- (void)restoreContentInCell:(LeftMenuCollectionViewCell *)cell {
    UIView *icon = cell.icon;
    UIView *border = cell.borderView;
    [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        icon.transform = CGAffineTransformMakeScale(1.0, 1.0);
        border.transform = CGAffineTransformMakeScale(1.0, 1.0);
    } completion:^(BOOL finished) {
        
    }];
    
}
#pragma mark - UIcollectionViewDataSource 
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 4;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LeftMenuCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CELL_REUSE_INDENTIFIER forIndexPath:indexPath];
    
    cell.label.text = [self.labelArray objectAtIndex:indexPath.row];
    cell.icon.image = [[UIImage imageNamed:[self.iconNameArray objectAtIndex:indexPath.row]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    cell.icon.highlightedImage = [[UIImage imageNamed:[self.iconHighlightedArray objectAtIndex:indexPath.row]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    CGFloat scale = [[self.scaleFactorArray objectAtIndex:indexPath.row] floatValue] * 1.2;
    cell.icon.layer.contentsRect = CGRectMake((1-scale)/2, (1-scale)/2, scale, scale);
    if (indexPath.row != [Preference currentMenuIndex]) {
        cell.borderView.borderColor = [UIColor darkGrayColor];
        [cell.icon setTintColor:[UIColor darkGrayColor]];
        cell.icon.highlighted = NO;
    } else {
        cell.borderView.borderColor = [[self.colorArray objectAtIndex:indexPath.row] colorWithAlphaComponent:0.8];
        [cell.icon setTintColor:[[self.colorArray objectAtIndex:indexPath.row] colorWithAlphaComponent:0.8]];
        cell.icon.highlighted = YES;
    }
    [cell.borderView setNeedsDisplay];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        
        reusableview = headerView;
    }
    
    if (kind == UICollectionElementKindSectionFooter) {
        UICollectionReusableView *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
        
        reusableview = footerview;
    }
    
    return reusableview;
}

#pragma mark – UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(60.0f, 50.0f);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeMake(60.0f, 50.0f);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(80, 95);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 10, 0, 10);
}

#pragma mark - UIcollectionView Delagate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    UIViewController *viewController;
    
    switch (indexPath.row)
    {
        case 0:
            viewController = [mainStoryboard instantiateViewControllerWithIdentifier: @"ArticleVC"];
            [Preference setCurrentMenuIndex:0];
            break;
        case 1:
            viewController = [mainStoryboard instantiateViewControllerWithIdentifier: @"BookListTBVC"];
            [Preference setCurrentMenuIndex:1];
            break;
        case 2:
            viewController = [mainStoryboard instantiateViewControllerWithIdentifier: @"HistoryTBVC"];
            [Preference setCurrentMenuIndex:2];
            break;
        case 3:
            viewController = [mainStoryboard instantiateViewControllerWithIdentifier: @"SettingTBVC"];
            [Preference setCurrentMenuIndex:3];
            break;
    }
    
    [[SlideNavigationController sharedInstance] popAllAndSwitchToViewController:viewController withSlideOutAnimation:NO andCompletion:nil];
    [self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
    [self.collectionView reloadData];
}

@end
