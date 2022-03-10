//
//  SFReusableTitleView.m
//  SFSymbolsPreview
//
//  Created by YICAI YANG on 2020/5/27.
//  Copyright © 2020 YICAI YANG. All rights reserved.
//

#import "SFSymbolDataSource.h"
#import "SFReusableTitleView.h"


@interface SFReusableTitleView ()

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation SFReusableTitleView

- (void)setTitle:(NSString *)title
{
    _title = title;
    self.titleLabel.text = title;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if ([super initWithFrame:frame])
    {
        [self setTitleLabel:({
            UILabel *f = UILabel.new;
            [f setTextColor:UIColor.secondaryLabelColor];
            [f setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleFootnote]];
            [f setAdjustsFontForContentSizeCategory:YES];
            [self addSubview:f];
            [f setTranslatesAutoresizingMaskIntoConstraints:NO];
            [f.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:16].active = YES;
            [f.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
            f;
        })];
    }
    return self;
}

@end


@interface SFReusableSegmentedControlView ()

@end

@implementation SFReusableSegmentedControlView

- (instancetype)initWithFrame:(CGRect)frame
{
    if ([super initWithFrame:frame])
    {
        [self setSegmentedControl:({
            NSArray <NSString *> *items = @[@"", @"", @"", @""];
            UISegmentedControl *f = [UISegmentedControl.alloc initWithItems:items];
            [self addSubview:f];
            [f setTranslatesAutoresizingMaskIntoConstraints:NO];
            [f.widthAnchor constraintEqualToAnchor:self.widthAnchor constant:-32.0f].active = YES;
            [f.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
            [f.topAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor constant:8.f].active = YES;
            f;
        })];
        [self updateSegmentedTitles];
    }
    return self;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [self updateSegmentedTitles];
}

- (void)updateSegmentedTitles {
    if (IS_IPAD(self)) {
        [self.segmentedControl setTitle:NSLocalizedString(@"One", nil) forSegmentAtIndex:0];
        [self.segmentedControl setTitle:NSLocalizedString(@"Four", nil) forSegmentAtIndex:1];
        [self.segmentedControl setTitle:NSLocalizedString(@"Six", nil) forSegmentAtIndex:2];
        [self.segmentedControl setTitle:NSLocalizedString(@"Eight", nil) forSegmentAtIndex:3];
    } else {
        [self.segmentedControl setTitle:NSLocalizedString(@"One", nil) forSegmentAtIndex:0];
        [self.segmentedControl setTitle:NSLocalizedString(@"Two", nil) forSegmentAtIndex:1];
        [self.segmentedControl setTitle:NSLocalizedString(@"Three", nil) forSegmentAtIndex:2];
        [self.segmentedControl setTitle:NSLocalizedString(@"Four", nil) forSegmentAtIndex:3];
    }
}

@end
