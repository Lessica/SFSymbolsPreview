//
//  SFSymbolDataSource.h
//  SFSymbolsPreview
//
//  Created by YICAI YANG on 2020/5/28.
//  Copyright © 2020 YICAI YANG. All rights reserved.
//

#import "SFSymbol.h"
#import "SFSymbolCategory.h"

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN BOOL IS_IPAD(UIView *);

FOUNDATION_EXTERN SFSymbolCategory *lastOpenedCategeory(void);
FOUNDATION_EXTERN void storeUserActivityLastOpenedCategory(SFSymbolCategory *category);

FOUNDATION_EXTERN NSUInteger numberOfItemsInColumn(void);
FOUNDATION_EXTERN void storeUserActivityNumberOfItemsInColumn(NSUInteger numberOfItems);

FOUNDATION_EXTERN NSNotificationName const SFPreferredSymbolConfigurationDidChangeNotification;
FOUNDATION_EXTERN SFSymbolLayerSetName preferredRenderMode(void);
FOUNDATION_EXTERN UIImageSymbolConfiguration *preferredImageSymbolConfiguration(void);
FOUNDATION_EXTERN void storePreferredImageSymbolConfiguration(UIImageSymbolConfiguration *configuration);

FOUNDATION_EXTERN NSNotificationName const SFSymbolFavoritesDidUpdateNotification;

@interface UIImageSymbolConfiguration (Private)

@property (nonatomic, assign) UIImageSymbolWeight weight;
@property (nonatomic, assign) UIImageSymbolScale scale;
@property (nonatomic, assign) CGFloat fixedPointSize;
@property (nonatomic, assign) CGFloat pointSizeForScalingWithTextStyle;
@property (nonatomic, assign) CGFloat customFontPointSizeMultiplier;
@property (nonatomic, copy) UIFontTextStyle textStyle;

@end

@interface SFSymbolDataSource : NSObject
    
@property (nonatomic, strong, readonly) NSArray <SFSymbolCategory *> *categories;

+ (instancetype)dataSource;

@end

@interface UIImage (SharingImageExtension)

- (UIImage *)toSize:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
