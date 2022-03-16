//
//  SFSymbolCategory.m
//  SFSymbolsPreview
//
//  Created by YICAI YANG on 2020/5/28.
//  Copyright © 2020 YICAI YANG. All rights reserved.
//

#import "SFSymbolCategory.h"


NSString * const SFSymbolFavoriteCategoryKey = @"__FAV__";

@interface SFSymbolCategory ()

@property (nonatomic, copy) NSString *favoriteItemPath;

@property (nonatomic, strong) NSMutableArray <SFSymbol *> *mutableSymbols;
@property (nonatomic, strong) NSMutableArray <NSString *> *mutableSymbolNames;
@property (nonatomic, strong) NSMutableDictionary <NSString *, SFSymbol *> *mutableFastSymbolNames;

@end

@implementation SFSymbolCategory

@synthesize tokenizedSymbols = _tokenizedSymbols;

+ (instancetype)favoriteCategory
{
    static SFSymbolCategory *_category = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *libraryPath = [[[NSFileManager defaultManager] URLForDirectory:NSLibraryDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil] path];
        _category = [[SFSymbolCategory alloc] initWithFavoriteItemPath:[libraryPath stringByAppendingPathComponent:@"favorite.plist"]];
    });
    return _category;
}

- (instancetype)initWithCategoryKey:(NSString *)categoryKey categoryName:(NSString *)categoryName
{
    return [self initWithCategoryKey:categoryKey categoryName:categoryName imageNamed:nil];
}

- (instancetype)initWithCategoryKey:(NSString *)categoryKey categoryName:(NSString *)categoryName imageNamed:(NSString *)imageNamed
{
    if (self = [super init])
    {
        _key = categoryKey;
        _name = categoryName;
        _imageNamed = imageNamed;
        
        [self loadSymbols];
    }
    return self;
}

- (instancetype)initWithFavoriteItemPath:(NSString *)favoriteItemPath
{
    if (self = [super init])
    {
        _name = NSLocalizedString(@"My Favorites", nil);
        _key = SFSymbolFavoriteCategoryKey;
        _favoriteItemPath = favoriteItemPath;
        _syncFavoriteAutomatically = YES;
        
        [self loadSymbols];
    }
    return self;
}

- (instancetype)initWithSearchResultsCategoryWithSymbols:(NSArray <SFSymbol *> *)symbols
{
    if (self = [super init])
    {
        _name = NSLocalizedString(@"Search Results", nil);
        _mutableSymbols = [symbols mutableCopy];
        
        NSMutableArray <NSString *> *cachedSymbolNames = [[NSMutableArray alloc] initWithCapacity:symbols.count];
        NSMutableDictionary <NSString *, SFSymbol *> *cachedFastSymbolNames = [[NSMutableDictionary alloc] initWithCapacity:symbols.count];
        for (SFSymbol *symbol in symbols) {
            [cachedSymbolNames addObject:symbol.name];
            [cachedFastSymbolNames setObject:symbol forKey:symbol.name];
        }
        _mutableSymbolNames = cachedSymbolNames;
        _mutableFastSymbolNames = cachedFastSymbolNames;
    }
    return self;
}

- (NSArray <SFSymbol *> *)symbols {
    return _mutableSymbols;
}

