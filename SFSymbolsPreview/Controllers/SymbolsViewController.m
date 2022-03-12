//
//  SymbolsViewController.m
//  SFSymbolsPreview
//
//  Created by YICAI YANG on 2020/5/27.
//  Copyright © 2020 YICAI YANG. All rights reserved.
//

#import "SymbolSearchResultsViewController.h"
#import "SymbolsViewController.h"
#import "SFReusableTitleView.h"
#import "SFSymbolDataSource.h"
#import "SymbolGroupedDetailsViewController.h"


@interface SymbolsViewController () <SymbolPreviewDelegate, UICollectionViewDragDelegate>
{
    dispatch_once_t _onceToken;
}

@property (nonatomic, strong) SymbolSearchResultsViewController *searchResultsViewController;

@end

@implementation SymbolsViewController

- (instancetype)initWithCategory:(SFSymbolCategory *)category
{
    if ([super init])
    {
        [self setCategory:category];
        [self setTitle:NSLocalizedString([category.name isEqualToString:@"All"] ? @"SF Symbols" : category.name, nil)];
    }
    return self;
}

- (NSArray <SFSymbol *> *)symbolsForDisplay
{
    return self.category.symbols;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setNumberOfItemInColumn:numberOfItemsInColumn()];
    
    [self.view setBackgroundColor:UIColor.systemBackgroundColor];
    [self.navigationController.navigationBar setPrefersLargeTitles:YES];
    [self.navigationItem setLargeTitleDisplayMode:UINavigationItemLargeTitleDisplayModeAutomatic];
    
    _searchResultsViewController = ({
        SymbolSearchResultsViewController *searchResultsVC = [SymbolSearchResultsViewController.alloc initWithCategory:self.category];
        searchResultsVC.numberOfItemInColumn = self.numberOfItemInColumn;
        searchResultsVC.searchResultDisplayingNavigationController = self.navigationController;
        searchResultsVC;
    });
    
    [self.navigationItem setSearchController:({
        UISearchController *searchController = [UISearchController.alloc initWithSearchResultsController:self.searchResultsViewController];
        searchController.searchResultsUpdater = self.searchResultsViewController;
        searchController.searchBar.placeholder = NSLocalizedString(@"Search", nil);
        searchController.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
        searchController.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
        searchController.searchBar.spellCheckingType = UITextSpellCheckingTypeNo;
        searchController.searchBar.smartQuotesType = UITextSmartQuotesTypeNo;
        searchController.searchBar.smartDashesType = UITextSmartDashesTypeNo;
        searchController.searchBar.smartInsertDeleteType = UITextSmartInsertDeleteTypeNo;
        searchController.searchBar.keyboardType = UIKeyboardTypeASCIICapable;
        searchController;
    })];
    [self.navigationItem setHidesSearchBarWhenScrolling:NO];
    
    [self.navigationItem setRightBarButtonItem:[UIBarButtonItem.alloc initWithTitle:@"Regular"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(changePreferredImageSymbolWeight)]];
    [self updateRightBarButtonItemTitle];
    
    [self.navigationItem setLeftBarButtonItem:self.splitViewController.displayModeButtonItem];
    [self.navigationItem setLeftItemsSupplementBackButton:YES];
    
    [self setCollectionView:({
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout.alloc init];
        [layout setMinimumInteritemSpacing:16];
        [layout setSectionInset:UIEdgeInsetsMake(16, 16, 16, 16)];
        
        UICollectionView *f = [UICollectionView.alloc initWithFrame:CGRectZero collectionViewLayout:layout];
        [f setDelegate:self];
        [f setDataSource:self];
        [f setDragDelegate:self];
        [f setDragInteractionEnabled:YES];
        [f setAlwaysBounceVertical:YES];
        [f setAlwaysBounceHorizontal:NO];
        [f setShowsVerticalScrollIndicator:YES];
        [f setShowsHorizontalScrollIndicator:NO];
        [f setAllowsSelection:YES];
        [f setAllowsMultipleSelection:NO];
        [f setBackgroundColor:UIColor.clearColor];
        [f setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.view addSubview:f];
        [f.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
        [f.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor].active = YES;
        [f.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor].active = YES;
        [f.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
        [f registerClass:SymbolPreviewCell.class forCellWithReuseIdentifier:NSStringFromClass(SymbolPreviewCell.class)];
        [f registerClass:SymbolPreviewTableCell.class forCellWithReuseIdentifier:NSStringFromClass(SymbolPreviewTableCell.class)];
        (f);
    })];
    
    [self.collectionView registerClass:SFReusableSegmentedControlView.class forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:NSStringFromClass(SFReusableSegmentedControlView.class)];
    
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(notifyPreferredSymbolWeightDidChange:)
                                               name:PreferredSymbolWeightDidChangeNotification
                                             object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.collectionView deselectItemAtIndexPath:self.collectionView.indexPathsForSelectedItems.firstObject animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([self isMemberOfClass:SymbolsViewController.class])
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
    return self.symbolsForDisplay.count;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return self.numberOfItemInColumn == 1 ? 0 : 16;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(CGRectGetWidth(collectionView.bounds), 48);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionHeader)
    {
        SFReusableSegmentedControlView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                                withReuseIdentifier:NSStringFromClass(SFReusableSegmentedControlView.class)
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
    
    if (self.numberOfItemInColumn > 1)
    {
        NSUInteger column = IS_IPAD(collectionView) ? self.numberOfItemInColumn * 2 : self.numberOfItemInColumn;
        itemWidth = (CGRectGetWidth(collectionView.bounds) - 16 * (column + 1)) / column;
        return CGSizeMake(itemWidth - 1, itemWidth * .68f + 44);
    }
    else
    {
        itemWidth = CGRectGetWidth(collectionView.bounds) - 32.0f;
        return CGSizeMake(itemWidth, 52);
    }
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.numberOfItemInColumn > 1)
    {
        SymbolPreviewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(SymbolPreviewCell.class)
                                                                            forIndexPath:indexPath];
        [cell setSymbol:self.symbolsForDisplay[indexPath.row]];
        [cell setDelegate:self];
        return cell;
    }
    else
    {
        SymbolPreviewTableCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(SymbolPreviewTableCell.class)
                                                                                 forIndexPath:indexPath];
        [cell setSymbol:self.symbolsForDisplay[indexPath.row]];
        [cell setDelegate:self];
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.navigationController pushViewController:[SymbolGroupedDetailsViewController.alloc initWithSymbol:self.symbolsForDisplay[indexPath.item]]
                                         animated:YES];
}

