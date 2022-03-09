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

@interface SFSymbolAvailability ()

@property (nonatomic, strong) NSMutableDictionary *internalDictionary;

@end

@implementation SFSymbolAvailability

- (instancetype)initWithYearToRelease:(NSString *)yearToRelease {
    if (self = [super init]) {
        _yearToRelease = yearToRelease;
        _internalDictionary = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (NSDictionary *)availabilityDictionary {
    return _internalDictionary;
}

- (void)setAvailabilityValue:(NSString *)availabilityValue forPlatform:(SFSymbolAvailabilityPlatform)platform {
    [_internalDictionary setObject:availabilityValue forKey:@(platform)];
}

- (NSString *)availabilityValueForPlatform:(SFSymbolAvailabilityPlatform)platform {
    if (platform == SFSymbolAvailabilityPlatform_macCatalyst) {
        platform = SFSymbolAvailabilityPlatform_iOS;
    }
    return [_internalDictionary objectForKey:@(platform)];
}

- (BOOL)isCompatibleWithCurrentPlatform {
    SFSymbolAvailabilityPlatform currentPlatform = NSUIntegerMax;
    if (@available(iOS 13, *)) {
        currentPlatform = SFSymbolAvailabilityPlatform_iOS;
    }
    if (@available(macOS 10.15, *)) {
        currentPlatform = SFSymbolAvailabilityPlatform_macOS;
    }
    if (@available(tvOS 13, *)) {
        currentPlatform = SFSymbolAvailabilityPlatform_tvOS;
    }
    if (@available(watchOS 6, *)) {
        currentPlatform = SFSymbolAvailabilityPlatform_watchOS;
    }
    if (@available(macCatalyst 13, *)) {
        currentPlatform = SFSymbolAvailabilityPlatform_macCatalyst;
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

+ (SFSymbolAvailabilityPlatform)platformWithName:(NSString *)platformName {
    if ([platformName isEqualToString:@"iOS"]) {
        return SFSymbolAvailabilityPlatform_iOS;
    }
    if ([platformName isEqualToString:@"macCatalyst"]) {
        return SFSymbolAvailabilityPlatform_macCatalyst;
    }
    if ([platformName isEqualToString:@"macOS"]) {
        return SFSymbolAvailabilityPlatform_macOS;
    }
    if ([platformName isEqualToString:@"tvOS"]) {
        return SFSymbolAvailabilityPlatform_tvOS;
    }
    if ([platformName isEqualToString:@"watchOS"]) {
        return SFSymbolAvailabilityPlatform_watchOS;
    }
    NSAssert(false, @"invalid platform name");
    return NSUIntegerMax;
}

- (NSString *)description {
    NSMutableString *s = [NSMutableString string];
    if ([self availabilityValueForPlatform:SFSymbolAvailabilityPlatform_iOS]) {
        [s appendFormat:@"• iOS %@+\n", [self availabilityValueForPlatform:SFSymbolAvailabilityPlatform_iOS]];
    }
    if ([self availabilityValueForPlatform:SFSymbolAvailabilityPlatform_macOS]) {
        [s appendFormat:@"• macOS %@+\n", [self availabilityValueForPlatform:SFSymbolAvailabilityPlatform_macOS]];
    }
    if ([self availabilityValueForPlatform:SFSymbolAvailabilityPlatform_macCatalyst]) {
        [s appendFormat:@"• Mac Catalyst %@+\n", [self availabilityValueForPlatform:SFSymbolAvailabilityPlatform_macCatalyst]];
    }
    if ([self availabilityValueForPlatform:SFSymbolAvailabilityPlatform_tvOS]) {
        [s appendFormat:@"• tvOS %@+\n", [self availabilityValueForPlatform:SFSymbolAvailabilityPlatform_tvOS]];
    }
    if ([self availabilityValueForPlatform:SFSymbolAvailabilityPlatform_watchOS]) {
        [s appendFormat:@"• watchOS %@+\n", [self availabilityValueForPlatform:SFSymbolAvailabilityPlatform_watchOS]];
    }
    if (!s.length) {
        return [super description];
    }
    return [s substringToIndex:s.length - 1];
}

@end
