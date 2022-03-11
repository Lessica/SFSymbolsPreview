//
//  SFSymbolCategory.m
//  SFSymbolsPreview
//
//  Created by YICAI YANG on 2020/5/28.
//  Copyright © 2020 YICAI YANG. All rights reserved.
//

#import "SFSymbolCategory.h"


@interface SFSymbolCategory ()

@property (nonatomic, strong) NSMutableArray <SFSymbol *> *mutableSymbols;
@property (nonatomic, strong) NSMutableSet <NSString *> *mutableSymbolNames;

@end

@implementation SFSymbolCategory

@synthesize tokenizedSymbols = _tokenizedSymbols;

- (instancetype)initWithCategoryKey:(NSString *)categoryKey categoryName:(NSString *)categoryName
{
    return [self initWithCategoryKey:categoryKey categoryName:categoryName imageNamed:nil];
}

- (instancetype)initWithCategoryKey:(NSString *)categoryKey categoryName:(NSString *)categoryName imageNamed:(NSString *)imageNamed
{
    if ([super init])
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
    if ([super init])
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

- (NSDictionary <NSString *, NSArray <SFSymbol *> *> *)tokenizedSymbols
{
    if (!_tokenizedSymbols) {
        NSArray <SFSymbol *> *allSymbols = self.symbols;
        NSMutableDictionary <NSString *, NSMutableArray <SFSymbol *> *> *tokenizedSymbolIndex = [[NSMutableDictionary alloc] init];
        
        for (SFSymbol *symbol in allSymbols) {
            
            // append accurate tokens
            for (NSString *symbolToken in symbol.accurateTokens) {
                if (![tokenizedSymbolIndex objectForKey:symbolToken]) {
                    [tokenizedSymbolIndex setObject:[[NSMutableArray alloc] init] forKey:symbolToken];
                }
                NSMutableArray <SFSymbol *> *tokenizedSymbols = tokenizedSymbolIndex[symbolToken];
                [tokenizedSymbols addObject:symbol];
            }
            
            // append fuzzy tokens
            for (NSString *fuzzyToken in symbol.fuzzyTokens) {
                NSString *fuzzyKey = [@"?" stringByAppendingString:fuzzyToken];
                if (![tokenizedSymbolIndex objectForKey:fuzzyKey]) {
                    [tokenizedSymbolIndex setObject:[[NSMutableArray alloc] init] forKey:fuzzyKey];
                }
                NSMutableArray <SFSymbol *> *tokenizedSymbols = tokenizedSymbolIndex[fuzzyKey];
                [tokenizedSymbols addObject:symbol];
            }
        }
        
#ifdef DEBUG
        NSLog(@"tokenized symbols for category %@ initialized, %ld tokens in total.", self.name, tokenizedSymbolIndex.count);
#endif
        _tokenizedSymbols = tokenizedSymbolIndex;
    }
    return _tokenizedSymbols;
}

- (void)loadSymbols
{
    static NSArray <NSString *> *allSymbolNames = nil;
    static NSMutableArray <NSString *> *uncategoriedSymbolNames = nil;
    static NSDictionary <NSString *, NSArray <NSString *> *> *categoryMappings = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        allSymbolNames = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"symbols" ofType:@"plist"]];
        uncategoriedSymbolNames = [[NSMutableArray alloc] initWithCapacity:allSymbolNames.count];
        NSMutableDictionary <NSString *, NSMutableArray <NSString *> *> *cachedCategoryMappings = [[NSMutableDictionary alloc] init];
        NSDictionary <NSString *, NSArray <NSString *> *> *localCategoryMappings = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"symbol_categories" ofType:@"plist"]];
        for (NSString *symbolName in allSymbolNames) {
            NSArray <NSString *> *categoryNames = localCategoryMappings[symbolName];
            if (!categoryNames) {
                [uncategoriedSymbolNames addObject:symbolName];
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
    
    if (categoryMappings[self.key]) {
        [self loadSymbolsWithSymbolNames:categoryMappings[self.key]];
    } else if ([self.key isEqualToString:@"all"]) {
        [self loadSymbolsWithSymbolNames:allSymbolNames];
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
}

@end
