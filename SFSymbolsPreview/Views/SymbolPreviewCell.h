//
//  SymbolPreviewCell.h
//  SFSymbolsPreview
//
//  Created by YICAI YANG on 2020/5/27.
//  Copyright © 2020 YICAI YANG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFSymbol.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SymbolPreviewDelegate <NSObject>

@optional
- (void)symbolPreviewShowDetailedInfo:(SFSymbol *)symbol;

@end

@interface SymbolPreviewCell : UICollectionViewCell

@property (nonatomic, weak) id <SymbolPreviewDelegate> delegate;
@property (nonatomic, weak) SFSymbol *symbol;
@property (nonatomic, copy) NSAttributedString *attributedText;

@end

@interface SymbolPreviewTableCell : UICollectionViewCell

@property (nonatomic, weak) id <SymbolPreviewDelegate> delegate;
@property (nonatomic, weak) SFSymbol *symbol;
@property (nonatomic, copy) NSAttributedString *attributedText;

@end

NS_ASSUME_NONNULL_END
