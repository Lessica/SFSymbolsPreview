//
//  SymbolsViewController.m
//  SFSymbolsPreview
//
//  Created by YICAI YANG on 2020/5/27.
//  Copyright © 2020 YICAI YANG. All rights reserved.
//

#import "SymbolSearchResultsViewController.h"
#import "SymbolsViewController.h"

#import "ReusableTitleView.h"
#import "TextCell.h"

#import "SFSymbolDatasource.h"


@implementation UIImage( SharingImageExtension )

- (UIImage *)toSize:(CGSize)size
{
    UIImage *image = nil;
    {
        UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
        [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
        (image = UIGraphicsGetImageFromCurrentImageContext());
        UIGraphicsEndImageContext();
    }
    return image;
}

@end


@interface SymbolsViewController()
{
    dispatch_once_t _onceToken;
}

@end

@implementation SymbolsViewController

- (instancetype)initWithCategory:(SFSymbolCategory *)category
{
    if( [super init] )
    {
        [self setCategory:category];
        [self setTitle:NSLocalizedString([category.name isEqualToString:@"All"] ? @"SF Symbols" : category.name, nil)];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setNumberOfItemInColumn:numberOfItemsInColumn()];
    
    [self.view setBackgroundColor:UIColor.systemBackgroundColor];
    [self.navigationController.navigationBar setPrefersLargeTitles:YES];
    
    [self.navigationItem setSearchController:({
        SymbolSearchResultsViewController *searchResultsVC = [SymbolSearchResultsViewController.alloc initWithCategory:self.category];
        searchResultsVC.navigationC = self.navigationController;
        UISearchController *searchController = [UISearchController.alloc initWithSearchResultsController:searchResultsVC];
        searchController.searchResultsUpdater = searchResultsVC;
        searchController.searchBar.placeholder = NSLocalizedString(@"Search", nil);
        searchController;
    })];
    [self.navigationItem setHidesSearchBarWhenScrolling:NO];
    
    [self.navigationItem setRightBarButtonItem:[UIBarButtonItem.alloc initWithTitle:@"Regular"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(changePreferredImageSymbolWeight)]];
    [self updateRightBarButtonItemTitle];
    
    [self setCollectionView:({
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout.alloc init];
        [layout setMinimumLineSpacing:16];
        [layout setMinimumInteritemSpacing:16];
        [layout setSectionInset:UIEdgeInsetsMake(16, 16, 16, 16)];
        
        UICollectionView *f = [UICollectionView.alloc initWithFrame:CGRectZero collectionViewLayout:layout];
        [f setDelegate:self];
        [f setDataSource:self];
        [f setAlwaysBounceVertical:YES];
        [f setAlwaysBounceHorizontal:NO];
        [f setShowsVerticalScrollIndicator:YES];
        [f setShowsHorizontalScrollIndicator:NO];
        [f setAllowsMultipleSelection:NO];
        [f setBackgroundColor:UIColor.clearColor];
        [f setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.view addSubview:f];
        [f.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
        [f.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active = YES;
        [f.rightAnchor constraintEqualToAnchor:self.view.rightAnchor].active = YES;
        [f.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
        [f registerClass:SymbolPreviewCell.class forCellWithReuseIdentifier:NSStringFromClass(SymbolPreviewCell.class)];
        [f registerClass:SymbolPreviewTableCell.class forCellWithReuseIdentifier:NSStringFromClass(SymbolPreviewTableCell.class)];
        (f);
    })];
    
    [self.collectionView registerClass:ReusableSegmentedControlView.class forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:NSStringFromClass(ReusableSegmentedControlView.class)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.collectionView deselectItemAtIndexPath:self.collectionView.indexPathsForVisibleItems.firstObject animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if( [self isKindOfClass:SymbolsViewController.class] )
    {
        dispatch_once(&_onceToken, ^{
            storeUserActivityLastOpenedCategory(self.category);
        });
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.category.symbols.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(CGRectGetWidth(collectionView.bounds), 64);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if( kind == UICollectionElementKindSectionHeader )
    {
        ReusableSegmentedControlView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                                withReuseIdentifier:NSStringFromClass(ReusableSegmentedControlView.class)
                                                                                       forIndexPath:indexPath];
        view.segmentedControl.selectedSegmentIndex = self.numberOfItemInColumn - 1;
        [view.segmentedControl addTarget:self action:@selector(changeNumberOfItemsInColumn:) forControlEvents:UIControlEventValueChanged];
        return view;
    }
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat itemWidth;
    
    if( self.numberOfItemInColumn > 1 )
    {
        itemWidth = (CGRectGetWidth(collectionView.bounds) - 16 * (self.numberOfItemInColumn + 1)) / self.numberOfItemInColumn;
        return CGSizeMake(itemWidth - 1, itemWidth * .68f + 64);
    }
    else
    {
        itemWidth = CGRectGetWidth(collectionView.bounds) - 32.0f;
        return CGSizeMake(itemWidth, 48);
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if( self.numberOfItemInColumn > 1 )
    {
        SymbolPreviewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(SymbolPreviewCell.class)
                                                                            forIndexPath:indexPath];
        [cell setSymbol:self.category.symbols[indexPath.row]];
        return cell;
    }
    else
    {
        SymbolPreviewTableCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(SymbolPreviewTableCell.class)
                                                                                 forIndexPath:indexPath];
        [cell setSymbol:self.category.symbols[indexPath.row]];
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *imageNamed = self.category.symbols[indexPath.item].name;
    
    UIImage *image;
    {
        CGRect imageRect = CGRectMake(0, 0, 512, 512);
        CGFloat scale = 3.0f;
        
        image = [UIImage systemImageNamed:imageNamed];
        image = [image toSize:CGSizeMake(imageRect.size.width, imageRect.size.width * image.size.height / image.size.width)];
        
        UIGraphicsBeginImageContextWithOptions(imageRect.size, NO, scale);
        [image drawAtPoint:CGPointMake(CGRectGetMidX(imageRect) - image.size.width / 2.0f, CGRectGetMidY(imageRect) - image.size.height / 2.0f)];
        (image = UIGraphicsGetImageFromCurrentImageContext());
        UIGraphicsEndImageContext();
    }
    
    UIActivityViewController *activityViewController = [UIActivityViewController.alloc initWithActivityItems:@[ imageNamed, image ]
                                                                                       applicationActivities:nil];
    if( UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad )
    {
        activityViewController.popoverPresentationController.sourceView = [collectionView cellForItemAtIndexPath:indexPath];
        activityViewController.popoverPresentationController.sourceRect = activityViewController.popoverPresentationController.sourceView.bounds;
    }
    [self presentViewController:activityViewController animated:YES completion:nil];
}

- (void)changePreferredImageSymbolWeight
{
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:nil
                                                                    message:nil
                                                             preferredStyle:UIAlertControllerStyleActionSheet];
    [alertC addAction:[UIAlertAction actionWithTitle:@"Ultralight" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self updatePreferredImageSymbolWeight:UIImageSymbolWeightUltraLight];
    }]];
    [alertC addAction:[UIAlertAction actionWithTitle:@"Thin" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self updatePreferredImageSymbolWeight:UIImageSymbolWeightThin];
    }]];
    [alertC addAction:[UIAlertAction actionWithTitle:@"Light" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self updatePreferredImageSymbolWeight:UIImageSymbolWeightLight];
    }]];
    [alertC addAction:[UIAlertAction actionWithTitle:@"Regular" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self updatePreferredImageSymbolWeight:UIImageSymbolWeightRegular];
    }]];
    [alertC addAction:[UIAlertAction actionWithTitle:@"Medium" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self updatePreferredImageSymbolWeight:UIImageSymbolWeightMedium];
    }]];
    [alertC addAction:[UIAlertAction actionWithTitle:@"Semibold" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self updatePreferredImageSymbolWeight:UIImageSymbolWeightSemibold];
    }]];
    [alertC addAction:[UIAlertAction actionWithTitle:@"Bold" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self updatePreferredImageSymbolWeight:UIImageSymbolWeightBold];
    }]];
    [alertC addAction:[UIAlertAction actionWithTitle:@"Heavy" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self updatePreferredImageSymbolWeight:UIImageSymbolWeightHeavy];
    }]];
    [alertC addAction:[UIAlertAction actionWithTitle:@"Black" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self updatePreferredImageSymbolWeight:UIImageSymbolWeightBlack];
    }]];
    [alertC addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
    if( UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad )
    {
        alertC.popoverPresentationController.barButtonItem = self.navigationItem.rightBarButtonItem;
    }
    [self presentViewController:alertC animated:YES completion:nil];
}

