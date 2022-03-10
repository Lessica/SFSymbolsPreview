//
//  ObjectNode.m
//  CommonViewControllers
//
//  Created by Lessica <82flex@gmail.com> on 2022/1/20.
//  Copyright © 2022 Zheng Wu. All rights reserved.
//

#import "ObjectNode-Private.h"

@implementation ObjectNode

+ (BOOL)supportsSecureCoding {
    return YES;
}

+ (NSNumberFormatter *)_numberFormatter {
    static NSNumberFormatter *__numberFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __numberFormatter = [NSNumberFormatter new];
        __numberFormatter.numberStyle = NSNumberFormatterNoStyle;
    });
    return __numberFormatter;
}

+ (NSDateFormatter *)_dateFormatter {
    static NSDateFormatter *__dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __dateFormatter = ({
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
            [dateFormatter setLocale:enUSPOSIXLocale];
            [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
            [dateFormatter setCalendar:[NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian]];
            dateFormatter;
        });
    });
    return __dateFormatter;
}

+ (ObjectNodeType)_typeForObject:(id)obj {
    if ([obj isKindOfClass:[NSNull class]]) {
        return ObjectNodeTypeNull;
    }
    if ([obj isKindOfClass:[NSArray class]]) {
        return ObjectNodeTypeArray;
    }
    if ([obj isKindOfClass:[NSDictionary class]]) {
        return ObjectNodeTypeDictionary;
    }
    if ([obj isKindOfClass:[NSString class]]) {
        return ObjectNodeTypeString;
    }
    if ([obj isKindOfClass:[NSDate class]]) {
        return ObjectNodeTypeDate;
    }
    if ([obj isKindOfClass:[NSData class]]) {
        return ObjectNodeTypeData;
    }
    if ([obj isKindOfClass:NSClassFromString(@"__NSCFBoolean")]) {
        return ObjectNodeTypeBoolean;
    }
    if ([obj isKindOfClass:[NSNumber class]]) {
        return ObjectNodeTypeNumber;
    }
    
    return ObjectNodeTypeUnknown;
}

+ (NSString *)stringForType:(ObjectNodeType)type {
    switch (type) {
    case ObjectNodeTypeUnknown:
        return nil;
    case ObjectNodeTypeNull:
        return @"Null";
    case ObjectNodeTypeArray:
        return @"Array";
    case ObjectNodeTypeDictionary:
        return @"Dictionary";
    case ObjectNodeTypeBoolean:
        return @"Boolean";
    case ObjectNodeTypeDate:
        return @"Date";
    case ObjectNodeTypeData:
        return @"Data";
    case ObjectNodeTypeNumber:
        return @"Number";
    case ObjectNodeTypeString:
        return @"String";
    }
}

+ (ObjectNodeType)typeForString:(NSString *)str {
    if ([str isEqualToString:@"Null"]) {
        return ObjectNodeTypeNull;
    }
    if ([str isEqualToString:@"Array"]) {
        return ObjectNodeTypeArray;
    }
    if ([str isEqualToString:@"Dictionary"]) {
        return ObjectNodeTypeDictionary;
    }
    if ([str isEqualToString:@"String"]) {
        return ObjectNodeTypeString;
    }
    if ([str isEqualToString:@"Date"]) {
        return ObjectNodeTypeDate;
    }
    if ([str isEqualToString:@"Data"]) {
        return ObjectNodeTypeData;
    }
    if ([str isEqualToString:@"Boolean"]) {
        return ObjectNodeTypeBoolean;
    }
    if ([str isEqualToString:@"Number"]) {
        return ObjectNodeTypeNumber;
    }
    
    return ObjectNodeTypeUnknown;
}

