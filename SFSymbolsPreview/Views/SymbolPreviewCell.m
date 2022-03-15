//
//  SymbolPreviewCell.m
//  SFSymbolsPreview
//
//  Created by YICAI YANG on 2020/5/27.
//  Copyright © 2020 YICAI YANG. All rights reserved.
//

#import "SymbolPreviewCell.h"
#import "SFSymbolCategory.h"

@interface SymbolPreviewCell ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UIButton *favButton;
@property (nonatomic, strong) UIButton *infoButton;

@property (nonatomic, strong) UIView *selectedHighlightView;

@end

@implementation SymbolPreviewCell

- (void)setSymbol:(SFSymbol *)symbol
{
    _symbol = symbol;
    
    self.textLabel.text = symbol.name;
    self.imageView.image = symbol.image;
    self.infoButton.hidden = !symbol.useRestrictions;
    self.favButton.hidden = _hidesFavoriteButton || ![[SFSymbolCategory favoriteCategory] containsSymbol:symbol];
}

- (void)setHidesFavoriteButton:(BOOL)hidesFavoriteButton
{
    _hidesFavoriteButton = hidesFavoriteButton;
    if ([self.favButton isHidden] != hidesFavoriteButton) {
        [self.favButton setHidden:hidesFavoriteButton];
    }
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    self.textLabel.attributedText = attributedText;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    [self.selectedHighlightView setBackgroundColor:selected ? self.tintColor : UIColor.secondarySystemBackgroundColor];
    [self.imageView setTintColor:selected ? UIColor.whiteColor : UIColor.labelColor];
    [self.favButton setTintColor:selected ? UIColor.whiteColor : UIColor.systemPinkColor];
    [self.infoButton setTintColor:selected ? UIColor.whiteColor : UIColor.secondaryLabelColor];
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    [self.selectedHighlightView setBackgroundColor:highlighted ? self.tintColor : UIColor.secondarySystemBackgroundColor];
    [self.imageView setTintColor:highlighted ? UIColor.whiteColor : UIColor.labelColor];
    [self.favButton setTintColor:highlighted ? UIColor.whiteColor : UIColor.systemPinkColor];
    [self.infoButton setTintColor:highlighted ? UIColor.whiteColor : UIColor.secondaryLabelColor];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if ([super initWithFrame:frame])
    {
        [self setSelectedHighlightView:({
            UIView *f = UIView.new;
            [f.layer setCornerRadius:12.f];
            [f setBackgroundColor:[UIColor secondarySystemBackgroundColor]];
            [self.contentView addSubview:f];
            [f setTranslatesAutoresizingMaskIntoConstraints:NO];
            [f.topAnchor constraintEqualToAnchor:self.contentView.topAnchor].active = YES;
            [f.widthAnchor constraintEqualToAnchor:self.contentView.widthAnchor].active = YES;
            [f.heightAnchor constraintEqualToAnchor:self.contentView.widthAnchor multiplier:.68f].active = YES;
            [f.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor].active = YES;
            f;
        })];
        
        [self setImageView:({
            UIImageView *f = [UIImageView.alloc init];
            [f setContentMode:UIViewContentModeScaleAspectFit];
            [f setTintColor:UIColor.labelColor];
            UIView *w = [UIView.alloc init];
            [w setClipsToBounds:NO];
            [w addSubview:f];
            [f setTranslatesAutoresizingMaskIntoConstraints:NO];
            [f.topAnchor constraintEqualToAnchor:w.topAnchor].active = YES;
            [f.leadingAnchor constraintEqualToAnchor:w.leadingAnchor].active = YES;
            [f.trailingAnchor constraintEqualToAnchor:w.trailingAnchor].active = YES;
            [f.bottomAnchor constraintEqualToAnchor:w.bottomAnchor].active = YES;
            [self.selectedHighlightView addSubview:w];
            [w setTranslatesAutoresizingMaskIntoConstraints:NO];
            [w.heightAnchor constraintEqualToAnchor:self.selectedHighlightView.heightAnchor multiplier:.68f].active = YES;
            [w.widthAnchor constraintEqualToAnchor:f.heightAnchor].active = YES;
            [w.centerXAnchor constraintEqualToAnchor:self.selectedHighlightView.centerXAnchor].active = YES;
            [w.centerYAnchor constraintEqualToAnchor:self.selectedHighlightView.centerYAnchor].active = YES;
            f;
        })];
        [self setTextLabel:({
            UILabel *f = UILabel.new;
            [f setNumberOfLines:2];
            [f setTextAlignment:NSTextAlignmentCenter];
            [f setLineBreakMode:NSLineBreakByTruncatingTail];
            [f setTextColor:[UIColor secondaryLabelColor]];
            [f setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]];
            [f setAdjustsFontForContentSizeCategory:YES];
            [self.contentView addSubview:f];
            [f setTranslatesAutoresizingMaskIntoConstraints:NO];
            [f.topAnchor constraintEqualToAnchor:self.selectedHighlightView.bottomAnchor constant:8.0f].active = YES;
            [f.widthAnchor constraintEqualToAnchor:self.contentView.widthAnchor constant:-8.0f].active = YES;
            [f.centerXAnchor constraintEqualToAnchor:self.imageView.centerXAnchor].active = YES;
            f;
        })];
        [self setFavButton:({
            UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
            [b setImage:[UIImage systemImageNamed:@"heart.fill"] forState:UIControlStateNormal];
            [b.imageView setContentMode:UIViewContentModeScaleAspectFit];
            [b setTintColor:[UIColor systemPinkColor]];
            [self.selectedHighlightView addSubview:b];
            [b setTranslatesAutoresizingMaskIntoConstraints:NO];
            [b.heightAnchor constraintEqualToConstant:18.f].active = YES;
            [b.widthAnchor constraintEqualToAnchor:b.heightAnchor].active = YES;
            [b.leadingAnchor constraintEqualToAnchor:self.selectedHighlightView.leadingAnchor constant:4.f].active = YES;
            [b.bottomAnchor constraintEqualToAnchor:self.selectedHighlightView.bottomAnchor constant:-4.f].active = YES;
            [b addTarget:self action:@selector(favButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            b;
        })];
        [self setInfoButton:({
            UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
            [b setImage:[UIImage systemImageNamed:@"info.circle.fill"] forState:UIControlStateNormal];
            [b.imageView setContentMode:UIViewContentModeScaleAspectFit];
            [b setTintColor:[UIColor secondaryLabelColor]];
            [self.selectedHighlightView addSubview:b];
            [b setTranslatesAutoresizingMaskIntoConstraints:NO];
            [b.heightAnchor constraintEqualToConstant:18.f].active = YES;
            [b.widthAnchor constraintEqualToAnchor:b.heightAnchor].active = YES;
            [b.trailingAnchor constraintEqualToAnchor:self.selectedHighlightView.trailingAnchor constant:-4.f].active = YES;
            [b.bottomAnchor constraintEqualToAnchor:self.selectedHighlightView.bottomAnchor constant:-4.f].active = YES;
            [b addTarget:self action:@selector(infoButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            b;
        })];
    }
    return self;
}

- (void)infoButtonTapped:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(symbolPreviewShowDetailedInfo:)]) {
        [self.delegate symbolPreviewShowDetailedInfo:self.symbol];
    }
}

