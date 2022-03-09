//
//  SFSymbolDataSource.m
//  SFSymbolsPreview
//
//  Created by YICAI YANG on 2020/5/28.
//  Copyright © 2020 YICAI YANG. All rights reserved.
//

#import "SFSymbolDataSource.h"

BOOL IS_IPAD(UIView *targetView)
{
    return [[targetView traitCollection] horizontalSizeClass] == UIUserInterfaceSizeClassRegular;
}

static NSString *const kLastOpenedCategoryNameKey = @"LastOpenedCategoryName";
SFSymbolCategory *lastOpenedCategeory(void)
{
    NSString *name;
    __block SFSymbolCategory *lastOpenedCategory;
    
    name = [NSUserDefaults.standardUserDefaults stringForKey:kLastOpenedCategoryNameKey];
    if (name)
    {
        [SFSymbolDataSource.datasource.categories enumerateObjectsUsingBlock:^(SFSymbolCategory *category, NSUInteger index, BOOL *stop) {
            if ([category.name isEqualToString:name])
            {
                lastOpenedCategory = category;
                *stop = YES;
            }
        }];
    }
    return lastOpenedCategory ? : SFSymbolDataSource.datasource.categories.firstObject;
}

void storeUserActivityLastOpenedCategory(SFSymbolCategory *category)
{
    [NSUserDefaults.standardUserDefaults setObject:category.name forKey:kLastOpenedCategoryNameKey];
}


static NSString *const kNumberOfItemsInColumnKey = @"NumberOfItemsInColumn";
NSUInteger numberOfItemsInColumn(void)
{
    NSUInteger numberOfItems = [NSUserDefaults.standardUserDefaults integerForKey:kNumberOfItemsInColumnKey];
    return (numberOfItems > 0 && numberOfItems < 5) ? numberOfItems : 4;
}

void storeUserActivityNumberOfItemsInColumn(NSUInteger numberOfItems)
{
    [NSUserDefaults.standardUserDefaults setInteger:numberOfItems forKey:kNumberOfItemsInColumnKey];
}

NSNotificationName const PreferredSymbolWeightDidChangeNotification = @"PreferredSymbolWeightDidChangeNotification";
static NSString *const kPreferredImageSymbolWeightKey = @"PreferredImageSymbolWeight";
UIImageSymbolWeight preferredImageSymbolWeight(void)
{
    NSUInteger weight = [NSUserDefaults.standardUserDefaults integerForKey:kPreferredImageSymbolWeightKey];
    return (weight >= UIImageSymbolWeightUltraLight && weight <= UIImageSymbolWeightBlack) ? weight : UIImageSymbolWeightRegular;
}

void storeUserActivityPreferredImageSymbolWeight(UIImageSymbolWeight weight)
{
    [NSUserDefaults.standardUserDefaults setInteger:weight forKey:kPreferredImageSymbolWeightKey];
}


@interface SFSymbolDataSource ()

@end

@implementation SFSymbolDataSource

- (void)loadCategories
{
    NSArray <NSDictionary *> *localCategories = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"categories" ofType:@"plist"]];
    NSMutableArray <SFSymbolCategory *> *cachedCategories = [[NSMutableArray alloc] initWithCapacity:localCategories.count];
    for (NSDictionary *localCategory in localCategories) {
        [cachedCategories addObject:[[SFSymbolCategory alloc] initWithCategoryKey:localCategory[@"key"] categoryName:localCategory[@"name"] imageNamed:localCategory[@"icon"]]];
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

+ (instancetype)datasource
{
    static SFSymbolDataSource *datasource;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ datasource = SFSymbolDataSource.new; });
    return datasource;
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