- (void)updateRightBarButtonItemTitle
{
    switch( preferredImageSymbolWeight() )
    {
        case UIImageSymbolWeightUltraLight: self.navigationItem.rightBarButtonItem.title = @"Ultralight"; break;
        case UIImageSymbolWeightThin: self.navigationItem.rightBarButtonItem.title = @"Thin"; break;
        case UIImageSymbolWeightLight: self.navigationItem.rightBarButtonItem.title = @"Light"; break;
        case UIImageSymbolWeightRegular: self.navigationItem.rightBarButtonItem.title = @"Regular"; break;
        case UIImageSymbolWeightMedium: self.navigationItem.rightBarButtonItem.title = @"Medium"; break;
        case UIImageSymbolWeightSemibold: self.navigationItem.rightBarButtonItem.title = @"Semibold"; break;
        case UIImageSymbolWeightBold: self.navigationItem.rightBarButtonItem.title = @"Bold"; break;
        case UIImageSymbolWeightHeavy: self.navigationItem.rightBarButtonItem.title = @"Heavy"; break;
        case UIImageSymbolWeightBlack: self.navigationItem.rightBarButtonItem.title = @"Black"; break;
        default: self.navigationItem.rightBarButtonItem.title = @"Regular"; break;
    }
}

- (void)updatePreferredImageSymbolWeight:(UIImageSymbolWeight)weight
{
    if( weight != preferredImageSymbolWeight() )
    {
        storeUserActivityPreferredImageSymbolWeight(weight);
        
        [self.collectionView performBatchUpdates:^{
            [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
        } completion:nil];
    }
    [self updateRightBarButtonItemTitle];
}

- (void)changeNumberOfItemsInColumn:(UISegmentedControl *)segmentedControl
{
    [self setNumberOfItemInColumn:segmentedControl.selectedSegmentIndex + 1];
    
    [self.collectionView performBatchUpdates:^{
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    } completion:nil];
    
    storeUserActivityNumberOfItemsInColumn(self.numberOfItemInColumn);
}

@end
