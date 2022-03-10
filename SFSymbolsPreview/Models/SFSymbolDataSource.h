//
//  SFSymbolDataSource.h
//  SFSymbolsPreview
//
//  Created by YICAI YANG on 2020/5/28.
//  Copyright © 2020 YICAI YANG. All rights reserved.
//

#import "SFSymbolCategory.h"

NS_ASSUME_NONNULL_BEGIN

BOOL IS_IPAD(UIView *);

SFSymbolCategory *lastOpenedCategeory(void);
void storeUserActivityLastOpenedCategory(SFSymbolCategory *category);

NSUInteger numberOfItemsInColumn(void);
void storeUserActivityNumberOfItemsInColumn(NSUInteger numberOfItems);

FOUNDATION_EXTERN NSNotificationName const PreferredSymbolWeightDidChangeNotification;
UIImageSymbolWeight preferredImageSymbolWeight(void);
void storeUserActivityPreferredImageSymbolWeight(UIImageSymbolWeight weight);

@interface SFSymbolDataSource : NSObject

@property (nonatomic, strong, readonly) NSArray <SFSymbolCategory *> *categories;

+ (instancetype)dataSource;

@end

@interface UIImage (SharingImageExtension)

- (UIImage *)toSize:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
