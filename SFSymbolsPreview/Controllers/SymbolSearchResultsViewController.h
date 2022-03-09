//
//  SymbolSearchResultsViewController.h
//  SFSymbolsPreview
//
//  Created by YICAI YANG on 2020/5/27.
//  Copyright © 2020 YICAI YANG. All rights reserved.
//

#import "SymbolsViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface SymbolSearchResultsViewController : SymbolsViewController <UISearchResultsUpdating>

@property (nonatomic, weak) UINavigationController *searchResultDisplayingNavigationController;

@end

NS_ASSUME_NONNULL_END
