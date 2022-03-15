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

+ (instancetype)favoriteCategory;
- (BOOL)isFavoriteCategory;
- (void)addSymbols:(NSArray <SFSymbol *> *)objects;
- (void)removeSymbols:(NSArray <SFSymbol *> *)objects;
- (BOOL)hasSymbol:(SFSymbol *)symbol;

@end

NS_ASSUME_NONNULL_END