- (NSDictionary <NSString *, NSSet <SFSymbol *> *> *)tokenizedSymbols
{
    if (!_tokenizedSymbols) {
        NSArray <SFSymbol *> *allSymbols = self.symbols;
        NSMutableDictionary <NSString *, NSMutableSet <SFSymbol *> *> *symbolSets = [[NSMutableDictionary alloc] init];
        
        for (SFSymbol *symbol in allSymbols) {
            
            // append accurate tokens
            for (NSString *symbolToken in symbol.accurateSearchTokens) {
                if (![symbolSets objectForKey:symbolToken]) {
                    [symbolSets setObject:[[NSMutableSet alloc] init] forKey:symbolToken];
                }
                NSMutableSet <SFSymbol *> *symbols = [symbolSets objectForKey:symbolToken];
                [symbols addObject:symbol];
            }
            
            // append fuzzy tokens
            for (NSString *fuzzyToken in symbol.fuzzySearchTokens) {
                NSString *fuzzyKey = [@"?" stringByAppendingString:fuzzyToken];
                if (![symbolSets objectForKey:fuzzyKey]) {
                    [symbolSets setObject:[[NSMutableSet alloc] init] forKey:fuzzyKey];
                }
                NSMutableSet <SFSymbol *> *symbols = [symbolSets objectForKey:fuzzyKey];
                [symbols addObject:symbol];
            }
        }
        
#ifdef DEBUG
        NSLog(@"tokenized symbols for category %@ initialized, %ld tokens in total.", self.name, symbolSets.count);
#endif
        _tokenizedSymbols = symbolSets;
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
    
    if (self.favoriteItemPath) {
        [self loadSymbolsWithSymbolNames:([NSArray arrayWithContentsOfFile:self.favoriteItemPath] ?: @[])];
    } else if (categoryMappings[self.key]) {
        [self loadSymbolsWithSymbolNames:categoryMappings[self.key]];
    } else if ([self.key isEqualToString:@"all"]) {
        [self loadSymbolsWithSymbolNames:allSymbolNames];
    }
}

- (void)loadSymbolsWithSymbolNames:(NSArray <NSString *> *)symbolNames
{
    if (!_mutableSymbols) {
        _mutableSymbols = [[NSMutableArray alloc] initWithCapacity:symbolNames.count];
        _mutableSymbolNames = [[NSMutableArray alloc] initWithCapacity:symbolNames.count];
        _mutableFastSymbolNames = [[NSMutableDictionary alloc] initWithCapacity:symbolNames.count];
    }
    [symbolNames enumerateObjectsUsingBlock:^(NSString *name, NSUInteger index, BOOL *stop) {
        if (![self->_mutableSymbolNames containsObject:name]) {
            [self->_mutableSymbolNames addObject:name];
            SFSymbol *symbol = [SFSymbol symbolWithName:name];
            if ([symbol.availability isCompatibleWithCurrentPlatform]) {
                [self->_mutableSymbols addObject:symbol];
                [self->_mutableFastSymbolNames setObject:symbol forKey:symbol.name];
            }
        }
    }];
}

- (BOOL)isFavoriteCategory
{
    return _favoriteItemPath != nil;
}

- (void)syncFavoriteIfNeeded
{
    if (self.isFavoriteCategory && self.syncFavoriteAutomatically) {
        [_mutableSymbolNames writeToFile:self.favoriteItemPath atomically:YES];
    }
}

- (void)syncFavorite
{
    if (self.isFavoriteCategory) {
        [_mutableSymbolNames writeToFile:self.favoriteItemPath atomically:YES];
    }
}

- (BOOL)containsSymbol:(SFSymbol *)symbol
{
    return [_mutableFastSymbolNames objectForKey:symbol.name] != nil;
}

- (NSUInteger)indexOfSymbol:(SFSymbol *)symbol
{
    return [_mutableSymbols indexOfObject:symbol];
}

- (NSUInteger)indexOfSymbolWithName:(NSString *)symbolName
{
    return [_mutableSymbolNames indexOfObject:symbolName];
}

- (SFSymbol *)symbolAtIndex:(NSUInteger)index
{
    return [_mutableSymbols objectAtIndex:index];
}

- (SFSymbol *)symbolWithName:(NSString *)symbolName
{
    return [_mutableFastSymbolNames objectForKey:symbolName];
}

- (void)addSymbolsFromArray:(NSArray <SFSymbol *> *)objects
{
    NSArray <SFSymbol *> *allSymbols = objects;
    [_mutableSymbols addObjectsFromArray:allSymbols];
    for (SFSymbol *symbol in allSymbols) {
        [_mutableSymbolNames addObject:symbol.name];
        [_mutableFastSymbolNames setObject:symbol forKey:symbol.name];
    }
    [self syncFavoriteIfNeeded];
}

- (void)removeSymbolsInArray:(NSArray <SFSymbol *> *)objects
{
    NSArray <SFSymbol *> *allSymbols = objects;
    [_mutableSymbols removeObjectsInArray:allSymbols];
    for (SFSymbol *symbol in allSymbols) {
        [_mutableSymbolNames removeObject:symbol.name];
        [_mutableFastSymbolNames removeObjectForKey:symbol.name];
    }
    [self syncFavoriteIfNeeded];
}

- (void)addSymbol:(SFSymbol *)object
{
    [_mutableSymbols addObject:object];
    [_mutableSymbolNames addObject:object.name];
    [_mutableFastSymbolNames setObject:object forKey:object.name];
    [self syncFavoriteIfNeeded];
}

- (void)removeSymbol:(SFSymbol *)object
{
    [_mutableSymbols removeObject:object];
    [_mutableSymbolNames removeObject:object.name];
    [_mutableFastSymbolNames removeObjectForKey:object.name];
    [self syncFavoriteIfNeeded];
}

- (void)insertSymbol:(SFSymbol *)object atIndex:(NSUInteger)index
{
    [_mutableSymbols insertObject:object atIndex:index];
    [_mutableSymbolNames insertObject:object.name atIndex:index];
    [_mutableFastSymbolNames setObject:object forKey:object.name];
    [self syncFavoriteIfNeeded];
}

- (void)insertSymbols:(NSArray <SFSymbol *> *)array atIndexes:(NSIndexSet *)indexes
{
    [_mutableSymbols insertObjects:array atIndexes:indexes];
    NSMutableArray <NSString *> *symbolNames = [NSMutableArray arrayWithCapacity:array.count];
    for (SFSymbol *symbol in array) {
        [symbolNames addObject:symbol.name];
        [_mutableFastSymbolNames setObject:symbol forKey:symbol.name];
    }
    [_mutableSymbolNames insertObjects:symbolNames atIndexes:indexes];
    [self syncFavoriteIfNeeded];
}

- (void)removeSymbolAtIndex:(NSUInteger)index
{
    [_mutableSymbols removeObjectAtIndex:index];
    NSString *symbolName = [_mutableSymbolNames objectAtIndex:index];
    [_mutableSymbolNames removeObjectAtIndex:index];
    [_mutableFastSymbolNames removeObjectForKey:symbolName];
    [self syncFavoriteIfNeeded];
}

- (void)removeSymbolsAtIndexes:(NSIndexSet *)indexes
{
    [_mutableSymbols removeObjectsAtIndexes:indexes];
    NSArray <NSString *> *symbolNames = [_mutableSymbolNames objectsAtIndexes:indexes];
    [_mutableSymbolNames removeObjectsAtIndexes:indexes];
    [_mutableFastSymbolNames removeObjectsForKeys:symbolNames];
    [self syncFavoriteIfNeeded];
}

- (void)removeAllSymbols
{
    [_mutableSymbols removeAllObjects];
    [_mutableSymbolNames removeAllObjects];
    [_mutableFastSymbolNames removeAllObjects];
    [self syncFavoriteIfNeeded];
}

@end
