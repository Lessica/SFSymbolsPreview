//
//  SymbolSearchResultsViewController.m
//  SFSymbolsPreview
//
//  Created by YICAI YANG on 2020/5/27.
//  Copyright © 2020 YICAI YANG. All rights reserved.
//

#import "SymbolSearchResultsViewController.h"
#import "SymbolGroupedDetailsViewController.h"
#import "SFReusableTitleView.h"


@interface SymbolSearchResultsViewController ()

@property (nonatomic, strong) SFSymbolCategory *searchResult;

@end

@implementation SymbolSearchResultsViewController

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString *text = [NSString stringWithFormat:@"%@", searchController.searchBar.text];
    UIColor *tintColor = self.view.tintColor;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        __block NSMutableArray <SFSymbol *> *searchResults = @[].mutableCopy;
        [self.category.symbols enumerateObjectsUsingBlock:^(SFSymbol *symbol, NSUInteger index, BOOL *stop) {
            NSRange range = [symbol.name rangeOfString:text options:NSCaseInsensitiveSearch];
            if (range.location != NSNotFound)
            {
                UIFont *bodyFont = [UIFont preferredFontForTextStyle:[self preferredTextStyle]];
                NSMutableAttributedString *attributedName = [NSAttributedString.alloc initWithString:symbol.name attributes:@{
                                                                 NSForegroundColorAttributeName: UIColor.labelColor,
                                                                 NSFontAttributeName: bodyFont,
                                                            }].mutableCopy;
                UIFont *boldFont = [UIFont fontWithDescriptor:[[bodyFont fontDescriptor] fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold] size:0];
                [attributedName setAttributes:@{
                    NSForegroundColorAttributeName: tintColor,
                    NSFontAttributeName: boldFont,
                } range:range];
                
                [searchResults addObject:[SFSymbol symbolWithAttributedName:attributedName]];
            }
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setSearchResult:[SFSymbolCategory.alloc initWithSearchResultsCategoryWithSymbols:searchResults]];
            [self.collectionView reloadData];
        });
    });
}

- (NSArray <SFSymbol *> *)symbolsForDisplay
{
    return self.searchResult.symbols;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.collectionView setKeyboardDismissMode:UIScrollViewKeyboardDismissModeOnDrag];
    [self.collectionView registerClass:SFReusableTitleView.class
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:NSStringFromClass(SFReusableTitleView.class)];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.searchResult.symbols.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(CGRectGetWidth(collectionView.bounds), 36);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionHeader)
    {
        SFReusableTitleView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                     withReuseIdentifier:NSStringFromClass(SFReusableTitleView.class)
                                                                            forIndexPath:indexPath];
        if (!self.symbolsForDisplay.count) {
            view.title = NSLocalizedString(@"No symbol found", nil);
        } else {
            view.title = [NSString stringWithFormat:@"%ld %@", self.symbolsForDisplay.count, self.symbolsForDisplay.count > 1 ? NSLocalizedString(@"symbols", nil) : NSLocalizedString(@"symbol", nil)];
        }
        return view;
    }
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    SymbolGroupedDetailsViewController *detailViewController = [SymbolGroupedDetailsViewController.alloc initWithSymbol:self.symbolsForDisplay[indexPath.item]];
    [self.searchResultDisplayingNavigationController pushViewController:detailViewController animated:YES];
}

- (void)dealloc
{
#ifdef DEBUG
    NSLog(@"- [%@ dealloc]", NSStringFromClass([self class]));
#endif
}

@end
