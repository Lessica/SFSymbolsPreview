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

- (SFSymbolAvailability *)availability {
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

- (NSDictionary <SFSymbolLayerSetName, SFSymbolAvailability *> *)layerSetAvailabilities {
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

- (NSString *)useRestrictions {
    static NSDictionary <NSString *, NSString *> *allRestrictions = nil;
    static NSDictionary <NSString *, NSString *> *restrictionMappings = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        allRestrictions = [[NSMutableDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"restrictions" ofType:@"plist"]];
        restrictionMappings = [[NSMutableDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"symbol_restrictions" ofType:@"plist"]];
    });
    
    return allRestrictions[restrictionMappings[self.name]];
}

- (NSString *)unicodeString {
    static NSDictionary <NSString *, NSString *> *unicodeMappings = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        unicodeMappings = [[NSMutableDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"symbol_unicodes" ofType:@"plist"]];
    });
    
    return unicodeMappings[self.name];
}

@end
