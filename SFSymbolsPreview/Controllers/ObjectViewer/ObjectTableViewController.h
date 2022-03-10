//
//  ObjectTableViewController.h
//  CommonViewControllers
//
//  Created by Lessica <82flex@gmail.com> on 2022/1/20.
//  Copyright © 2022 Zheng Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ObjectTableViewController : UITableViewController
    
- (instancetype)initWithPath:(NSString *)path;
@property (nonatomic, copy, readonly) NSString *entryPath;

- (instancetype)initWithObject:(id)object;
@property (nonatomic, strong, readonly) id object;

@property (nonatomic, assign) CGFloat indentationWidth;
@property (nonatomic, assign) BOOL initialRootExpanded;
@property (nonatomic, assign) BOOL initialRootHidden;
@property (nonatomic, assign) BOOL pullToReload;
@property (nonatomic, assign) BOOL pressToCopy;
@property (nonatomic, assign) BOOL showTypeHint;
@property (nonatomic, assign) BOOL allowSearch;

@end

NS_ASSUME_NONNULL_END
