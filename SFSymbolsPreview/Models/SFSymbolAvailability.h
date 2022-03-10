//
//  SFSymbolAvailability.h
//  SFSymbolsPreview
//
//  Created by Rachel on 3/5/22.
//  Copyright © 2022 YICAI YANG. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const SFSymbolAvailabilityPlatformName_iOS;
extern NSString * const SFSymbolAvailabilityPlatformName_macCatalyst;
extern NSString * const SFSymbolAvailabilityPlatformName_macOS;
extern NSString * const SFSymbolAvailabilityPlatformName_tvOS;
extern NSString * const SFSymbolAvailabilityPlatformName_watchOS;

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
