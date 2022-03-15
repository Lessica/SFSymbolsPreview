//
//  UIColor+HexColor.h
//  SFSymbolsPreview
//
//  Created by Rachel on 3/15/22.
//  Copyright © 2022 YICAI YANG. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (HexColor)

+ (UIColor *)colorWithHex:(NSString *)representation;

@end

NS_ASSUME_NONNULL_END