- (void)favButtonTapped:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(symbolPreviewRemoveFromFavorite:)]) {
        [self.delegate symbolPreviewRemoveFromFavorite:self.symbol];
    }
}

@end


@interface SymbolPreviewTableCell ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *textLabel;

@property (nonatomic, strong) NSLayoutConstraint *infoButtonLeadingConstraint;
@property (nonatomic, strong) UIButton *infoButton;
@property (nonatomic, strong) UIButton *favButton;

@end

@implementation SymbolPreviewTableCell

- (void)setSymbol:(SFSymbol *)symbol
{
    _symbol = symbol;
    
    self.textLabel.text = symbol.name;
    self.imageView.image = symbol.image;
    BOOL hasRestrictions = symbol.useRestrictions != nil;
    self.infoButtonLeadingConstraint.active = hasRestrictions;
    
    BOOL isFavHidden = _hidesFavoriteButton || ![[SFSymbolCategory favoriteCategory] containsSymbol:symbol];
    BOOL isInfoHidden = !isFavHidden || !hasRestrictions;
    
    if (self.infoButton.hidden != isInfoHidden) {
        self.infoButton.hidden = isInfoHidden;
    }
    if (self.favButton.hidden != isFavHidden) {
        self.favButton.hidden = isFavHidden;
    }
}

- (void)setHidesFavoriteButton:(BOOL)hidesFavoriteButton
{
    _hidesFavoriteButton = hidesFavoriteButton;
    if ([self.favButton isHidden] != hidesFavoriteButton) {
        [self.favButton setHidden:hidesFavoriteButton];
    }
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    self.textLabel.attributedText = attributedText;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    [self setColorsHighlighted:selected];
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    [self setColorsHighlighted:highlighted];
}