- (void)changePreferredImageSymbolWeight
{
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:nil
                                                                    message:nil
                                                             preferredStyle:UIAlertControllerStyleActionSheet];
    [alertC addAction:[UIAlertAction actionWithTitle:@"Ultralight" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self updatePreferredImageSymbolWeight:UIImageSymbolWeightUltraLight];
    }]];
    [alertC addAction:[UIAlertAction actionWithTitle:@"Thin" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self updatePreferredImageSymbolWeight:UIImageSymbolWeightThin];
    }]];
    [alertC addAction:[UIAlertAction actionWithTitle:@"Light" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self updatePreferredImageSymbolWeight:UIImageSymbolWeightLight];
    }]];
    [alertC addAction:[UIAlertAction actionWithTitle:@"Regular" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self updatePreferredImageSymbolWeight:UIImageSymbolWeightRegular];
    }]];
    [alertC addAction:[UIAlertAction actionWithTitle:@"Medium" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self updatePreferredImageSymbolWeight:UIImageSymbolWeightMedium];
    }]];
    [alertC addAction:[UIAlertAction actionWithTitle:@"Semibold" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self updatePreferredImageSymbolWeight:UIImageSymbolWeightSemibold];
    }]];
    [alertC addAction:[UIAlertAction actionWithTitle:@"Bold" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self updatePreferredImageSymbolWeight:UIImageSymbolWeightBold];
    }]];
    [alertC addAction:[UIAlertAction actionWithTitle:@"Heavy" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self updatePreferredImageSymbolWeight:UIImageSymbolWeightHeavy];
    }]];
    [alertC addAction:[UIAlertAction actionWithTitle:@"Black" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self updatePreferredImageSymbolWeight:UIImageSymbolWeightBlack];
    }]];
    [alertC addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        alertC.popoverPresentationController.barButtonItem = self.navigationItem.rightBarButtonItem;
    }
    [self presentViewController:alertC animated:YES completion:nil];
}