+ (id)defaultValueForType:(ObjectNodeType)type {
    switch (type) {
    case ObjectNodeTypeUnknown:
        return nil;
    case ObjectNodeTypeNull:
        return [NSNull null];
    case ObjectNodeTypeArray:
    case ObjectNodeTypeDictionary:
        return nil;
    case ObjectNodeTypeBoolean:
        return @NO;
    case ObjectNodeTypeDate:
        return [NSDate date];
    case ObjectNodeTypeData:
        return [NSData data];
    case ObjectNodeTypeNumber:
        return @0;
    case ObjectNodeTypeString:
        return @"";
    }
}

+ (id)convertString:(NSString *)str toObjectOfType:(ObjectNodeType)type {
    switch (type) {
    case ObjectNodeTypeUnknown:
        return nil;
    case ObjectNodeTypeNull:
        return nil;
    case ObjectNodeTypeArray:
        return nil;
    case ObjectNodeTypeDictionary:
        return nil;
    case ObjectNodeTypeBoolean:
        return [[str uppercaseString] isEqualToString:@"YES"] || [[str lowercaseString] isEqualToString:@"true"] ? @YES : @NO;
    case ObjectNodeTypeDate:
        return nil;
    case ObjectNodeTypeData:
        return nil;
    case ObjectNodeTypeNumber:
        return [ObjectNode._numberFormatter numberFromString:str];
    case ObjectNodeTypeString:
        return str;
    }
}

+ (NSString *)stringValueOfNode:(ObjectNode *)node {
    id valueToTranslate = node._cachedDisplayValue ?: node.value;
    NSArray *childrenToTranslate = [node._cachedDisplayValue isKindOfClass:[NSArray class]] ? node._cachedDisplayValue : [node._cachedDisplayValue isKindOfClass:[NSDictionary class]] ? [node._cachedDisplayValue allKeys] : node.children;
    ObjectNodeType typeToTranslate = node._cachedDisplayValue ? [self _typeForObject:node._cachedDisplayValue] : node.type;
    
    switch (typeToTranslate) {
    case ObjectNodeTypeUnknown:
        return nil;
    case ObjectNodeTypeNull:
        return NSLocalizedString(@"(null)", @"");
    case ObjectNodeTypeArray:
    case ObjectNodeTypeDictionary:
        return [NSString stringWithFormat:NSLocalizedString(@"(%lu items)", @""), [childrenToTranslate count]];
    case ObjectNodeTypeBoolean:
        return [valueToTranslate boolValue] ? NSLocalizedString(@"YES", @"") : NSLocalizedString(@"NO", @"");
    case ObjectNodeTypeDate:
        return [ObjectNode._dateFormatter stringFromDate:valueToTranslate];
    case ObjectNodeTypeData:
        return [NSString stringWithFormat:NSLocalizedString(@"(%lu bytes)", @""), [(NSData *)valueToTranslate length]];
    case ObjectNodeTypeNumber:
        return [ObjectNode._numberFormatter stringFromNumber:valueToTranslate];
    case ObjectNodeTypeString:
        return valueToTranslate;
    }
}

