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

@property (nonatomic, strong) NSSet <NSString *> *searchTokens;
@property (nonatomic, strong) SFSymbolCategory *searchResult;

@end

@implementation SymbolSearchResultsViewController

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(updateSearchWithText:) withObject:searchController.searchBar.text afterDelay:0.5];
}

- (void)updateSearchWithText:(NSString *)text
{
    NSString *lowercasedText = [[NSString stringWithFormat:@"%@", text] lowercaseString];
    NSSet <NSString *> *inputTokens = [[NSSet alloc] initWithArray:[lowercasedText componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" ."]]];
    
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        
        NSArray <SFSymbol *> *allSymbols = self.category.symbols;
        NSDictionary <NSString *, NSArray <SFSymbol *> *> *tokenizedSymbols = self.category.tokenizedSymbols;
        NSArray <NSString *> *allTokens = tokenizedSymbols.allKeys;
        
        NSMutableSet <SFSymbol *> *filteredSymbols = [[NSMutableSet alloc] initWithArray:allSymbols];
        for (NSString *inputToken in inputTokens) {
            if (inputToken.length == 0) {
                continue;
            }
            NSMutableArray <NSString *> *possibleTokens = [[NSMutableArray alloc] initWithCapacity:allTokens.count];
            for (NSString *token in allTokens) {
                if ([token hasPrefix:@"?"]) {
                    NSString *realToken = [token substringFromIndex:1];
                    if ([realToken rangeOfString:inputToken options:NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch].location != NSNotFound) {
                        [possibleTokens addObject:token];
                    }
                } else if ([token isEqualToString:inputToken]) {
                    [possibleTokens addObject:token];
                }
            }
            NSMutableSet <SFSymbol *> *possibleSymbols = [[NSMutableSet alloc] initWithCapacity:possibleTokens.count];
            for (NSString *possibleToken in possibleTokens) {
                [possibleSymbols addObjectsFromArray:tokenizedSymbols[possibleToken]];
            }
            [filteredSymbols intersectSet:possibleSymbols];
        }
        
        NSArray <SFSymbol *> *filteredOrderedSymbols = [[filteredSymbols allObjects] sortedArrayUsingComparator:^NSComparisonResult (SFSymbol * _Nonnull obj1, SFSymbol * _Nonnull obj2) {
            if (obj1.initializedOrder > obj2.initializedOrder) {
                return NSOrderedDescending;
            } else if (obj1.initializedOrder < obj2.initializedOrder) {
                return NSOrderedAscending;
            }
            return NSOrderedSame;
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setSearchTokens:inputTokens];
            [self setSearchResult:[SFSymbolCategory.alloc initWithSearchResultsCategoryWithSymbols:filteredOrderedSymbols]];
            [self.collectionView reloadData];
        });
    });
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.collectionView setKeyboardDismissMode:UIScrollViewKeyboardDismissModeOnDrag];
    [self.collectionView registerClass:SFReusableTitleView.class
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:NSStringFromClass(SFReusableTitleView.class)];
}

- (NSArray <SFSymbol *> *)symbolsForDisplay
{
    return self.searchResult.symbols;
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

- (NSAttributedString *)attributedSymbolNameWithSearchToken:(NSString *)name
{
    UIColor *tintColor = self.view.tintColor;
    UIFont *bodyFont = [UIFont preferredFontForTextStyle:self.preferredTextStyle];
    NSMutableAttributedString *attributedName = [NSAttributedString.alloc initWithString:name attributes:@{
                                                     NSForegroundColorAttributeName: UIColor.secondaryLabelColor,
                                                     NSFontAttributeName: bodyFont,
                                                }].mutableCopy;
    
    for (NSString *token in self.searchTokens) {
        NSRange range = [name rangeOfString:token options:NSCaseInsensitiveSearch];
        if (range.location != NSNotFound)
        {
            UIFont *boldFont = [UIFont fontWithDescriptor:[[bodyFont fontDescriptor] fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold] size:0];
            [attributedName setAttributes:@{
                 NSForegroundColorAttributeName: tintColor,
                 NSFontAttributeName: boldFont,
             } range:range];
        }
    }
    
    return [attributedName copy];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    SFSymbol *symbol = self.symbolsForDisplay[indexPath.row];
    
    if (self.numberOfItemInColumn > 1)
        [(SymbolPreviewCell *)cell setAttributedText:[self attributedSymbolNameWithSearchToken:symbol.name]];
    else
        [(SymbolPreviewTableCell *)cell setAttributedText:[self attributedSymbolNameWithSearchToken:symbol.name]];
    
    return cell;
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