- (void)notifyPreferredSymbolWeightDidChange:(NSNotification *)notification
{
    [self updatePreferredImageSymbolWeight:preferredImageSymbolWeight()];
}

- (void)updateRightBarButtonItemTitle
{
    switch (preferredImageSymbolWeight())
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
    storeUserActivityPreferredImageSymbolWeight(weight);
    
    [self.collectionView performBatchUpdates:^{
                             [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
                         } completion:nil];
    [self updateRightBarButtonItemTitle];
}

- (void)changeNumberOfItemsInColumn:(UISegmentedControl *)segmentedControl
{
    [self setNumberOfItemInColumn:segmentedControl.selectedSegmentIndex + 1];
    [self.searchResultsViewController setNumberOfItemInColumn:segmentedControl.selectedSegmentIndex + 1];
    
    [self.collectionView performBatchUpdates:^{
                             [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
                         } completion:nil];
    
    storeUserActivityNumberOfItemsInColumn(self.numberOfItemInColumn);
}

- (void)symbolPreviewShowDetailedInfo:(SFSymbol *)symbol
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@", symbol.useRestrictions] message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (UIFontTextStyle)preferredTextStyle
{
    return self.numberOfItemInColumn <= 1 ? UIFontTextStyleBody : UIFontTextStyleCaption1;
}

- (UIContextMenuConfiguration *)collectionView:(UICollectionView *)collectionView contextMenuConfigurationForItemAtIndexPath:(NSIndexPath *)indexPath point:(CGPoint)point
{
    SFSymbol *symbol = self.symbolsForDisplay[indexPath.item];
    NSArray <UIAction *> *cellActions = @[
        [UIAction actionWithTitle:NSLocalizedString(@"Copy Name", nil) image:[UIImage systemImageNamed:@"doc.on.doc"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
            [[UIPasteboard generalPasteboard] setString:symbol.name];
        }],
        [UIAction actionWithTitle:NSLocalizedString(@"Share...", nil) image:[UIImage systemImageNamed:@"square.and.arrow.up"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
            UIActivityViewController *activityVC = [UIActivityViewController.alloc initWithActivityItems:@[ symbol.name, symbol.image ]
                                                                                   applicationActivities:nil];
            if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad)
            {
                activityVC.popoverPresentationController.sourceView = [collectionView cellForItemAtIndexPath:indexPath];
                activityVC.popoverPresentationController.sourceRect = activityVC.popoverPresentationController.sourceView.bounds;
            }
            [self presentViewController:activityVC animated:YES completion:nil];
        }],
    ];
    return [UIContextMenuConfiguration configurationWithIdentifier:nil previewProvider:nil actionProvider:^UIMenu * _Nullable (NSArray <UIMenuElement *> * _Nonnull suggestedActions) {
        UIMenu *menu = [UIMenu menuWithTitle:@"" children:cellActions];
        return menu;
    }];
}

- (NSArray <UIDragItem *> *)collectionView:(UICollectionView *)collectionView itemsForBeginningDragSession:(id <UIDragSession>)session atIndexPath:(NSIndexPath *)indexPath
{
    SFSymbol *symbol = self.symbolsForDisplay[indexPath.item];
    
    NSItemProvider *symbolProvider = [[NSItemProvider alloc] initWithObject:symbol.image];
    UIDragItem *symbolDragItem = [[UIDragItem alloc] initWithItemProvider:symbolProvider];
    
    return @[symbolDragItem];
}

- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (void)dealloc
{
#ifdef DEBUG
    NSLog(@"- [%@ dealloc]", NSStringFromClass([self class]));
#endif
}

@end