- (void)setColorsHighlighted:(BOOL)highlighted {
    [self.contentView setBackgroundColor:highlighted ? self.tintColor : UIColor.clearColor];
    [self.imageView setTintColor:highlighted ? UIColor.whiteColor : UIColor.labelColor];
    [self.infoButton setTintColor:highlighted ? UIColor.whiteColor : UIColor.secondaryLabelColor];
    if (self.attributedText) {
        if (highlighted) {
            NSMutableAttributedString *mAttributedText = [self.attributedText mutableCopy];
            [mAttributedText addAttribute:NSForegroundColorAttributeName value:UIColor.whiteColor range:NSMakeRange(0, mAttributedText.length)];
            [self.textLabel setAttributedText:mAttributedText];
        } else {
            [self.textLabel setAttributedText:self.attributedText];
        }
    } else {
        [self.textLabel setTextColor:highlighted ? UIColor.whiteColor : UIColor.labelColor];
    }
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if ([super initWithFrame:frame])
    {
        [self.contentView.layer setCornerRadius:2.0f];
        
        [self setImageView:({
            UIImageView *f = [UIImageView.alloc initWithImage:[UIImage systemImageNamed:@"paperplane.fill"]];
            [f setContentMode:UIViewContentModeScaleAspectFit];
            [f setTintColor:UIColor.labelColor];
            [self.contentView addSubview:f];
            [f setTranslatesAutoresizingMaskIntoConstraints:NO];
            [f.leftAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leftAnchor].active = YES;
            [f.widthAnchor constraintEqualToConstant:26.f].active = YES;
            [f.heightAnchor constraintEqualToConstant:26.f].active = YES;
            [f.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor].active = YES;
            f;
        })];
        [self setTextLabel:({
            UILabel *f = UILabel.new;
            [f setTextAlignment:NSTextAlignmentLeft];
            [f setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
            [f setAdjustsFontForContentSizeCategory:YES];
            [f setNumberOfLines:1];
            [self.contentView addSubview:f];
            [f setTranslatesAutoresizingMaskIntoConstraints:NO];
            [f.leadingAnchor constraintEqualToAnchor:self.imageView.trailingAnchor constant:16.f].active = YES;
            
            NSLayoutConstraint *trailingConstraint = [f.rightAnchor constraintEqualToAnchor:self.layoutMarginsGuide.rightAnchor];
            trailingConstraint.priority = UILayoutPriorityDefaultHigh;
            trailingConstraint.active = YES;
            
            [f.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor].active = YES;
            [f setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
            f;
        })];
        [self setInfoButton:({
            UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
            [b setImage:[UIImage systemImageNamed:@"info.circle.fill"] forState:UIControlStateNormal];
            [b.imageView setContentMode:UIViewContentModeScaleAspectFit];
            [b setTintColor:[UIColor secondaryLabelColor]];
            [self.contentView addSubview:b];
            [b setTranslatesAutoresizingMaskIntoConstraints:NO];
            [b.heightAnchor constraintEqualToConstant:18.f].active = YES;
            [b.widthAnchor constraintEqualToAnchor:b.heightAnchor].active = YES;
            [b.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor constant:-4.f].active = YES;
            [b.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor].active = YES;
            [b addTarget:self action:@selector(infoButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            b;
        })];
        [self setInfoButtonLeadingConstraint:({
            NSLayoutConstraint *c = [self.infoButton.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.textLabel.trailingAnchor constant:8.f];
            c.active = YES;
            c;
        })];
        [self setFavButton:({
            UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
            [b setImage:[UIImage systemImageNamed:@"heart.fill"] forState:UIControlStateNormal];
            [b.imageView setContentMode:UIViewContentModeScaleAspectFit];
            [b setTintColor:[UIColor systemPinkColor]];
            [self.contentView addSubview:b];
            [b setTranslatesAutoresizingMaskIntoConstraints:NO];
            [b.heightAnchor constraintEqualToConstant:18.f].active = YES;
            [b.widthAnchor constraintEqualToAnchor:b.heightAnchor].active = YES;
            [b.topAnchor constraintEqualToAnchor:self.infoButton.topAnchor].active = YES;
            [b.leadingAnchor constraintEqualToAnchor:self.infoButton.leadingAnchor].active = YES;
            [b addTarget:self action:@selector(favButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            b;
        })];
        
        UIView *stroke = UIView.new;
        [stroke setUserInteractionEnabled:NO];
        [stroke setBackgroundColor:UIColor.separatorColor];
        [self.contentView addSubview:stroke];
        [stroke setTranslatesAutoresizingMaskIntoConstraints:NO];
        [stroke.widthAnchor constraintEqualToAnchor:self.contentView.widthAnchor].active = YES;
        [stroke.heightAnchor constraintEqualToConstant:1.0f / UIScreen.mainScreen.scale].active = YES;
        [stroke.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor].active = YES;
        [stroke.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor].active = YES;
    }
    return self;
}

- (void)infoButtonTapped:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(symbolPreviewShowDetailedInfo:)]) {
        [self.delegate symbolPreviewShowDetailedInfo:self.symbol];
    }
}

- (void)favButtonTapped:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(symbolPreviewRemoveFromFavorite:)]) {
        [self.delegate symbolPreviewRemoveFromFavorite:self.symbol];
    }
}

@end
