//
//  SFSymbol.m
//  SFSymbolsPreview
//
//  Created by YICAI YANG on 2020/5/28.
//  Copyright © 2020 YICAI YANG. All rights reserved.
//

#import "SFSymbolDataSource.h"
#import "SFSymbol.h"


NSString * const SFSymbolLayerSetNameMonochrome = @"monochrome";
NSString * const SFSymbolLayerSetNameHierarchical = @"hierarchical";
NSString * const SFSymbolLayerSetNamePalette = @"palette";
NSString * const SFSymbolLayerSetNameMulticolor = @"multicolor";

NSString *SFSymbolLayerSetDisplayName(SFSymbolLayerSetName name)
{
    if ([name isEqualToString:SFSymbolLayerSetNameMonochrome]) {
        return @"Monochrome";
    }
    if ([name isEqualToString:SFSymbolLayerSetNameHierarchical]) {
        return @"Hierarchical";
    }
    if ([name isEqualToString:SFSymbolLayerSetNamePalette]) {
        return @"Palette";
    }
    if ([name isEqualToString:SFSymbolLayerSetNameMulticolor]) {
        return @"Multicolor";
    }
    return nil;
}

@interface SFSymbol ()

@end

@implementation SFSymbol

@synthesize variantName = _variantName;
@synthesize symbolVariants = _symbolVariants;
@synthesize symbolAliases = _symbolAliases;
@synthesize layerSetAvailabilities = _layerSetAvailabilities;
@synthesize availabilityDictionary = _availabilityDictionary;

+ (instancetype)symbolWithName:(NSString *)name
{
    return [SFSymbol.alloc initWithName:name attributedName:nil];
}

+ (instancetype)symbolWithAttributedName:(NSAttributedString *)attributedName
{
    return [SFSymbol.alloc initWithName:attributedName.string attributedName:attributedName];
}

+ (NSDictionary *)_nameAvailabilityObject
{
    static NSDictionary *nameAvailabilities = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        nameAvailabilities = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"name_availability" ofType:@"plist"]];
    });
    
    return nameAvailabilities;
}

+ (SFSymbolAvailability *)nameAvailabilityOfSymbolWithName:(NSString *)name
{
    static NSMutableDictionary <NSString *, SFSymbolAvailability *> *allAvailabilitys = nil;
    static NSMutableDictionary <NSString *, NSString *> *availabilityMappings = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary *localAvailabilitys = [SFSymbol _nameAvailabilityObject];
        NSDictionary <NSString *, NSDictionary *> *localYearToReleaseMap = localAvailabilitys[@"year_to_release"];
        
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
    
    return allAvailabilitys[availabilityMappings[name]];
}

+ (NSDictionary *)_layerSetAvailabilityObject
{
    static NSDictionary *layerSetAvailabilities = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        layerSetAvailabilities = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"layerset_availability" ofType:@"plist"]];
    });
    
    return layerSetAvailabilities;
}

+ (NSDictionary <SFSymbolLayerSetName, SFSymbolAvailability *> *)layerSetAvailabilityOfSymbolWithName:(NSString *)name
{
    static NSMutableDictionary <NSString *, SFSymbolAvailability *> *allAvailabilitys = nil;
    static NSMutableDictionary <NSString *, NSDictionary <SFSymbolLayerSetName, NSString *> *> *availabilityMappings = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary *localAvailabilitys = [SFSymbol _layerSetAvailabilityObject];
        NSDictionary <NSString *, NSDictionary *> *localYearToReleaseMap = localAvailabilitys[@"year_to_release"];
        
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
    
    NSDictionary <SFSymbolLayerSetName, NSString *> *availabilityMapping = availabilityMappings[name];
    NSMutableDictionary <SFSymbolLayerSetName, SFSymbolAvailability *> *availabilities = [[NSMutableDictionary alloc] initWithCapacity:availabilityMapping.count];
    for (SFSymbolLayerSetName availabilityName in availabilityMapping) {
        NSString *availabilityYear = availabilityMapping[availabilityName];
        if (!allAvailabilitys[availabilityYear]) {
            continue;
        }
        [availabilities setObject:allAvailabilitys[availabilityYear] forKey:availabilityName];
    }
    return [availabilities copy];
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

+ (NSString *)variantNameOfSymbolWithSuffix:(NSString *)suffix
{
    static NSDictionary <NSString *, NSString *> *variantNames = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        variantNames = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"symbol_variant_scripts" ofType:@"json"]] options:kNilOptions error:nil];
    });
    
    return variantNames[suffix];
}

