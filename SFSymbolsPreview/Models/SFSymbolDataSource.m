//
//  SFSymbolDataSource.m
//  SFSymbolsPreview
//
//  Created by YICAI YANG on 2020/5/28.
//  Copyright © 2020 YICAI YANG. All rights reserved.
//

#import "SFSymbolDataSource.h"
#import "UIColor+HexColor.h"

BOOL IS_IPAD(UIView *targetView)
{
    return [[targetView traitCollection] horizontalSizeClass] == UIUserInterfaceSizeClassRegular;
}

static NSString *const kLastOpenedCategoryKey = @"SFLastOpenedCategoryKey";
SFSymbolCategory *lastOpenedCategeory(void)
{
    NSString *categoryKey = [NSUserDefaults.standardUserDefaults stringForKey:kLastOpenedCategoryKey];
    if ([categoryKey isEqualToString:SFSymbolFavoriteCategoryKey])
    {
        return [SFSymbolCategory favoriteCategory];
    }
    else
    {
        __block SFSymbolCategory *lastOpenedCategory = nil;
        [SFSymbolDataSource.dataSource.categories enumerateObjectsUsingBlock:^(SFSymbolCategory *category, NSUInteger index, BOOL *stop) {
            if ([category.key isEqualToString:categoryKey])
            {
                lastOpenedCategory = category;
                *stop = YES;
            }
        }];
        return lastOpenedCategory ? : SFSymbolDataSource.dataSource.categories.firstObject;
    }
}

void storeUserActivityLastOpenedCategory(SFSymbolCategory *category)
{
    if (!category.key) {
        return;
    }
    [NSUserDefaults.standardUserDefaults setObject:category.key forKey:kLastOpenedCategoryKey];
}


static NSString *const kNumberOfItemsInColumnKey = @"SFNumberOfItemsInColumn";
NSUInteger numberOfItemsInColumn(void)
{
    NSUInteger numberOfItems = [NSUserDefaults.standardUserDefaults integerForKey:kNumberOfItemsInColumnKey];
    return (numberOfItems > 0 && numberOfItems < 5) ? numberOfItems : 4;
}

void storeUserActivityNumberOfItemsInColumn(NSUInteger numberOfItems)
{
    [NSUserDefaults.standardUserDefaults setInteger:numberOfItems forKey:kNumberOfItemsInColumnKey];
}

SFSymbolLayerSetName preferredRenderMode(void)
{
    return (SFSymbolLayerSetName)[NSUserDefaults.standardUserDefaults objectForKey:@"SFRenderMode"] ?: SFSymbolLayerSetNameMonochrome;
}

