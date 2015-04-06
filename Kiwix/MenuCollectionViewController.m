//
//  MenuCollectionViewController.m
//  Kiwix
//
//  Created by Chris Li on 4/3/15.
//  Copyright (c) 2015 Chris Li. All rights reserved.
//

#import "MenuCollectionViewController.h"
#import "MenuCollectionViewCell.h"

@interface MenuCollectionViewController ()

@property (strong, nonatomic) NSArray *imageNameArray;

@property (strong, nonatomic) UIViewController *BooksVC;

@end

@implementation MenuCollectionViewController

//static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    [self.collectionView registerClass:[MenuCollectionViewCell class] forCellWithReuseIdentifier:@"MenuCollectionViewCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"MenuCollectionViewCell" bundle:[NSBundle mainBundle]]
        forCellWithReuseIdentifier:@"MenuCollectionViewCell"];
    
    self.imageNameArray = @[@"Bookshelf", @"Settings"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.imageNameArray count];;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MenuCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MenuCollectionViewCell" forIndexPath:indexPath];
    
    cell.imageView.image = [UIImage imageNamed:[self.imageNameArray objectAtIndex:indexPath.row]];
    cell.label.text = [self.imageNameArray objectAtIndex:indexPath.row];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (kind == UICollectionElementKindSectionHeader) {
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        return headerView;
    } else {
        UICollectionReusableView *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
        return footerview;
    }
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        if (!self.BooksVC) {
            self.BooksVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"BooksViewController"];
        }
        [self presentViewController:self.BooksVC animated:YES completion:nil];
    }
}

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
