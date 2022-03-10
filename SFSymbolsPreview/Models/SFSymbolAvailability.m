//
//  SFSymbolAvailability.m
//  SFSymbolsPreview
//
//  Created by Rachel on 3/5/22.
//  Copyright © 2022 YICAI YANG. All rights reserved.
//

#import "SFSymbolAvailability.h"
#if TARGET_OS_MACCATALYST
#import <UIKit/UIKit.h>
#endif


NSString * const SFSymbolAvailabilityPlatformName_iOS = @"iOS";
NSString * const SFSymbolAvailabilityPlatformName_macCatalyst = @"macCatalyst";
NSString * const SFSymbolAvailabilityPlatformName_macOS = @"macOS";
NSString * const SFSymbolAvailabilityPlatformName_tvOS = @"tvOS";
NSString * const SFSymbolAvailabilityPlatformName_watchOS = @"watchOS";

@interface SFSymbolAvailability ()

@property (nonatomic, strong) NSMutableDictionary *internalDictionary;

@end

@implementation SFSymbolAvailability

@synthesize availabilityDictionary = _availabilityDictionary;

- (instancetype)initWithYearToRelease:(NSString *)yearToRelease {
    if (self = [super init]) {
        _yearToRelease = yearToRelease;
        _internalDictionary = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (NSDictionary *)availabilityDictionary {
    if (!_availabilityDictionary) {
        NSMutableDictionary *availabilityDictionary = [_internalDictionary mutableCopy];
        [availabilityDictionary setObject:self.version forKey:@"__VALUE__"];
        if (_internalDictionary[SFSymbolAvailabilityPlatformName_iOS]) {
            availabilityDictionary[SFSymbolAvailabilityPlatformName_macCatalyst] = _internalDictionary[SFSymbolAvailabilityPlatformName_iOS];
        }
        _availabilityDictionary = availabilityDictionary;
    }
    return _availabilityDictionary;
}

- (void)setAvailabilityValue:(NSString *)availabilityValue forPlatform:(SFSymbolAvailabilityPlatformName)platform {
    [_internalDictionary setObject:availabilityValue forKey:platform];
}

- (NSString *)availabilityValueForPlatform:(SFSymbolAvailabilityPlatformName)platform {
    if ([platform isEqualToString:SFSymbolAvailabilityPlatformName_macCatalyst]) {
        platform = SFSymbolAvailabilityPlatformName_iOS;
    }
    return [_internalDictionary objectForKey:platform];
}

- (BOOL)isCompatibleWithCurrentPlatform {
    SFSymbolAvailabilityPlatformName currentPlatform = nil;
    if (@available(iOS 13, *)) {
        currentPlatform = SFSymbolAvailabilityPlatformName_iOS;
    }
    if (@available(macOS 10.15, *)) {
        currentPlatform = SFSymbolAvailabilityPlatformName_macOS;
    }
    if (@available(tvOS 13, *)) {
        currentPlatform = SFSymbolAvailabilityPlatformName_tvOS;
    }
    if (@available(watchOS 6, *)) {
        currentPlatform = SFSymbolAvailabilityPlatformName_watchOS;
    }
    if (@available(macCatalyst 13, *)) {
        currentPlatform = SFSymbolAvailabilityPlatformName_macCatalyst;
    }
    NSString *availabilityValue = [self availabilityValueForPlatform:currentPlatform];
    NSMutableArray <NSString *> *availabilityVersionValues = [[availabilityValue componentsSeparatedByString:@"."] mutableCopy];
    NSInteger majorVersion = [[availabilityVersionValues firstObject] integerValue];
    [availabilityVersionValues removeObjectAtIndex:0];
    NSInteger minorVersion = [[availabilityVersionValues firstObject] integerValue];
    [availabilityVersionValues removeObjectAtIndex:0];
    NSInteger patchVersion = [[availabilityVersionValues firstObject] integerValue];
    if ([[NSProcessInfo processInfo] isMacCatalystApp]) {
#if TARGET_OS_MACCATALYST
        return [[[UIDevice currentDevice] systemVersion] localizedStandardCompare:availabilityValue] != NSOrderedAscending;
#endif
    }
    return [[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:(NSOperatingSystemVersion) {majorVersion, minorVersion, patchVersion}];
}

+ (nullable SFSymbolAvailabilityPlatformName)platformWithName:(NSString *)platformName {
    if ([platformName isEqualToString:@"iOS"]) {
        return SFSymbolAvailabilityPlatformName_iOS;
    }
    if ([platformName isEqualToString:@"macCatalyst"]) {
        return SFSymbolAvailabilityPlatformName_macCatalyst;
    }
    if ([platformName isEqualToString:@"macOS"]) {
        return SFSymbolAvailabilityPlatformName_macOS;
    }
    if ([platformName isEqualToString:@"tvOS"]) {
        return SFSymbolAvailabilityPlatformName_tvOS;
    }
    if ([platformName isEqualToString:@"watchOS"]) {
        return SFSymbolAvailabilityPlatformName_watchOS;
    }
    return nil;
}

- (NSString *)description {
    NSMutableString *s = [NSMutableString string];
    if ([self availabilityValueForPlatform:SFSymbolAvailabilityPlatformName_iOS]) {
        [s appendFormat:@"• iOS %@+\n", [self availabilityValueForPlatform:SFSymbolAvailabilityPlatformName_iOS]];
    }
    if ([self availabilityValueForPlatform:SFSymbolAvailabilityPlatformName_macOS]) {
        [s appendFormat:@"• macOS %@+\n", [self availabilityValueForPlatform:SFSymbolAvailabilityPlatformName_macOS]];
    }
    if ([self availabilityValueForPlatform:SFSymbolAvailabilityPlatformName_macCatalyst]) {
        [s appendFormat:@"• Mac Catalyst %@+\n", [self availabilityValueForPlatform:SFSymbolAvailabilityPlatformName_macCatalyst]];
    }
    if ([self availabilityValueForPlatform:SFSymbolAvailabilityPlatformName_tvOS]) {
        [s appendFormat:@"• tvOS %@+\n", [self availabilityValueForPlatform:SFSymbolAvailabilityPlatformName_tvOS]];
    }
    if ([self availabilityValueForPlatform:SFSymbolAvailabilityPlatformName_watchOS]) {
        [s appendFormat:@"• watchOS %@+\n", [self availabilityValueForPlatform:SFSymbolAvailabilityPlatformName_watchOS]];
    }
    if (!s.length) {
        return [super description];
    }
    return [s substringToIndex:s.length - 1];
}

- (NSString *)version {
    NSMutableArray <NSString *> *yearToReleaseArray = [[[[self.yearToRelease componentsSeparatedByString:@"."] reverseObjectEnumerator] allObjects] mutableCopy];
    NSInteger majorVersion = [[yearToReleaseArray lastObject] integerValue];
    if (majorVersion > 2018) {
        majorVersion -= 2018;
    }
    [yearToReleaseArray removeLastObject];
    NSInteger minorVersion = [[yearToReleaseArray lastObject] integerValue];
    [yearToReleaseArray removeLastObject];
    NSInteger patchVersion = [[yearToReleaseArray lastObject] integerValue];
    if (majorVersion > 0 && minorVersion > 0 && patchVersion > 0) {
        return [NSString stringWithFormat:@"%ld.%ld.%ld", majorVersion, minorVersion, patchVersion];
    }
    if (majorVersion > 0 && minorVersion > 0) {
        return [NSString stringWithFormat:@"%ld.%ld", majorVersion, minorVersion];
    }
    return [NSString stringWithFormat:@"%ld.0", majorVersion];
}

@end
