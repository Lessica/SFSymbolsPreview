//
//  SFCategoriesViewController.m
//  SFSymbolsPreview
//
//  Created by YICAI YANG on 2020/5/28.
//  Copyright © 2020 YICAI YANG. All rights reserved.
//

#import "SFCategoriesViewController.h"
#import "SymbolsViewController.h"
#import "SFSymbolDataSource.h"
#import <XUI/XUI.h>


@interface CategoryCell : UITableViewCell
    
@end

@implementation CategoryCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    [self.textLabel setTextColor:selected ? UIColor.whiteColor : UIColor.labelColor];
    [self.detailTextLabel setTextColor:selected ? UIColor.whiteColor : UIColor.secondaryLabelColor];
    [self.accessoryView setTintColor:self.detailTextLabel.textColor];
    [self.imageView setTintColor:self.textLabel.textColor];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    [self.textLabel setTextColor:highlighted ? UIColor.whiteColor : UIColor.labelColor];
    [self.detailTextLabel setTextColor:highlighted ? UIColor.whiteColor : UIColor.secondaryLabelColor];
    [self.accessoryView setTintColor:self.detailTextLabel.textColor];
    [self.imageView setTintColor:self.textLabel.textColor];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    return [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
}

@end


@interface SFCategoriesViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSDictionary *versionDictionary;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation SFCategoriesViewController

- (SFSymbolCategory *)categoryForIndexPath:(NSIndexPath *)indexPath
{
    return SFSymbolDataSource.dataSource.categories[indexPath.row];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:NSLocalizedString(@"Categories", nil)];
    [self.view setBackgroundColor:UIColor.systemBackgroundColor];
    [self.navigationController.navigationBar setPrefersLargeTitles:YES];
    [self.navigationItem setLargeTitleDisplayMode:UINavigationItemLargeTitleDisplayModeAutomatic];
    
    if (@available(iOS 15.0, *)) {
        [self.navigationItem setRightBarButtonItems:@[
            [UIBarButtonItem.alloc initWithImage:[UIImage systemImageNamed:@"gear"] style:UIBarButtonItemStylePlain target:self action:@selector(settingsItemTapped:)],
            [UIBarButtonItem.alloc initWithImage:[[[UIImage systemImageNamed:@"heart.fill"] imageWithTintColor:[UIColor systemPinkColor]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(bookmarkItemTapped:)],
        ]];
    } else {
        [self.navigationItem setRightBarButtonItems:@[
            [UIBarButtonItem.alloc initWithImage:[[[UIImage systemImageNamed:@"heart.fill"] imageWithTintColor:[UIColor systemPinkColor]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(bookmarkItemTapped:)],
        ]];
    }
    
    [self setTableView:({
        UITableView *f = [UITableView.alloc initWithFrame:CGRectZero style:UITableViewStylePlain];
        [f setDelegate:self];
        [f setDataSource:self];
        [f setTableFooterView:UIView.new];
        [self.view addSubview:f];
        [f setTranslatesAutoresizingMaskIntoConstraints:NO];
        [f.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
        [f.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor].active = YES;
        [f.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor].active = YES;
        [f.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
        [f registerClass:CategoryCell.class forCellReuseIdentifier:NSStringFromClass(CategoryCell.class)];
        f;
    })];
    
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
}

- (void)bookmarkItemTapped:(UIBarButtonItem *)sender
{
    SymbolsViewController *symbolVC = [SymbolsViewController.alloc initWithCategory:[SFSymbolCategory favoriteCategory]];
    UINavigationController *navigationC = [UINavigationController.alloc initWithRootViewController:symbolVC];
    [self.splitViewController showDetailViewController:navigationC sender:self];
}

- (void)settingsItemTapped:(UIBarButtonItem *)sender
{
    // to specify the path for Settings.bundle
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    
    // to specify the root entry for that bundle
    NSString *xuiPath = [[NSBundle bundleWithPath:bundlePath] pathForResource:@"Root" ofType:@"plist"];
    
    // present or push it!
    XUIListViewController *xuiController = [[XUIListViewController alloc] initWithPath:xuiPath withBundlePath:bundlePath];
    [xuiController setTitle:NSLocalizedString(@"Settings", nil)];
    
    XUINavigationController *navController = [[XUINavigationController alloc] initWithRootViewController:xuiController];
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return SFSymbolDataSource.dataSource.categories.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 52.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CategoryCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(CategoryCell.class)];
    
    cell.selectedBackgroundView = UIView.new;
    cell.selectedBackgroundView.backgroundColor = self.view.tintColor;
    
    SFSymbolCategory *category = [self categoryForIndexPath:indexPath];
    
    [cell.textLabel setText:category.name];
    [cell.textLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
    [cell.detailTextLabel setText:@(category.symbols.count).stringValue];

    UIImage *categoryImage = [UIImage systemImageNamed:category.imageNamed];
    if (!categoryImage) {
        categoryImage = [UIImage systemImageNamed:@"questionmark.circle"];
    }
    [cell.imageView setImage:categoryImage];

    [cell.imageView setTintColor:cell.textLabel.textColor];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SymbolsViewController *symbolVC = [SymbolsViewController.alloc initWithCategory:[self categoryForIndexPath:indexPath]];
    UINavigationController *navigationC = [UINavigationController.alloc initWithRootViewController:symbolVC];
    [self.splitViewController showDetailViewController:navigationC sender:self];
}

- (void)dealloc
{
#ifdef DEBUG
    NSLog(@"- [%@ dealloc]", NSStringFromClass([self class]));
#endif
}

@end
