//
//  SFSymbolAvailability.h
//  SFSymbolsPreview
//
//  Created by Rachel on 3/5/22.
//  Copyright © 2022 YICAI YANG. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN NSString * const SFSymbolAvailabilityPlatformName_iOS;
FOUNDATION_EXTERN NSString * const SFSymbolAvailabilityPlatformName_macCatalyst;
FOUNDATION_EXTERN NSString * const SFSymbolAvailabilityPlatformName_macOS;
FOUNDATION_EXTERN NSString * const SFSymbolAvailabilityPlatformName_tvOS;
FOUNDATION_EXTERN NSString * const SFSymbolAvailabilityPlatformName_watchOS;
FOUNDATION_EXTERN NSString * const SFSymbolAvailabilityPlatformName_visionOS;

typedef NSString *SFSymbolAvailabilityPlatformName;

@interface SFSymbolAvailability : NSObject

@property (nonatomic, copy, readonly) NSString *yearToRelease;
@property (nonatomic, copy, readonly) NSString *version;
@property (nonatomic, strong, readonly) NSDictionary *availabilityDictionary;

- (instancetype)initWithYearToRelease:(NSString *)yearToRelease;

- (void)setAvailabilityValue:(NSString *)availabilityValue forPlatform:(SFSymbolAvailabilityPlatformName)platform;
- (NSString *)availabilityValueForPlatform:(SFSymbolAvailabilityPlatformName)platform;
- (BOOL)isCompatibleWithCurrentPlatform;

+ (nullable SFSymbolAvailabilityPlatformName)platformWithName:(NSString *)platformName;

@end

NS_ASSUME_NONNULL_END
