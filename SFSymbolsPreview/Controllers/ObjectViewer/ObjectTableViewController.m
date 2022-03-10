//
//  ObjectTableViewController.m
//  CommonViewControllers
//
//  Created by Lessica <82flex@gmail.com> on 2022/1/20.
//  Copyright © 2022 Zheng Wu. All rights reserved.
//

#import "ObjectTableViewController.h"
#import "ObjectNode.h"
#import "ObjectNode-Private.h"
#import "ObjectCell.h"

@interface ObjectTableViewController () <UISearchResultsUpdating>

@property (nonatomic, strong) ObjectNode *rootNode;
@property (nonatomic, strong) ObjectNode *rootNodeForSearch;
@property (nonatomic, strong) UISearchController *searchController;

@end

@implementation ObjectTableViewController

+ (NSString *)viewerName {
    return NSLocalizedString(@"Object Viewer", @"ObjectTableViewController");
}

+ (id)objectWithContentsOfPath:(NSString *)path {
    NSError *readError = nil;
    NSData *data = [NSData dataWithContentsOfFile:path options:kNilOptions error:&readError];
    if (!data) return nil;
    id object = nil;
    object = [NSPropertyListSerialization propertyListWithData:data options:kNilOptions format:nil error:&readError];
    if (object) return object;
    object = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&readError];
    if (object) return object;
    return nil;
}

- (instancetype)initWithPath:(NSString *)path {
    if (self = [super init]) {
        _indentationWidth = 14.0;
        _entryPath = path;
        [self setupWithPath];
    }
    return self;
}

- (instancetype)initWithObject:(id)object {
    if (self = [super init]) {
        _indentationWidth = 14.0;
        _object = object;
        [self setupWithObject];
    }
    return self;
}

- (void)setupWithPath {
    _object = [ObjectTableViewController objectWithContentsOfPath:_entryPath];
    [self setupWithObject];
}

- (void)setupWithObject {
    _rootNode = [[ObjectNode alloc] initWithPropertyList:_object];
    [_rootNode _optionalSortUsingDescriptors:@[
         [NSSortDescriptor sortDescriptorWithKey:@"key" ascending:YES],
    ]];
    if (self.initialRootExpanded) {
        [_rootNode setExpanded:YES recursively:NO];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.title.length == 0) {
        if (self.entryPath) {
            NSString *entryName = [self.entryPath lastPathComponent];
            self.title = entryName;
        } else {
            self.title = [[self class] viewerName];
        }
    }
    
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    
    self.searchController = ({
        UISearchController *searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
        searchController.searchResultsUpdater = self;
        searchController.obscuresBackgroundDuringPresentation = NO;
        searchController.hidesNavigationBarDuringPresentation = YES;
        searchController;
    });
    
    if (self.pullToReload && self.entryPath) {
        self.refreshControl = ({
            UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
            [refreshControl addTarget:self action:@selector(reloadDataFromEntry:) forControlEvents:UIControlEventValueChanged];
            refreshControl;
        });
    }
    
    if (self.allowSearch) {
        self.navigationItem.hidesSearchBarWhenScrolling = YES;
        self.navigationItem.searchController = self.searchController;
    }
    
    [self.tableView registerClass:[ObjectCell class] forCellReuseIdentifier:@"ObjectCell"];
    
    if (self.initialRootExpanded) {
        [_rootNode setExpanded:YES recursively:NO];
    }
}

- (void)reloadDataFromEntry:(UIRefreshControl *)sender {
    if (self.searchController.isActive) {
        return;
    }
    [self loadDataFromEntry];
    if ([sender isRefreshing]) {
        [sender endRefreshing];
    }
}

- (void)loadDataFromEntry {
    [self setupWithPath];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = self.searchController.isActive ? self.rootNodeForSearch.numberOfDescendants : self.rootNode.numberOfDescendants;
    return (self.initialRootHidden ? numberOfRows - 1 : numberOfRows);
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
    ObjectNode *cellNode = [(self.searchController.isActive ? self.rootNodeForSearch : self.rootNode) descendantNodeAtIndex:(self.initialRootHidden ? indexPath.row + 1 : indexPath.row)];
    return (self.initialRootHidden ? cellNode.levelOfDescendants - 1 : cellNode.levelOfDescendants);
}

