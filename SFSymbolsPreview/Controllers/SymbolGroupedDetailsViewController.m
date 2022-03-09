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


@interface SymbolGroupedDetailsViewController () <UITableViewDelegate, UITableViewDataSource, UITableViewDragDelegate>

@property (nonatomic, strong) SFSymbol *symbol;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UITableViewCell *imageViewCell;
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation SymbolGroupedDetailsViewController

- (instancetype)initWithSymbol:(SFSymbol *)symbol {
    if ([super init]) {
        [self setSymbol:symbol];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:self.symbol.name];
    [self.view setBackgroundColor:UIColor.systemGroupedBackgroundColor];
    [self.navigationController.navigationBar setPrefersLargeTitles:YES];
    [self.navigationItem setLargeTitleDisplayMode:UINavigationItemLargeTitleDisplayModeAutomatic];
    
    [self setImageView:({
        UIImageView *v = UIImageView.new;
        [v setContentMode:UIViewContentModeScaleAspectFit];
        [v setTintColor:UIColor.labelColor];
        v;
    })];
    
    [self setImageViewCell:({
        UIImageView *v = self.imageView;
        UITableViewCell *c = [UITableViewCell.alloc initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        [c setSelectionStyle:UITableViewCellSelectionStyleNone];
        [c.contentView addSubview:v];
        [v setTranslatesAutoresizingMaskIntoConstraints:NO];
        [v.topAnchor constraintEqualToAnchor:c.contentView.topAnchor].active = YES;
        [v.bottomAnchor constraintEqualToAnchor:c.contentView.bottomAnchor].active = YES;
        [v.centerXAnchor constraintEqualToAnchor:c.contentView.centerXAnchor].active = YES;
        [v.leadingAnchor constraintEqualToAnchor:c.contentView.leadingAnchor].active = YES;
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
    
    [self updatePreviewSymbolImage];
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
    self.imageView.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
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
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(SymbolKeyValueTableViewCell.class)];
            [cell.textLabel setText:NSLocalizedString(@"Name", nil)];
            [cell.detailTextLabel setText:self.symbol.name];
            [cell.textLabel setNumberOfLines:1];
            [cell.textLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
            [cell.imageView setImage:nil];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        } else if (indexPath.row == 1) {
            cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(SymbolActionTableViewCell.class)];
            [cell.textLabel setText:NSLocalizedString(@"Copy Name", nil)];
            [cell.textLabel setNumberOfLines:1];
            [cell.textLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
            [cell.imageView setImage:[UIImage systemImageNamed:@"doc.on.doc"]];
            [cell.imageView setTintColor:self.view.tintColor];
            [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
        } else if (indexPath.row == 2) {
            cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(SymbolActionTableViewCell.class)];
            [cell.textLabel setText:NSLocalizedString(@"Share...", nil)];
            [cell.textLabel setNumberOfLines:1];
            [cell.textLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
            [cell.imageView setImage:[UIImage systemImageNamed:@"square.and.arrow.up"]];
            [cell.imageView setTintColor:self.view.tintColor];
            [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
        }
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(SymbolTextTableViewCell.class)];
            [cell.textLabel setText:self.symbol.availability.description];
            [cell.textLabel setNumberOfLines:0];
            [cell.textLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
            [cell.imageView setImage:nil];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
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
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSArray <UIDragItem *> *)tableView:(UITableView *)tableView itemsForBeginningDragSession:(id <UIDragSession>)session atIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        SFSymbol *symbol = self.symbol;
        
        NSItemProvider *symbolProvider = [[NSItemProvider alloc] initWithObject:symbol.image];
        UIDragItem *symbolDragItem = [[UIDragItem alloc] initWithItemProvider:symbolProvider];
        
        return @[symbolDragItem];
    }
    
    if (indexPath.section == 1 && indexPath.row == 0) {
        SFSymbol *symbol = self.symbol;
        
        NSItemProvider *symbolNameProvider = [[NSItemProvider alloc] initWithObject:symbol.name];
        UIDragItem *symbolNameDragItem = [[UIDragItem alloc] initWithItemProvider:symbolNameProvider];
        
        return @[symbolNameDragItem];
    }
    
    return @[];
}

- (void)dealloc
{
#ifdef DEBUG
    NSLog(@"- [%@ dealloc]", NSStringFromClass([self class]));
#endif
}

@end
