//
//  SFSymbolCategory.h
//  SFSymbolsPreview
//
//  Created by YICAI YANG on 2020/5/28.
//  Copyright © 2020 YICAI YANG. All rights reserved.
//

#import "SFSymbol.h"

NS_ASSUME_NONNULL_BEGIN

@interface SFSymbolCategory : NSObject

@property (nonatomic, strong, readonly) NSString *key;
@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong, readonly) NSString *imageNamed;

@property (nonatomic, strong, readonly) NSArray <SFSymbol *> *symbols;
@property (nonatomic, strong, readonly) NSDictionary <NSString *, NSSet <SFSymbol *> *> *tokenizedSymbols;

- (instancetype)initWithCategoryKey:(NSString *)categoryKey categoryName:(NSString *)categoryName;
- (instancetype)initWithCategoryKey:(NSString *)categoryKey categoryName:(NSString *)categoryName imageNamed:(nullable NSString *)imageNamed;
- (instancetype)initWithSearchResultsCategoryWithSymbols:(NSArray <SFSymbol *> *)symbols;

@property (nonatomic, assign) BOOL syncFavoriteAutomatically;
+ (instancetype)favoriteCategory;
- (BOOL)isFavoriteCategory;
- (void)syncFavorite;

- (BOOL)containsSymbol:(SFSymbol *)symbol;
- (NSUInteger)indexOfSymbol:(SFSymbol *)symbol;
- (NSUInteger)indexOfSymbolWithName:(NSString *)symbolName;
- (SFSymbol *)symbolAtIndex:(NSUInteger)index;
- (SFSymbol *)symbolWithName:(NSString *)symbolName;
- (void)addSymbolsFromArray:(NSArray <SFSymbol *> *)objects;
- (void)addSymbol:(SFSymbol *)object;
- (void)removeSymbolsInArray:(NSArray <SFSymbol *> *)objects;
- (void)removeSymbol:(SFSymbol *)object;
- (void)insertSymbol:(SFSymbol *)object atIndex:(NSUInteger)index;
- (void)insertSymbols:(NSArray <SFSymbol *> *)array atIndexes:(NSIndexSet *)indexes;
- (void)removeSymbolAtIndex:(NSUInteger)index;
- (void)removeSymbolsAtIndexes:(NSIndexSet *)indexes;
- (void)removeAllSymbols;

@end

NS_ASSUME_NONNULL_END
