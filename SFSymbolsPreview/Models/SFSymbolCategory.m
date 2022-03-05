//
//  SFSymbolCategory.m
//  SFSymbolsPreview
//
//  Created by YICAI YANG on 2020/5/28.
//  Copyright © 2020 YICAI YANG. All rights reserved.
//

#import "SFSymbolCategory.h"


@interface SFSymbolCategory()

@property (nonatomic, strong) NSMutableArray <SFSymbol *> *mutableSymbols;
@property (nonatomic, strong) NSMutableSet <NSString *> *mutableSymbolNames;

@end

@implementation SFSymbolCategory

- (instancetype)initWithCategoryKey:(NSString *)categoryKey categoryName:(NSString *)categoryName
{
    return [self initWithCategoryKey:categoryKey categoryName:categoryName imageNamed:nil];
}

- (instancetype)initWithCategoryKey:(NSString *)categoryKey categoryName:(NSString *)categoryName imageNamed:(NSString *)imageNamed
{
    if( [super init] )
    {
        _key = categoryKey;
        _name = categoryName;
        _imageNamed = imageNamed;
        
        [self loadSymbols];
    }
    return self;
}

- (instancetype)initWithSearchResultsCategoryWithSymbols:(NSArray <SFSymbol *> *)symbols
{
    if( [super init] )
    {
        _name = NSLocalizedString(@"Search Results", nil);
        _mutableSymbols = [symbols mutableCopy];
        
        NSMutableSet <NSString *> *cachedSymbolNames = [[NSMutableSet alloc] initWithCapacity:symbols.count];
        for (SFSymbol *symbol in symbols) {
            [cachedSymbolNames addObject:symbol.name];
        }
        _mutableSymbolNames = cachedSymbolNames;
    }
    return self;
}

- (NSArray <SFSymbol *> *)symbols {
    return _mutableSymbols;
}

- (void)loadSymbols
{
    static NSMutableArray <NSString *> *uncategoriedSymbols = nil;
    static NSDictionary <NSString *, NSArray <NSString *> *> *categoryMappings = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray <NSString *> *localSymbols = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"symbols" ofType:@"plist"]];
        uncategoriedSymbols = [[NSMutableArray alloc] initWithCapacity:localSymbols.count];
        NSMutableDictionary <NSString *, NSMutableArray <NSString *> *> *cachedCategoryMappings = [[NSMutableDictionary alloc] init];
        NSDictionary <NSString *, NSArray <NSString *> *> *localCategoryMappings = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"symbol_categories" ofType:@"plist"]];
        for (NSString *symbolName in localSymbols) {
            NSArray <NSString *> *categoryNames = localCategoryMappings[symbolName];
            if (!categoryNames) {
                [uncategoriedSymbols addObject:symbolName];
                continue;
            }
            for (NSString *categoryName in categoryNames) {
                if (!cachedCategoryMappings[categoryName]) {
                    cachedCategoryMappings[categoryName] = [[NSMutableArray alloc] init];
                }
                [cachedCategoryMappings[categoryName] addObject:symbolName];
            }
        }
        categoryMappings = cachedCategoryMappings;
    });
    
    if (categoryMappings[self.key])
    {
        [self loadSymbolsWithSymbolNames:categoryMappings[self.key]];
    } else if ([self.key isEqualToString:@"all"]) {
        [self loadSymbolsWithSymbolNames:uncategoriedSymbols];
        for (NSArray <NSString *> *symbolNames in [categoryMappings objectEnumerator]) {
            [self loadSymbolsWithSymbolNames:symbolNames];
        }
    }
}

- (void)loadSymbolsWithSymbolNames:(NSArray <NSString *> *)symbolNames
{
    if (!_mutableSymbols) {
        _mutableSymbols = [[NSMutableArray alloc] initWithCapacity:symbolNames.count];
        _mutableSymbolNames = [[NSMutableSet alloc] initWithCapacity:symbolNames.count];
    }
    [symbolNames enumerateObjectsUsingBlock:^(NSString *name, NSUInteger index, BOOL *stop) {
        if (![self->_mutableSymbolNames containsObject:name]) {
            [self->_mutableSymbolNames addObject:name];
            SFSymbol *symbol = [SFSymbol symbolWithName:name];
            if ([symbol.availability isCompatibleWithCurrentPlatform]) {
                [self->_mutableSymbols addObject:symbol];
            }
        }
    }];
    
    /// Sort (Optional)
//    [_mutableSymbols sortUsingComparator:^NSComparisonResult(SFSymbol *obj1, SFSymbol *obj2) {
//        return [obj1.name localizedStandardCompare:obj2.name];
//    }];
}

@end