- (NSString *)variantName
{
    if (!_variantName) {
        if (!self.symbolVariants.count) {
            NSString *variantSuffix = [[self.name componentsSeparatedByString:@"."] lastObject];
            if ([variantSuffix isEqualToString:@"rtl"]) {
                _variantName = @"Right-to-Left";
            } else {
                _variantName = [SFSymbol variantNameOfSymbolWithSuffix:variantSuffix];
            }
        } else {
            SFSymbol *firstSymbolVariant = self.symbolVariants.firstObject;
            NSString *variantSuffix = [[firstSymbolVariant.name componentsSeparatedByString:@"."] lastObject];
            if ([variantSuffix isEqualToString:@"rtl"]) {
                _variantName = @"Left-to-Right";
            } else {
                _variantName = @"Latin";
            }
        }
    }
    return _variantName;
}

- (NSArray <SFSymbol *> *)symbolVariants
{
    static NSArray <NSString *> *allVariants = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary *localAvailabilitys = [SFSymbol _nameAvailabilityObject];
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

- (NSArray <SFSymbol *> *)symbolAliases
{
    static NSDictionary <NSString *, NSString *> *allAliases = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        allAliases = [NSDictionary.alloc initWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"name_aliases_strings" ofType:@"txt"]];
    });
    
    if (!_symbolAliases) {
        NSMutableArray <NSString *> *aliasNames = [[NSMutableArray alloc] init];
        for (NSString *aliasName in allAliases) {
            NSString *aliasValue = allAliases[aliasName];
            if ([aliasValue isEqualToString:self.name]) {
                [aliasNames addObject:aliasName];
            }
        }
        NSMutableArray <SFSymbol *> *symbolAliases = [[NSMutableArray alloc] initWithCapacity:aliasNames.count];
        for (NSString *aliasName in aliasNames) {
            [symbolAliases addObject:[SFSymbol symbolWithName:aliasName]];
        }
        _symbolAliases = symbolAliases;
    }
    return _symbolAliases;
}

- (SFSymbolAvailability *)availability
{
    return [SFSymbol nameAvailabilityOfSymbolWithName:self.name];
}

- (NSDictionary <SFSymbolLayerSetName, SFSymbolAvailability *> *)layerSetAvailabilities
{
    if (!_layerSetAvailabilities) {
        NSMutableDictionary <SFSymbolLayerSetName, SFSymbolAvailability *> *availabilities = [[SFSymbol layerSetAvailabilityOfSymbolWithName:self.name] mutableCopy];
        if (self.availability) {
            [availabilities setObject:self.availability forKey:SFSymbolLayerSetNameMonochrome];
        }
        if (availabilities[SFSymbolLayerSetNameHierarchical]) {
            [availabilities setObject:availabilities[SFSymbolLayerSetNameHierarchical] forKey:SFSymbolLayerSetNamePalette];
        }
        _layerSetAvailabilities = availabilities;
    }
    return _layerSetAvailabilities;
}

+ (NSString *)useRestrictionsOfSymbolWithName:(NSString *)name
{
    static NSDictionary <NSString *, NSString *> *allRestrictions = nil;
    static NSDictionary <NSString *, NSString *> *restrictionMappings = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        allRestrictions = [[NSMutableDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"restrictions" ofType:@"plist"]];
        restrictionMappings = [[NSMutableDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"symbol_restrictions" ofType:@"plist"]];
    });
    
    return allRestrictions[restrictionMappings[name]];
}

- (NSString *)useRestrictions
{
    return [SFSymbol useRestrictionsOfSymbolWithName:self.name];
}

+ (NSString *)unicodeStringOfSymbolWithName:(NSString *)name
{
    static NSDictionary <NSString *, NSString *> *unicodeMappings = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        unicodeMappings = [[NSMutableDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"symbol_unicodes" ofType:@"plist"]];
    });
    
    return unicodeMappings[name];
}

- (NSString *)unicodeString
{
    return [SFSymbol unicodeStringOfSymbolWithName:self.name];
}

- (NSDictionary *)availabilityDictionary {
    if (!_availabilityDictionary) {
        NSMutableDictionary *object = [[NSMutableDictionary alloc] init];
        for (SFSymbolLayerSetName layerSetName in self.layerSetAvailabilities) {
            SFSymbolAvailability *availability = self.layerSetAvailabilities[layerSetName];
            [object setObject:availability.availabilityDictionary forKey:SFSymbolLayerSetDisplayName(layerSetName)];
        }
        [object setObject:self.name forKey:@"__KEY__"];
        [object setObject:@"" forKey:@"__VALUE__"];
        [object setObject:@[
            SFSymbolLayerSetDisplayName(SFSymbolLayerSetNameMonochrome),
            SFSymbolLayerSetDisplayName(SFSymbolLayerSetNameHierarchical),
            SFSymbolLayerSetDisplayName(SFSymbolLayerSetNamePalette),
            SFSymbolLayerSetDisplayName(SFSymbolLayerSetNameMulticolor),
        ] forKey:@"__KEYS__"];
        _availabilityDictionary = object;
    }
    return _availabilityDictionary;
}

@end
