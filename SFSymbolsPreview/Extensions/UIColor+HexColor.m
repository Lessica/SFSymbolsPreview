//
//  UIColor+HexColor.m
//  SFSymbolsPreview
//
//  Created by Rachel on 3/15/22.
//  Copyright © 2022 YICAI YANG. All rights reserved.
//

#import "UIColor+HexColor.h"

@implementation UIColor (HexColor)

+ (UIColor *)colorWithHex:(NSString *)representation {
    if (representation != nil && [representation rangeOfString:@"/"].location != NSNotFound)
    {
        if (@available(iOS 13.0, *)) {
            NSArray <NSString *> *dynamicColorStrings = [representation componentsSeparatedByString:@"/"];
            if (dynamicColorStrings.count == 2) {
                return [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
                    if (traitCollection.userInterfaceStyle != UIUserInterfaceStyleDark) {
                        return [self colorWithHex:dynamicColorStrings.firstObject];
                    } else {
                        return [self colorWithHex:dynamicColorStrings.lastObject];
                    }
                }];
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    NSString *hex = representation;
    if ([hex hasPrefix:@"#"]) {
        hex = [hex substringFromIndex:1];
    } else if ([hex hasPrefix:@"0x"]) {
        hex = [hex substringFromIndex:2];
    }
    NSUInteger length = hex.length;
    if (length != 3 && length != 6 && length != 8)
        return nil;
    if (length == 3) {
        NSString *r = [hex substringWithRange:NSMakeRange(0, 1)];
        NSString *g = [hex substringWithRange:NSMakeRange(1, 1)];
        NSString *b = [hex substringWithRange:NSMakeRange(2, 1)];
        hex = [NSString stringWithFormat:@"%@%@%@%@%@%@ff", r, r, g, g, b, b];
    } else if (length == 6) {
        hex = [NSString stringWithFormat:@"%@ff", hex];
    }
    NSScanner *scanner = [NSScanner scannerWithString:hex];
    unsigned int rgbaValue = 0;
    [scanner scanHexInt:&rgbaValue];
    return [self colorWithRed:((rgbaValue & 0xFF000000) >> 24) / 255.f
                        green:((rgbaValue & 0xFF0000) >> 16) / 255.f
                         blue:((rgbaValue & 0xFF00) >> 8) / 255.f
                        alpha:((rgbaValue & 0xFF)) / 255.f];
}

@end
