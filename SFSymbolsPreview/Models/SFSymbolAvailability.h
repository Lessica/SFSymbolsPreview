//
//  SFSymbolAvailability.h
//  SFSymbolsPreview
//
//  Created by Rachel on 3/5/22.
//  Copyright © 2022 YICAI YANG. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    SFSymbolAvailabilityPlatform_iOS = 0,
    SFSymbolAvailabilityPlatform_macCatalyst,
    SFSymbolAvailabilityPlatform_macOS,
    SFSymbolAvailabilityPlatform_tvOS,
    SFSymbolAvailabilityPlatform_watchOS,
} SFSymbolAvailabilityPlatform;

@interface SFSymbolAvailability : NSObject

@property (nonatomic, copy, readonly) NSString *yearToRelease;
@property (nonatomic, strong, readonly) NSDictionary *availabilityDictionary;

- (instancetype)initWithYearToRelease:(NSString *)yearToRelease;

- (void)setAvailabilityValue:(NSString *)availabilityValue forPlatform:(SFSymbolAvailabilityPlatform)platform;
- (NSString *)availabilityValueForPlatform:(SFSymbolAvailabilityPlatform)platform;
- (BOOL)isCompatibleWithCurrentPlatform;

+ (SFSymbolAvailabilityPlatform)platformWithName:(NSString *)platformName;

@end

NS_ASSUME_NONNULL_END
