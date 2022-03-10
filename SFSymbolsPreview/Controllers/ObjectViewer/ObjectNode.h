//
//  ObjectNode.h
//  CommonViewControllers
//
//  Created by Lessica <82flex@gmail.com> on 2022/1/20.
//  Copyright © 2022 Zheng Wu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ObjectNodeType) {
    ObjectNodeTypeUnknown,
    
    ObjectNodeTypeNull,
    ObjectNodeTypeArray,
    ObjectNodeTypeDictionary,
    ObjectNodeTypeBoolean,
    ObjectNodeTypeDate,
    ObjectNodeTypeData,
    ObjectNodeTypeNumber,
    ObjectNodeTypeString,
};

@interface ObjectNode : NSObject <NSCopying, NSSecureCoding>
    
//- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithPropertyList:(id)obj;

@property (nonatomic, copy) NSString *key;
@property (nonatomic) ObjectNodeType type;

@property (nonatomic, strong) NSObject <NSCopying, NSSecureCoding> *value;
@property (nonatomic, strong) NSMutableArray <ObjectNode *> *children;
- (ObjectNode *)childNodeContainingDescendantNode:(ObjectNode *)descendantNode;
- (ObjectNode *)childNodeForKey:(NSString *)key;
- (ObjectNode *)childNodeForVisibleKey:(NSString *)key;

@property (nonatomic, weak) ObjectNode *parent;
@property (nonatomic, strong, readonly) id propertyList;

#pragma mark - Outline View Related
@property (nonatomic, assign, getter=isExpanded) BOOL expanded;
- (void)setExpanded:(BOOL)expanded recursively:(BOOL)recursively;
- (BOOL)isContainerNode;
- (BOOL)isLeafNode;
- (BOOL)isNodeOfArray;
- (BOOL)isVisible;
- (NSInteger)levelOfDescendants;
- (NSInteger)numberOfDescendants;
- (ObjectNode *)descendantNodeAtIndex:(NSInteger)index;
- (NSInteger)indexOfDescendantNode:(ObjectNode *)descendantNode;

#pragma mark - Search Related
@property (nonatomic, copy, readonly) NSString *visibleKey;
- (ObjectNode *)descendantNodeForVisibleKey:(NSString *)visibleKey;
- (void)updateVisibleStateWithPredicate:(NSPredicate *)predicate;
- (void)expandToDescendantNode:(ObjectNode *)descendantNode;

@end
