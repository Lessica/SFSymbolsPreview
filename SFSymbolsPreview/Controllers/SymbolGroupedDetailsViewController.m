//
//  SymbolGroupedDetailsViewController.m
//  SFSymbolsPreview
//
//  Created by Mason Rachel on 2022/3/9.
//  Copyright © 2022 YICAI YANG. All rights reserved.
//

#import "SymbolGroupedDetailsViewController.h"
#import "SFSymbolDataSource.h"
#import "SymbolKeyValueTableViewCell.h"
#import "SymbolActionTableViewCell.h"
#import "SymbolTextTableViewCell.h"
#import "SFOutlineImageView.h"
#import "ObjectViewer/ObjectTableViewController.h"


@interface SymbolGroupedDetailsViewController () <UITableViewDelegate, UITableViewDataSource, UITableViewDragDelegate>

@property (nonatomic, strong) SFSymbol *symbol;
@property (nonatomic, assign, readonly) BOOL isSymbolBeingDisplayedInMonochrome;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UITableViewCell *imageViewCell;
@property (nonatomic, strong) SFOutlineImageView *imageView;

@property (nonatomic, strong) UIButton *favButton;

@end

@implementation SymbolGroupedDetailsViewController

- (instancetype)initWithSymbol:(SFSymbol *)symbol {
    if (self = [super init]) {
        _symbol = symbol;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:self.symbol.name];
    [self.view setBackgroundColor:UIColor.systemGroupedBackgroundColor];
    [self.navigationController.navigationBar setPrefersLargeTitles:YES];
    [self.navigationItem setLargeTitleDisplayMode:UINavigationItemLargeTitleDisplayModeAutomatic];
    
    [self setFavButton:({
        UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
        [b setFrame:CGRectMake(0, 0, 48, 44)];
        [b setImage:[UIImage systemImageNamed:@"heart.fill" withConfiguration:[UIImageSymbolConfiguration configurationWithScale:UIImageSymbolScaleLarge]] forState:UIControlStateSelected];
        [b setImage:[UIImage systemImageNamed:@"heart" withConfiguration:[UIImageSymbolConfiguration configurationWithScale:UIImageSymbolScaleLarge]] forState:UIControlStateNormal];
        [b.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [b setTintColor:[UIColor systemPinkColor]];
        [b addTarget:self action:@selector(favButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        b;
    })];
    
    [self.navigationItem setRightBarButtonItem:({
        [[UIBarButtonItem alloc] initWithCustomView:self.favButton];
    })];
    
    [self setImageView:({
        SFOutlineImageView *v = SFOutlineImageView.new;
        [v setContentMode:UIViewContentModeScaleAspectFit];
        [v setTintColor:UIColor.labelColor];
        v;
    })];
    
    [self setImageViewCell:({
        SFOutlineImageView *v = self.imageView;
        UITableViewCell *c = [UITableViewCell.alloc initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        [c setSelectionStyle:UITableViewCellSelectionStyleNone];
        [c.contentView addSubview:v];
        [v setTranslatesAutoresizingMaskIntoConstraints:NO];
        [v.topAnchor constraintEqualToAnchor:c.contentView.topAnchor].active = YES;
        [v.bottomAnchor constraintEqualToAnchor:c.contentView.bottomAnchor].active = YES;
        [v.centerXAnchor constraintEqualToAnchor:c.contentView.centerXAnchor].active = YES;
        [v.leadingAnchor constraintGreaterThanOrEqualToAnchor:c.contentView.leadingAnchor].active = YES;
        c;
    })];
    
    [self setTableView:({
        UITableView *f = [UITableView.alloc initWithFrame:CGRectZero style:UITableViewStyleInsetGrouped];
        [f setDelegate:self];
        [f setDataSource:self];
        [f setDragDelegate:self];
        [f setDragInteractionEnabled:YES];
        [f setRowHeight:UITableViewAutomaticDimension];
        [f setTableFooterView:UIView.new];
        [f setAllowsSelection:YES];
        [f setAllowsMultipleSelection:NO];
        [self.view addSubview:f];
        [f setTranslatesAutoresizingMaskIntoConstraints:NO];
        [f.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
        [f.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor].active = YES;
        [f.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor].active = YES;
        [f.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
        [f registerClass:SymbolKeyValueTableViewCell.class forCellReuseIdentifier:NSStringFromClass(SymbolKeyValueTableViewCell.class)];
        [f registerClass:SymbolActionTableViewCell.class forCellReuseIdentifier:NSStringFromClass(SymbolActionTableViewCell.class)];
        [f registerClass:SymbolTextTableViewCell.class forCellReuseIdentifier:NSStringFromClass(SymbolTextTableViewCell.class)];
        f;
    })];
    
    [self updateFavoriteState];
    [self updatePreviewSymbolImage];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)updateFavoriteState {
    [self.favButton setSelected:[[SFSymbolCategory favoriteCategory] containsSymbol:self.symbol]];
}

- (BOOL)isSymbolBeingDisplayedInMonochrome
{
    if ([preferredRenderMode() isEqualToString:SFSymbolLayerSetNameMonochrome])
    {
        return YES;
    }
    if (!self.symbol.supportsMulticolor && [preferredRenderMode() isEqualToString:SFSymbolLayerSetNameMulticolor])
    {
        return YES;
    }
    return NO;
}

- (void)updatePreviewSymbolImage {
    UIImage *image = nil;
    {
        CGRect imageRect = CGRectMake(0, 0, 512, 512);
        CGRect contentRect = CGRectInset(imageRect, 88, 88);
        CGFloat scale = 3.0f;
        
        image = self.symbol.image;
        image = [image toSize:CGSizeMake(contentRect.size.width, contentRect.size.width * image.size.height / image.size.width)];
        
        UIGraphicsBeginImageContextWithOptions(imageRect.size, NO, scale);
        [image drawAtPoint:CGPointMake(CGRectGetMidX(imageRect) - image.size.width / 2.0f, CGRectGetMidY(imageRect) - image.size.height / 2.0f)];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    if (self.isSymbolBeingDisplayedInMonochrome) {
        self.imageView.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    } else {
        self.imageView.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1 + self.symbol.symbolVariants.count;
    } else if (section == 1) {
        return 3;
    } else if (section == 2) {
        return 1;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 2) {
        return NSLocalizedString(@"Availability", nil);
    }
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return self.symbol.useRestrictions;
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            return self.imageViewCell;
        }
    }
    
    UITableViewCell *cell = nil;
    
    if (indexPath.section == 0) {
        NSInteger row = indexPath.row - 1;
        SFSymbol *symbolVariant = self.symbol.symbolVariants[row];
        
        cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(SymbolKeyValueTableViewCell.class)];
        [cell.textLabel setText:symbolVariant.variantName];
        [cell.detailTextLabel setText:symbolVariant.name];
        [cell.textLabel setNumberOfLines:1];
        [cell.textLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
        [cell.imageView setImage:symbolVariant.image];
        [cell.imageView setTintColor:UIColor.labelColor];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(SymbolKeyValueTableViewCell.class)];
            [cell.textLabel setText:NSLocalizedString(@"Name", nil)];
            [cell.detailTextLabel setText:self.symbol.name];
            [cell.textLabel setNumberOfLines:1];
            [cell.textLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
            [cell.imageView setImage:nil];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        } else if (indexPath.row == 1) {
            cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(SymbolActionTableViewCell.class)];
            [cell.textLabel setText:NSLocalizedString(@"Copy Name", nil)];
            [cell.textLabel setNumberOfLines:1];
            [cell.textLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
            [cell.imageView setImage:[UIImage systemImageNamed:@"doc.on.doc"]];
            [cell.imageView setTintColor:self.view.tintColor];
            [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        } else if (indexPath.row == 2) {
            cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(SymbolActionTableViewCell.class)];
            [cell.textLabel setText:NSLocalizedString(@"Share...", nil)];
            [cell.textLabel setNumberOfLines:1];
            [cell.textLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
            [cell.imageView setImage:[UIImage systemImageNamed:@"square.and.arrow.up"]];
            [cell.imageView setTintColor:self.view.tintColor];
            [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            SymbolTextTableViewCell *textCell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(SymbolTextTableViewCell.class)];
            [textCell.centeredTextLabel setText:self.symbol.availability.description];
            [textCell.centeredTextLabel setNumberOfLines:0];
            [textCell.centeredTextLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
            [textCell.imageView setImage:nil];
            [textCell setSelectionStyle:UITableViewCellSelectionStyleDefault];
            [textCell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            cell = textCell;
        }
    }
    
    return cell ?: [UITableViewCell new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        if (indexPath.row == 1) {
            UIPasteboard.generalPasteboard.string = self.symbol.name;
        } else if (indexPath.row == 2) {
            UIActivityViewController *activityVC = [UIActivityViewController.alloc initWithActivityItems:@[ self.symbol.name, self.imageView.image ]
                                                                                   applicationActivities:nil];
            if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
                activityVC.popoverPresentationController.sourceView = [tableView cellForRowAtIndexPath:indexPath];
                activityVC.popoverPresentationController.sourceRect = activityVC.popoverPresentationController.sourceView.bounds;
            }
            [self presentViewController:activityVC animated:YES completion:nil];
        }
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            NSMutableArray <NSDictionary *> *availabilityObject = [[NSMutableArray alloc] initWithCapacity:self.symbol.symbolAliases.count + 1];
            [availabilityObject addObject:self.symbol.availabilityDictionary];
            for (SFSymbol *aliasSymbol in self.symbol.symbolAliases) {
                if (aliasSymbol.availability) {
                    NSMutableDictionary *aliasDictionary = [aliasSymbol.availabilityDictionary mutableCopy];
                    [aliasDictionary setObject:NSLocalizedString(@"This name has been deprecated. You should use a more modern name if your app does not need to support older platforms.", nil) forKey:@"__DESCRIPTION__"];
                    [availabilityObject addObject:aliasDictionary];
                }
            }
            ObjectTableViewController *objectVC = [ObjectTableViewController.alloc initWithObject:availabilityObject];
            [objectVC setTitle:NSLocalizedString(@"Availability", nil)];
            [objectVC setInitialRootExpanded:YES];
            [objectVC setInitialRootHidden:YES];
            [objectVC setPressToCopy:YES];
            [self.navigationController pushViewController:objectVC animated:YES];
        }
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        if (indexPath.row == 2) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"These glyphs seem to have been given code points in Unicode‘s Supplementary Private Use Area B. Perhaps the iOS apps don‘t have the ability to deal with that yet.", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }
}

- (NSArray <UIDragItem *> *)tableView:(UITableView *)tableView itemsForBeginningDragSession:(id <UIDragSession>)session atIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        SFSymbol *symbol = nil;
        if (indexPath.section == 0 && indexPath.row == 0) {
            symbol = self.symbol;
        } else {
            NSInteger row = indexPath.row - 1;
            symbol = self.symbol.symbolVariants[row];
        }
        
        NSItemProvider *symbolProvider = [[NSItemProvider alloc] initWithObject:symbol.image];
        UIDragItem *symbolDragItem = [[UIDragItem alloc] initWithItemProvider:symbolProvider];
        
        return @[symbolDragItem];
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        SFSymbol *symbol = self.symbol;
        
        NSItemProvider *symbolNameProvider = [[NSItemProvider alloc] initWithObject:symbol.name];
        UIDragItem *symbolNameDragItem = [[UIDragItem alloc] initWithItemProvider:symbolNameProvider];
        
        return @[symbolNameDragItem];
    }
    
    return @[];
}

- (void)favButtonTapped:(UIBarButtonItem *)sender
{
    SFSymbolCategory *favoriteCategory = [SFSymbolCategory favoriteCategory];
    if ([favoriteCategory containsSymbol:self.symbol]) {
        [favoriteCategory removeSymbolsInArray:@[self.symbol]];
    } else {
        [favoriteCategory addSymbolsFromArray:@[self.symbol]];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:SFSymbolFavoritesDidUpdateNotification object:self.symbol];
    [self updateFavoriteState];
}

- (void)dealloc
{
#ifdef DEBUG
    NSLog(@"- [%@ dealloc]", NSStringFromClass([self class]));
#endif
}

@end