- (nullable UIContextMenuConfiguration *)tableView:(UITableView *)tableView contextMenuConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath point:(CGPoint)point {
    if (self.pressToCopy) {
        ObjectNode *rootNode = self.searchController.isActive ? self.rootNodeForSearch : self.rootNode;
        ObjectNode *cellNode = [rootNode descendantNodeAtIndex:(self.initialRootHidden ? indexPath.row + 1 : indexPath.row)];
        NSMutableArray <UIAction *> *cellActions = [NSMutableArray array];
        if (cellNode.isLeafNode) {
            NSString *strValue = [NSString stringWithFormat:@"%@", [ObjectNode stringValueOfNode:cellNode]];
            if (cellNode != rootNode && !cellNode.isNodeOfArray) {
                NSString *strKey = [NSString stringWithFormat:@"%@", [ObjectNode stringKeyOfNode:cellNode]];
                [cellActions addObject:[UIAction actionWithTitle:NSLocalizedString(@"Copy Key", @"ObjectTableViewController") image:[UIImage systemImageNamed:@"doc.on.doc"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
                    [[UIPasteboard generalPasteboard] setString:strKey];
                }]];
            }
            [cellActions addObject:[UIAction actionWithTitle:NSLocalizedString(@"Copy Value", @"ObjectTableViewController") image:[UIImage systemImageNamed:@"doc.on.doc.fill"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
                [[UIPasteboard generalPasteboard] setString:strValue];
            }]];
        } else {
            if (cellNode != rootNode) {
                NSString *strKey = [NSString stringWithFormat:@"%@", [ObjectNode stringKeyOfNode:cellNode]];
                [cellActions addObject:[UIAction actionWithTitle:NSLocalizedString(@"Copy Key", @"ObjectTableViewController") image:[UIImage systemImageNamed:@"doc.on.doc"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
                    [[UIPasteboard generalPasteboard] setString:strKey];
                }]];
            }
            if (!self.searchController.isActive) {
                if (cellNode.isExpanded) {
                    [cellActions addObject:[UIAction actionWithTitle:NSLocalizedString(@"Collapse Recursively", @"ObjectTableViewController") image:[UIImage systemImageNamed:@"arrow.down.right.and.arrow.up.left"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
                        [self tableView:tableView triggerNodeAtIndexPath:indexPath recursively:YES];
                    }]];
                } else {
                    [cellActions addObject:[UIAction actionWithTitle:NSLocalizedString(@"Expand Recursively", @"ObjectTableViewController") image:[UIImage systemImageNamed:@"arrow.up.left.and.arrow.down.right"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
                        [self tableView:tableView triggerNodeAtIndexPath:indexPath recursively:YES];
                    }]];
                }
            }
        }
        if (self.searchController.isActive) {
            [cellActions addObject:[UIAction actionWithTitle:NSLocalizedString(@"Focus", @"ObjectTableViewController") image:[UIImage systemImageNamed:@"scope"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
                ObjectNode *targetNode = [self.rootNode descendantNodeForVisibleKey:cellNode.visibleKey];
                if (targetNode) {
                    [self.rootNode expandToDescendantNode:targetNode];
                    NSInteger targetIndex = [self.rootNode indexOfDescendantNode:targetNode];
                    NSIndexPath *targetPath = [NSIndexPath indexPathForRow:targetIndex inSection:0];
                    if (targetIndex != NSNotFound) {
                        [self.searchController.searchBar setText:@""];
                        [self.searchController dismissViewControllerAnimated:YES completion:^{
                            [tableView reloadData];
                            [tableView selectRowAtIndexPath:targetPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
                        }];
                    }
                }
            }]];
        }
        return [UIContextMenuConfiguration configurationWithIdentifier:nil previewProvider:nil actionProvider:^UIMenu * _Nullable (NSArray <UIMenuElement *> * _Nonnull suggestedActions) {
            UIMenu *menu = [UIMenu menuWithTitle:(self.showTypeHint ? [NSString stringWithFormat:NSLocalizedString(@"<%@: %p>", @"ObjectTableViewController"), NSStringFromClass([cellNode.propertyList class]), cellNode.propertyList] : @"") children:cellActions];
            return menu;
        }];
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView triggerNodeAtIndexPath:(NSIndexPath *)indexPath recursively:(BOOL)recursively {
    if (self.searchController.isActive) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    ObjectNode *cellNode = [(self.searchController.isActive ? self.rootNodeForSearch : self.rootNode) descendantNodeAtIndex:(self.initialRootHidden ? indexPath.row + 1 : indexPath.row)];
    if (cellNode.isLeafNode) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else {
        NSInteger beforeCount = cellNode.numberOfDescendants;
        if (cellNode.isExpanded) {
            [cellNode setExpanded:NO recursively:recursively];
        } else {
            [cellNode setExpanded:YES recursively:recursively];
        }
        [tableView beginUpdates];
        NSInteger afterCount = cellNode.numberOfDescendants;
        if (afterCount != beforeCount) {
            if (afterCount > beforeCount) {
                // add
                NSInteger changeCount = afterCount - beforeCount;
                NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:changeCount];
                for (NSInteger i = 0; i < changeCount; i++) {
                    [indexPaths addObject:[NSIndexPath indexPathForRow:(indexPath.row + 1 + i) inSection:0]];
                }
                [tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
            } else {
                // delete
                NSInteger changeCount = beforeCount - afterCount;
                NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:changeCount];
                for (NSInteger i = 0; i < changeCount; i++) {
                    [indexPaths addObject:[NSIndexPath indexPathForRow:(indexPath.row + 1 + i) inSection:0]];
                }
                [tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
            }
        }
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [tableView endUpdates];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self tableView:tableView triggerNodeAtIndexPath:indexPath recursively:NO];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ObjectCell *cell = (ObjectCell *)[tableView dequeueReusableCellWithIdentifier:@"ObjectCell" forIndexPath:indexPath];
    cell.indentationWidth = self.indentationWidth;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    ObjectNode *rootNode = self.searchController.isActive ? self.rootNodeForSearch : self.rootNode;
    ObjectNode *cellNode = [rootNode descendantNodeAtIndex:(self.initialRootHidden ? indexPath.row + 1 : indexPath.row)];
    
    NSString *cellKey;
    BOOL isRootNode;
    if (cellNode == rootNode) {
        cellKey = [ObjectNode stringKeyOfNode:rootNode] ?: NSLocalizedString(@"Root", @"ObjectTableViewController");
        isRootNode = YES;
    } else {
        cellKey = [ObjectNode stringKeyOfNode:cellNode];
        isRootNode = NO;
    }
    
    {
        NSMutableAttributedString *attrKey = nil;
        NSString *strKey = nil;
        if ([cellNode isContainerNode]) {
            strKey = [NSString stringWithFormat:@"%@ %@", ([cellNode isExpanded] ? @"▼" : @"▶"), cellKey];
            attrKey = [[NSMutableAttributedString alloc] initWithString:strKey attributes:@{
                           NSFontAttributeName: [UIFont systemFontOfSize:[UIFont systemFontSize]],
                           NSForegroundColorAttributeName: cellNode.isNodeOfArray ? [UIColor linkColor] : [UIColor labelColor],
            }];
        } else {
            strKey = [NSString stringWithFormat:@"%@", cellKey];
            attrKey = [[NSMutableAttributedString alloc] initWithString:strKey attributes:@{
                           NSFontAttributeName: [UIFont systemFontOfSize:[UIFont systemFontSize]],
                           NSForegroundColorAttributeName: cellNode.isNodeOfArray ? [UIColor linkColor] : [UIColor labelColor],
            }];
        }
        if (!isRootNode && !cellNode.isNodeOfArray && self.searchController.isActive) {
            NSString *searchContent = self.searchController.searchBar.text;
            NSRange searchRange = [strKey rangeOfString:searchContent options:NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch range:NSMakeRange(0, strKey.length)];
            if (searchRange.location != NSNotFound) {
                [attrKey addAttributes:@{
                     NSForegroundColorAttributeName: [UIColor colorWithDynamicProvider:^UIColor * _Nonnull (UITraitCollection * _Nonnull traitCollection) {
                         if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                             return [UIColor systemBackgroundColor];
                         } else {
                             return [UIColor labelColor];
                         }
                     }],
                     NSBackgroundColorAttributeName: [UIColor colorWithRed:253.0 / 255.0 green:247.0 / 255.0 blue:148.0 / 255.0 alpha:1.0],
                 } range:searchRange];
            }
        }
        [cell.textLabel setAttributedText:attrKey];
    }
    
    {
        NSMutableAttributedString *attrValue = nil;
        NSString *strVal = [NSString stringWithFormat:@"%@", [ObjectNode stringValueOfNode:cellNode]];
        if ([cellNode isLeafNode]) {
            attrValue = [[NSMutableAttributedString alloc] initWithString:strVal attributes:@{
                             NSFontAttributeName: [UIFont systemFontOfSize:[UIFont systemFontSize]],
                             NSForegroundColorAttributeName: [UIColor secondaryLabelColor],
            }];
        } else {
            attrValue = [[NSMutableAttributedString alloc] initWithString:strVal attributes:@{
                             NSFontAttributeName: [UIFont italicSystemFontOfSize:[UIFont systemFontSize]],
                             NSForegroundColorAttributeName: [UIColor secondaryLabelColor],
            }];
        }
        if (cellNode.isLeafNode && self.searchController.isActive) {
            NSString *searchContent = self.searchController.searchBar.text;
            NSRange searchRange = [strVal rangeOfString:searchContent options:NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch range:NSMakeRange(0, strVal.length)];
            if (searchRange.location != NSNotFound) {
                [attrValue addAttributes:@{
                     NSForegroundColorAttributeName: [UIColor colorWithDynamicProvider:^UIColor * _Nonnull (UITraitCollection * _Nonnull traitCollection) {
                         if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                             return [UIColor systemBackgroundColor];
                         } else {
                             return [UIColor labelColor];
                         }
                     }],
                     NSBackgroundColorAttributeName: [UIColor colorWithRed:253.0 / 255.0 green:247.0 / 255.0 blue:148.0 / 255.0 alpha:1.0],
                 } range:searchRange];
            }
        }
        [cell.detailTextLabel setAttributedText:attrValue];
    }
    
    {
        NSString *cellDescription = [cellNode _cachedDescription];
        if (cellDescription) {
            [cell setAccessoryType:UITableViewCellAccessoryDetailButton];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    ObjectNode *rootNode = self.searchController.isActive ? self.rootNodeForSearch : self.rootNode;
    ObjectNode *cellNode = [rootNode descendantNodeAtIndex:(self.initialRootHidden ? indexPath.row + 1 : indexPath.row)];
    
    {
        NSString *cellDescription = [cellNode _cachedDescription];
        if (cellDescription) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@", cellDescription] message:nil preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }
}

#pragma mark - Lazy Getters

- (ObjectNode *)rootNodeForSearch {
    if (!_rootNodeForSearch) {
        _rootNodeForSearch = [_rootNode copy];
        [_rootNodeForSearch setExpanded:YES recursively:YES];
    }
    return _rootNodeForSearch;
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *text = self.searchController.searchBar.text;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@", text];
    if (predicate) {
        [self.rootNodeForSearch updateVisibleStateWithPredicate:predicate];
    }
    [self.tableView reloadData];
}

#pragma mark -

- (void)dealloc {
#if DEBUG
    NSLog(@"-[%@ dealloc]", [self class]);
#endif
}

@end