+ (NSString *)stringKeyOfNode:(ObjectNode *)node {
    if ([node._cachedDisplayKey isKindOfClass:[NSString class]]) {
        return node._cachedDisplayKey;
    }
    switch (node.parent.type) {
    case ObjectNodeTypeArray:
        return [NSString stringWithFormat:NSLocalizedString(@"Item #%lu", @""), [node.parent.children indexOfObject:node]];
    default:
        return node.key;
    }
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    
    if (self) {
        self._visible = YES;
        self.key = [aDecoder decodeObjectForKey:@"key"];
        self.type = [[aDecoder decodeObjectForKey:@"type"] unsignedIntegerValue];
        self.value = [aDecoder decodeObjectForKey:@"value"];
        self.children = [aDecoder decodeObjectForKey:@"children"];
        
        [self.children enumerateObjectsUsingBlock:^(ObjectNode * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.parent = self;
        }];
    }
    
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary <NSString *, id> *)dictionary {
    self = [super init];
    
    if (self) {
        self._visible = YES;
        self.type = ObjectNodeTypeDictionary;
        self.children = [NSMutableArray new];
        
        [dictionary enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id _Nonnull obj, BOOL * _Nonnull stop) {
            if ([key hasPrefix:@"__"]) {
                if ([obj isKindOfClass:[NSString class]]) {
                    if ([key isEqualToString:@"__KEY__"]) {
                        self._cachedDisplayKey = obj;
                    } else if ([key isEqualToString:@"__VALUE__"]) {
                        self._cachedDisplayValue = obj;
                    } else if ([key isEqualToString:@"__DESCRIPTION__"]) {
                        self._cachedDescription = obj;
                    }
                } else if ([obj isKindOfClass:[NSArray class]]) {
                    if ([key isEqualToString:@"__KEYS__"]) {
                        self._cachedDisplayKeyOrder = obj;
                    }
                }
                return;
            }
            ObjectNode *childNode = [[ObjectNode alloc] initWithObject:obj];
            childNode.key = key;
            childNode.parent = self;
            [self.children addObject:childNode];
        }];
        
        if (self._cachedDisplayKeyOrder) {
            [self.children sortUsingComparator:^NSComparisonResult (ObjectNode * _Nonnull obj1, ObjectNode * _Nonnull obj2) {
                NSUInteger idx1 = [self._cachedDisplayKeyOrder indexOfObject:obj1.key];
                NSUInteger idx2 = [self._cachedDisplayKeyOrder indexOfObject:obj2.key];
                if (idx1 != NSNotFound && idx2 != NSNotFound) {
                    if (idx1 > idx2) {
                        return NSOrderedDescending;
                    } else if (idx1 < idx2) {
                        return NSOrderedAscending;
                    }
                }
                return NSOrderedSame;
            }];
        }
    }
    
    return self;
}

- (instancetype)initWithArray:(NSArray <id> *)array {
    self = [super init];
    
    if (self) {
        self._visible = YES;
        self.type = ObjectNodeTypeArray;
        self.children = [NSMutableArray new];
        
        [array enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            ObjectNode *childNode = [[ObjectNode alloc] initWithObject:obj];
            childNode.parent = self;
            [self.children addObject:childNode];
        }];
    }
    
    return self;
}

- (instancetype)initWithObject:(id)obj {
    if (obj == nil) {
        return nil;
    }
    
    ObjectNodeType type = [ObjectNode _typeForObject:obj];
    
    if (type == ObjectNodeTypeDictionary) {
        return [self initWithDictionary:obj];
    }
    if (type == ObjectNodeTypeArray) {
        return [self initWithArray:obj];
    }
    
    self = [super init];
    
    if (self) {
        self._visible = YES;
        self.type = type;
        self.value = obj;
    }
    
    return self;
}

- (instancetype)initWithPropertyList:(id)obj {
    return [self initWithObject:obj];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.key forKey:@"key"];
    [aCoder encodeObject:@(self.type) forKey:@"type"];
    [aCoder encodeObject:self.value forKey:@"value"];
    [aCoder encodeObject:self.children forKey:@"children"];
}

- (NSString *)description {
    NSMutableString *builder = [NSMutableString stringWithFormat:@"<%@ %p", NSStringFromClass([self class]), self];
    
    if (self.key != nil) {
        [builder appendFormat:@" key: “%@”", self.key];
    }
    
    [builder appendFormat:@" type: “%@”", [ObjectNode stringForType:self.type]];
    
    if (self.type == ObjectNodeTypeDictionary || self.type == ObjectNodeTypeArray) {
        [builder appendFormat:@" children: “%lu items”", self.children.count];
    }else {
        [builder appendFormat:@" value: “%@”", [self.value description]];
    }
    
    [builder appendString:@">"];
    
    return builder;
}

- (NSDictionary *)_dictionaryObject {
    NSMutableDictionary *rv = [NSMutableDictionary new];
    
    [self.children enumerateObjectsUsingBlock:^(ObjectNode * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        rv[obj.key] = obj.propertyList;
    }];
    
    return rv.copy;
}