NSNotificationName const SFPreferredSymbolConfigurationDidChangeNotification = @"SFPreferredSymbolConfigurationDidChangeNotification";
static NSString *const kPreferredImageSymbolConfigurationKey = @"SFPreferredImageSymbolConfiguration";
UIImageSymbolConfiguration *preferredImageSymbolConfiguration(void)
{
    NSData *encodedObject = [NSUserDefaults.standardUserDefaults objectForKey:kPreferredImageSymbolConfigurationKey];
    
    UIImageSymbolConfiguration *configuration = [NSKeyedUnarchiver unarchivedObjectOfClass:[UIImageSymbolConfiguration class] fromData:encodedObject error:nil];
    
    UIFontWeight fontWeight = configuration.weight;
    SFSymbolLayerSetName layerSetName = [NSUserDefaults.standardUserDefaults objectForKey:@"SFRenderMode"] ?: SFSymbolLayerSetNameMonochrome;
    configuration = [UIImageSymbolConfiguration configurationWithWeight:fontWeight];
    
    UIColor *primaryColor = nil;
    
    if ([layerSetName isEqualToString:SFSymbolLayerSetNameHierarchical] || [layerSetName isEqualToString:SFSymbolLayerSetNamePalette]) {
        NSString *primaryColorString = [NSUserDefaults.standardUserDefaults objectForKey:@"SFPrimaryColor"];
        if (primaryColorString) {
            primaryColor = [UIColor colorWithHex:[[primaryColorString componentsSeparatedByString:@":"] lastObject]];
        } else {
            primaryColor = [UIColor labelColor];
        }
        
        if (primaryColor) {
            if (@available(iOS 15.0, *)) {
                configuration = [configuration configurationByApplyingConfiguration:[UIImageSymbolConfiguration configurationWithHierarchicalColor:primaryColor]];
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    UIColor *secondaryColor = nil;
    UIColor *tertiaryColor = nil;
    
    if ([layerSetName isEqualToString:SFSymbolLayerSetNamePalette]) {
        NSString *secondaryColorString = [NSUserDefaults.standardUserDefaults objectForKey:@"SFSecondaryColor"];
        if (secondaryColorString) {
            secondaryColor = [UIColor colorWithHex:[[secondaryColorString componentsSeparatedByString:@":"] lastObject]];
        } else {
            secondaryColor = [UIColor secondaryLabelColor];
        }
        
        NSString *tertiaryColorString = [NSUserDefaults.standardUserDefaults objectForKey:@"SFTertiaryColor"];
        if (tertiaryColorString) {
            tertiaryColor = [UIColor colorWithHex:[[tertiaryColorString componentsSeparatedByString:@":"] lastObject]];
        } else {
            tertiaryColor = [UIColor clearColor];
        }
        
        if (@available(iOS 15.0, *)) {
            configuration = [configuration configurationByApplyingConfiguration:[UIImageSymbolConfiguration configurationWithPaletteColors:@[
                primaryColor, secondaryColor, tertiaryColor,
            ]]];
        } else {
            // Fallback on earlier versions
        }
    }
    
    else if ([layerSetName isEqualToString:SFSymbolLayerSetNameMulticolor]) {
        if (@available(iOS 15.0, *)) {
            configuration = [configuration configurationByApplyingConfiguration:[UIImageSymbolConfiguration configurationPreferringMulticolor]];
        } else {
            // Fallback on earlier versions
        }
    }
    
    return configuration ?: [UIImageSymbolConfiguration unspecifiedConfiguration];
}

void storePreferredImageSymbolConfiguration(UIImageSymbolConfiguration *configuration)
{
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:configuration requiringSecureCoding:YES error:nil];
    [NSUserDefaults.standardUserDefaults setObject:encodedObject forKey:kPreferredImageSymbolConfigurationKey];
}

NSNotificationName const SFSymbolFavoritesDidUpdateNotification = @"SFSymbolFavoritesDidUpdateNotification";


@interface SFSymbolDataSource ()

@end

@implementation SFSymbolDataSource

- (void)loadCategories
{
    NSArray <NSDictionary *> *localCategories = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"categories" ofType:@"plist"]];
    NSMutableArray <SFSymbolCategory *> *cachedCategories = [[NSMutableArray alloc] initWithCapacity:localCategories.count];
    for (NSDictionary *localCategory in localCategories) {
        SFSymbolCategory *cachedCategory = [[SFSymbolCategory alloc] initWithCategoryKey:localCategory[@"key"] categoryName:(localCategory[@"label"] ?: localCategory[@"name"]) imageNamed:localCategory[@"icon"]];
        if (cachedCategory.symbols.count > 0) {
            [cachedCategories addObject:cachedCategory];
        }
    }
    _categories = cachedCategories;
}

- (instancetype)init
{
    if ([super init])
    {
        [self loadCategories];
    }
    return self;
}

+ (instancetype)dataSource
{
    static SFSymbolDataSource *dataSource;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ dataSource = SFSymbolDataSource.new; });
    return dataSource;
}

@end


@implementation UIImage (SharingImageExtension)

- (UIImage *)toSize:(CGSize)size
{
    UIImage *image = nil;
    {
        UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
        [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
        (image = UIGraphicsGetImageFromCurrentImageContext());
        UIGraphicsEndImageContext();
    }
    return image;
}

@end
