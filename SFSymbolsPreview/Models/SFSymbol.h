//
//  SFSymbol.h
//  SFSymbolsPreview
//
//  Created by YICAI YANG on 2020/5/28.
//  Copyright © 2020 YICAI YANG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFSymbolAvailability.h"

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN NSString * const SFSymbolLayerSetNameMonochrome;
FOUNDATION_EXTERN NSString * const SFSymbolLayerSetNameHierarchical;
FOUNDATION_EXTERN NSString * const SFSymbolLayerSetNamePalette;
FOUNDATION_EXTERN NSString * const SFSymbolLayerSetNameMulticolor;

typedef NSString *SFSymbolLayerSetName;

FOUNDATION_EXTERN NSString *SFSymbolLayerSetDisplayName(SFSymbolLayerSetName name);

@interface SFSymbol : NSObject
    
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, strong, readonly) UIImage *image;

@property (nonatomic, copy, readonly, nullable) NSString *variantName;
@property (nonatomic, strong, readonly) NSArray <SFSymbol *> *symbolVariants;
@property (nonatomic, strong, readonly) NSArray <SFSymbol *> *symbolAliases;

@property (nonatomic, strong, readonly) SFSymbolAvailability *availability;
@property (nonatomic, strong, readonly) NSSet <SFSymbolLayerSetName> *supportedLayerSets;
@property (nonatomic, strong, readonly) NSDictionary <SFSymbolLayerSetName, SFSymbolAvailability *> *layerSetAvailabilities;
@property (nonatomic, copy, readonly, nullable) NSString *useRestrictions;

- (BOOL)supportsMulticolor;

@property (nonatomic, strong, readonly) NSDictionary *availabilityDictionary;

+ (instancetype)symbolWithName:(NSString *)name;

#pragma mark - Search
@property (nonatomic, assign, readonly) NSUInteger initializedOrder;
@property (nonatomic, strong, readonly) NSSet <NSString *> *accurateSearchTokens;
@property (nonatomic, strong, readonly) NSSet <NSString *> *fuzzySearchTokens;
@property (nonatomic, assign) double bestMatchedScore;

@end

NS_ASSUME_NONNULL_END