- (NSArray *)_arrayObject {
    NSMutableArray *rv = [NSMutableArray new];
    
    [self.children enumerateObjectsUsingBlock:^(ObjectNode * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [rv addObject:obj.propertyList];
    }];
    
    return rv.copy;
}

- (id)propertyList {
    if (self.type == ObjectNodeTypeDictionary) {
        return self._dictionaryObject;
    }
    if (self.type == ObjectNodeTypeArray) {
        return self._arrayObject;
    }
    
    return self.value;
}

- (ObjectNode *)childNodeContainingDescendantNode:(ObjectNode *)descendantNode;
{
    ObjectNode *parent = descendantNode;
    
    while (parent != nil && [self.children containsObject:parent] == NO) {
        parent = parent.parent;
    }
    
    return parent;
}

- (ObjectNode *)childNodeForKey:(NSString *)key {
    return [self.children filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"key == %@", key]].firstObject;
}

- (ObjectNode *)childNodeForVisibleKey:(NSString *)key {
    for (ObjectNode *childNode in self.children) {
        if ([childNode.visibleKey isEqualToString:key]) {
            return childNode;
        }
    }
    return nil;
}

- (void)_optionalSortUsingDescriptors:(NSArray <NSSortDescriptor *> *)descriptors {
    if (!self.isContainerNode) {
        return;
    }
    
    if (!self._cachedDisplayKeyOrder) {
        [self.children sortUsingDescriptors:descriptors];
    }
    for (ObjectNode *child in self.children) {
        [child _optionalSortUsingDescriptors:descriptors];
    }
}

- (BOOL)isContainerNode {
    return self.type == ObjectNodeTypeArray || self.type == ObjectNodeTypeDictionary;
}

- (BOOL)isLeafNode {
    return !self.isContainerNode;
}

- (BOOL)isNodeOfArray {
    return self.parent.type == ObjectNodeTypeArray;
}

- (BOOL)isVisible {
    return self._visible;
}

- (NSString *)_visibleKey {
    if (!__visibleKey) {
        __visibleKey = [[NSUUID UUID] UUIDString];
    }
    return __visibleKey;
}

- (NSString *)visibleKey {
    return self._visibleKey;
}

- (NSInteger)levelOfDescendants {
    return self._levelOfDescendants;
}

- (void)setExpanded:(BOOL)expanded {
    [self setExpanded:expanded recursively:NO];
}

- (void)setExpanded:(BOOL)expanded recursively:(BOOL)recursively {
    if (![self isContainerNode]) {
        return;
    }
    if (_expanded != expanded || recursively) {
        _expanded = expanded;
        ObjectNode *parent = self;
        while ((parent = parent.parent)) {
            parent._hasCachedNumberOfDescendants = NO;
        }
        [self _invalidateNumberOfDescendantsRecursively:!recursively];
        if (expanded || recursively) {
            for (ObjectNode *childNode in self.children) {
                if (expanded) {
                    childNode._levelOfDescendants = self.levelOfDescendants + 1;
                }
                if (recursively) {
                    [childNode setExpanded:expanded recursively:recursively];
                }
            }
        }
    }
}

- (NSInteger)numberOfDescendants {
    if (self._hasCachedNumberOfDescendants) {
        return self._cachedNumberOfDescendants;
    }
    NSInteger num = self.isVisible ? 1 : 0;
    if (self.isVisible && self.isExpanded && [self isContainerNode]) {
        for (ObjectNode *childNode in self.children) {
            num += childNode.numberOfDescendants;
        }
    }
    self._cachedNumberOfDescendants = num;
    self._hasCachedNumberOfDescendants = YES;
    return num;
}

- (void)_invalidateNumberOfDescendants {
    [self _invalidateNumberOfDescendantsRecursively:NO];
}

