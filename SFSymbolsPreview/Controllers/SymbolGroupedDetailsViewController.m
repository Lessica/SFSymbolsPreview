//
//  SymbolGroupedDetailsViewController.m
//  SFSymbolsPreview
//
//  Created by Mason Rachel on 2022/3/9.
//  Copyright © 2022 YICAI YANG. All rights reserved.
//

#import "SymbolGroupedDetailsViewController.h"
#import "SFSymbolDataSource.h"


@interface SymbolGroupedDetailsViewController () <UITableViewDelegate, UITableViewDataSource>

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
        [f setRowHeight:UITableViewAutomaticDimension];
        [f setTableFooterView:UIView.new];
        [self.view addSubview:f];
        [f setTranslatesAutoresizingMaskIntoConstraints:NO];
        [f.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
        [f.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor].active = YES;
        [f.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor].active = YES;
        [f.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
        [f registerClass:UITableViewCell.class forCellReuseIdentifier:NSStringFromClass(UITableViewCell.class)];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return self.symbol.useRestrictions;
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        return self.imageViewCell;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(UITableViewCell.class)];
    
    if (indexPath.section == 0) {
        if (indexPath.row == 1) {
            [cell.textLabel setText:[[NSLocalizedString(@"Copy", nil) stringByAppendingString:@" "] stringByAppendingString:self.symbol.name]];
            [cell.textLabel setNumberOfLines:0];
            [cell.textLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
            [cell.imageView setImage:[UIImage systemImageNamed:@"doc.on.doc"]];
            [cell.imageView setTintColor:self.view.tintColor];
        } else if (indexPath.row == 2) {
            [cell.textLabel setText:NSLocalizedString(@"Share...", nil)];
            [cell.textLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
            [cell.imageView setImage:[UIImage systemImageNamed:@"square.and.arrow.up"]];
            [cell.imageView setTintColor:self.view.tintColor];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
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

@end
