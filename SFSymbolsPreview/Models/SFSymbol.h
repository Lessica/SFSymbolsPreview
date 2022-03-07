//
//  SFSymbol.h
//  SFSymbolsPreview
//
//  Created by YICAI YANG on 2020/5/28.
//  Copyright © 2020 YICAI YANG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFSymbolAvailability.h"


extern NSString * const SFSymbolLayerSetNameMonochrome;
extern NSString * const SFSymbolLayerSetNameHierarchical;
extern NSString * const SFSymbolLayerSetNamePalette;
extern NSString * const SFSymbolLayerSetNameMulticolor;

typedef NSString *SFSymbolLayerSetName;

@interface SFSymbol : NSObject
    
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSAttributedString *attributedName;
@property (nonatomic, strong, readonly) UIImage *image;

@property (nonatomic, strong, readonly) SFSymbolAvailability *availability;
@property (nonatomic, strong, readonly) NSDictionary <SFSymbolLayerSetName, SFSymbolAvailability *> *layerSetAvailabilities;
@property (nonatomic, copy, readonly) NSString *useRestrictions;
@property (nonatomic, copy, readonly) NSString *unicodeString;

+ (instancetype)symbolWithName:(NSString *)name;
+ (instancetype)symbolWithAttributedName:(NSAttributedString *)attributedName;

@end