- (void)_invalidateNumberOfDescendantsRecursively:(BOOL)recursively {
    self._hasCachedNumberOfDescendants = NO;
    if (recursively) {
        for (ObjectNode *childNode in self.children) {
            [childNode _invalidateNumberOfDescendantsRecursively:recursively];
        }
    }
}

- (ObjectNode *)descendantNodeAtIndex:(NSInteger)index {
    if (index == 0) {
        return self;
    }
    NSInteger lowerBound = 1;
    for (ObjectNode *childNode in self.children) {
        NSInteger upperBound = lowerBound + childNode.numberOfDescendants;
        if (index >= lowerBound && index < upperBound) {
            return [childNode descendantNodeAtIndex:index - lowerBound];
        }
        lowerBound = upperBound;
    }
    NSAssert(NO, @"out of range");
    return nil;
}

- (NSInteger)indexOfDescendantNode:(ObjectNode *)descendantNode {
    if (descendantNode == self) {
        return 0;
    }
    NSInteger offset = 1;
    for (ObjectNode *childNode in self.children) {
        NSInteger indexFound = [childNode indexOfDescendantNode:descendantNode];
        if (indexFound != NSNotFound) {
            return offset + indexFound;
        } else {
            offset += childNode.numberOfDescendants;
        }
    }
    return NSNotFound;
}

- (ObjectNode *)descendantNodeForVisibleKey:(NSString *)visibleKey {
    if ([self._visibleKey isEqualToString:visibleKey]) {
        return self;
    }
    for (ObjectNode *childNode in self.children) {
        ObjectNode *targetNode = [childNode descendantNodeForVisibleKey:visibleKey];
        if (targetNode) {
            return targetNode;
        }
    }
    return nil;
}

- (void)updateVisibleStateWithPredicate:(NSPredicate *)predicate {
    BOOL matched = NO;
    if (!matched && !self.isNodeOfArray) {
        matched = [predicate evaluateWithObject:[NSString stringWithFormat:@"%@", [ObjectNode stringKeyOfNode:self]]];
    }
    if (!matched && self.isLeafNode) {
        matched = [predicate evaluateWithObject:[NSString stringWithFormat:@"%@", [ObjectNode stringValueOfNode:self]]];
    }
    self._visible = matched;
    if (matched) {
        ObjectNode *parent = self;
        while ((parent = parent.parent)) {
            parent._visible = matched;
        }
    }
    [self _invalidateNumberOfDescendantsRecursively:NO];
    for (ObjectNode *childNode in self.children) {
        [childNode updateVisibleStateWithPredicate:predicate];
    }
}

- (void)expandToDescendantNode:(ObjectNode *)descendantNode {
    NSMutableArray <ObjectNode *> *nodesToExpand = [NSMutableArray array];
    ObjectNode *parent = descendantNode;
    while (parent != nil && parent != self) {
        parent = parent.parent;
        [nodesToExpand addObject:parent];
    }
    [nodesToExpand addObject:parent];
    for (ObjectNode *node in [nodesToExpand reverseObjectEnumerator]) {
        [node setExpanded:YES];
    }
}

- (instancetype)copyWithZone:(NSZone *)zone {
    
    // Objective-C no longer uses zone.
    ObjectNode *newNode = [[ObjectNode alloc] init];
    
    newNode.key = [self.key copy];
    newNode.value = [self.value copy];
    newNode.type = self.type;
    
    // Expand state is not copied.
    
    // Visible state is copied.
    newNode._visible = self._visible;
    newNode._visibleKey = [self._visibleKey copy];
    
    NSMutableArray *children = [[NSMutableArray alloc] initWithCapacity:self.children.count];
    for (ObjectNode *childNode in self.children) {
        ObjectNode *newChildNode = [childNode copy];
        newChildNode.parent = newNode;
        [children addObject:newChildNode];
    }
    
    newNode.children = [children copy];
    
    return newNode;
}

@end
