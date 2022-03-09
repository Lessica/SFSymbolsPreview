//
//  SFSymbol.m
//  SFSymbolsPreview
//
//  Created by YICAI YANG on 2020/5/28.
//  Copyright © 2020 YICAI YANG. All rights reserved.
//

#import "SFSymbolDataSource.h"
#import "SFSymbol.h"


@interface SFSymbol ()

@end

@implementation SFSymbol

@synthesize variantName = _variantName;
@synthesize symbolVariants = _symbolVariants;
@synthesize layerSetAvailabilities = _layerSetAvailabilities;

+ (instancetype)symbolWithName:(NSString *)name
{
    return [SFSymbol.alloc initWithName:name attributedName:nil];
}

+ (instancetype)symbolWithAttributedName:(NSAttributedString *)attributedName
{
    return [SFSymbol.alloc initWithName:attributedName.string attributedName:attributedName];
}

- (UIImage *)image
{
    return [UIImage systemImageNamed:self.name withConfiguration:[UIImageSymbolConfiguration configurationWithWeight:preferredImageSymbolWeight()]];
}

- (instancetype)initWithName:(NSString *)name attributedName:(NSAttributedString *)attributedName
{
    if ([super init])
    {
        _name = name;
        _attributedName = attributedName;
    }
    return self;
}

- (NSString *)variantName
{
    static NSDictionary <NSString *, NSString *> *variantNames = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        variantNames = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"symbol_variant_scripts" ofType:@"json"]] options:kNilOptions error:nil];
    });
    
    if (!_variantName) {
        NSString *variantSuffix = [[self.name componentsSeparatedByString:@"."] lastObject];
        if ([variantSuffix isEqualToString:@"rtl"]) {
            _variantName = NSLocalizedString(@"Right-to-Left", nil);
        } else {
            _variantName = variantNames[variantSuffix] ?: @"Latin";
        }
    }
    return _variantName;
}

- (NSArray <SFSymbol *> *)symbolVariants
{
    static NSArray <NSString *> *allVariants = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary *localAvailabilitys = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"name_availability" ofType:@"plist"]];
        allVariants = [localAvailabilitys[@"symbols"] allKeys];
    });
    
    if (!_symbolVariants) {
        NSString *variantPrefix = [self.name stringByAppendingString:@"."];
        NSMutableArray <NSString *> *symbolVariantNames = [[NSMutableArray alloc] init];
        for (NSString *symbolVariantName in allVariants) {
            if ([symbolVariantName hasPrefix:variantPrefix] && (symbolVariantName.length - variantPrefix.length == 2 || (symbolVariantName.length - variantPrefix.length == 3 && [[symbolVariantName substringFromIndex:symbolVariantName.length - 3] isEqualToString:@"rtl"])))
            {
                [symbolVariantNames addObject:symbolVariantName];
            }
        }
        [symbolVariantNames sortUsingSelector:@selector(localizedStandardCompare:)];
        NSMutableArray <SFSymbol *> *symbolVariants = [[NSMutableArray alloc] initWithCapacity:symbolVariantNames.count];
        for (NSString *symbolVariantName in symbolVariantNames) {
            [symbolVariants addObject:[SFSymbol symbolWithName:symbolVariantName]];
        }
        _symbolVariants = symbolVariants;
    }
    return _symbolVariants;
}

- (SFSymbolAvailability *)availability
{
    static NSMutableDictionary <NSString *, SFSymbolAvailability *> *allAvailabilitys = nil;
    static NSMutableDictionary <NSString *, NSString *> *availabilityMappings = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary *localAvailabilitys = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"name_availability" ofType:@"plist"]];
        NSDictionary *localYearToReleaseMap = localAvailabilitys[@"year_to_release"];
        
        allAvailabilitys = [[NSMutableDictionary alloc] init];
        for (NSString *localYearToReleaseName in localYearToReleaseMap) {
            SFSymbolAvailability *availabilityItem = [[SFSymbolAvailability alloc] initWithYearToRelease:localYearToReleaseName];
            NSDictionary *localYearToRelease = localYearToReleaseMap[localYearToReleaseName];
            for (NSString *platformName in localYearToRelease) {
                NSString *availabilityValue = localYearToRelease[platformName];
                [availabilityItem setAvailabilityValue:availabilityValue forPlatform:[SFSymbolAvailability platformWithName:platformName]];
            }
            [allAvailabilitys setObject:availabilityItem forKey:localYearToReleaseName];
        }
        
        availabilityMappings = [localAvailabilitys[@"symbols"] mutableCopy];
    });
    
    return allAvailabilitys[availabilityMappings[self.name]];
}

- (NSDictionary <SFSymbolLayerSetName, SFSymbolAvailability *> *)layerSetAvailabilities
{
    static NSMutableDictionary <NSString *, SFSymbolAvailability *> *allAvailabilitys = nil;
    static NSMutableDictionary <NSString *, NSDictionary <SFSymbolLayerSetName, NSString *> *> *availabilityMappings = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary *localAvailabilitys = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"layerset_availability" ofType:@"plist"]];
        NSDictionary *localYearToReleaseMap = localAvailabilitys[@"year_to_release"];
        
        allAvailabilitys = [[NSMutableDictionary alloc] init];
        for (NSString *localYearToReleaseName in localYearToReleaseMap) {
            SFSymbolAvailability *availabilityItem = [[SFSymbolAvailability alloc] initWithYearToRelease:localYearToReleaseName];
            NSDictionary *localYearToRelease = localYearToReleaseMap[localYearToReleaseName];
            for (NSString *platformName in localYearToRelease) {
                NSString *availabilityValue = localYearToRelease[platformName];
                [availabilityItem setAvailabilityValue:availabilityValue forPlatform:[SFSymbolAvailability platformWithName:platformName]];
            }
            [allAvailabilitys setObject:availabilityItem forKey:localYearToReleaseName];
        }
        
        availabilityMappings = [localAvailabilitys[@"symbols"] mutableCopy];
    });
    
    if (!_layerSetAvailabilities) {
        NSDictionary <SFSymbolLayerSetName, NSString *> *availabilityMapping = availabilityMappings[self.name];
        NSMutableDictionary <SFSymbolLayerSetName, SFSymbolAvailability *> *availabilities = [[NSMutableDictionary alloc] initWithCapacity:availabilityMapping.count];
        for (SFSymbolLayerSetName availabilityName in availabilityMapping) {
            if (!allAvailabilitys[availabilityName]) {
                continue;
            }
            [availabilities setObject:allAvailabilitys[availabilityName] forKey:availabilityName];
        }
        _layerSetAvailabilities = availabilities;
    }
    return _layerSetAvailabilities;
}

- (NSString *)useRestrictions
{
    static NSDictionary <NSString *, NSString *> *allRestrictions = nil;
    static NSDictionary <NSString *, NSString *> *restrictionMappings = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        allRestrictions = [[NSMutableDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"restrictions" ofType:@"plist"]];
        restrictionMappings = [[NSMutableDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"symbol_restrictions" ofType:@"plist"]];
    });
    
    return allRestrictions[restrictionMappings[self.name]];
}

- (NSString *)unicodeString
{
    static NSDictionary <NSString *, NSString *> *unicodeMappings = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        unicodeMappings = [[NSMutableDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"symbol_unicodes" ofType:@"plist"]];
    });
    
    return unicodeMappings[self.name];
}

@end
