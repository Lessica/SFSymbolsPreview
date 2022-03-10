//
//  ObjectNode-Private.h
//  CommonViewControllers
//
//  Created by Lessica <82flex@gmail.com> on 2022/1/20.
//  Copyright © 2022 Zheng Wu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjectNode.h"

@interface ObjectNode ()

+ (ObjectNodeType)_typeForObject:(id)obj;
+ (NSString *)stringForType:(ObjectNodeType)type;
+ (ObjectNodeType)typeForString:(NSString *)str;
+ (id)defaultValueForType:(ObjectNodeType)type;
+ (id)convertString:(NSString *)str toObjectOfType:(ObjectNodeType)type;
+ (NSString *)stringKeyOfNode:(ObjectNode *)node;
+ (NSString *)stringValueOfNode:(ObjectNode *)node;

@property (nonatomic, strong) NSString *_cachedDisplayKey;
@property (nonatomic, strong) id _cachedDisplayValue;
@property (nonatomic, strong) NSArray <NSString *> *_cachedDisplayKeyOrder;
@property (nonatomic, strong) NSString *_cachedDescription;

- (void)_optionalSortUsingDescriptors:(NSArray <NSSortDescriptor *> *)descriptors;

#pragma mark - Outline View Related
@property (nonatomic, assign) BOOL _hasCachedNumberOfDescendants;
@property (nonatomic, assign) NSInteger _levelOfDescendants;
@property (nonatomic, assign) NSInteger _cachedNumberOfDescendants;

- (void)_invalidateNumberOfDescendants;
- (void)_invalidateNumberOfDescendantsRecursively:(BOOL)recursively;

#pragma mark - Search Related
@property (nonatomic, assign) BOOL _visible;
@property (nonatomic, copy) NSString *_visibleKey;

@end
