//
//  SymbolTextTableViewCell.h
//  SFSymbolsPreview
//
//  Created by Lessica on 2022/3/9.
//  Copyright © 2022 YICAI YANG. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SymbolTextTableViewCell : UITableViewCell

@property (nonatomic, strong, readonly) UILabel *centeredTextLabel;
@property (nonatomic, strong, readonly) UILabel *centeredDetailTextLabel;

@end

NS_ASSUME_NONNULL_END
