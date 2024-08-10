//
//  SymbolTextTableViewCell.m
//  SFSymbolsPreview
//
//  Created by Lessica on 2022/3/9.
//  Copyright © 2022 YICAI YANG. All rights reserved.
//

#import "SymbolTextTableViewCell.h"

@implementation SymbolTextTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    if (self) {
        _centeredTextLabel = ({
            UILabel *l = UILabel.new;
            [l setTextColor:[UIColor labelColor]];
            [self.contentView addSubview:l];
            [l setTranslatesAutoresizingMaskIntoConstraints:NO];
            [l.leadingAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.leadingAnchor].active = YES;
            [l.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor].active = YES;
            [l.topAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.topAnchor].active = YES;
            l;
        });
        _centeredDetailTextLabel = ({
            UILabel *l = UILabel.new;
            [l setTextColor:[UIColor secondaryLabelColor]];
            [l setLineBreakMode:NSLineBreakByTruncatingTail];
            [l setTextAlignment:NSTextAlignmentRight];
            [l setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
            [self.contentView addSubview:l];
            [l setTranslatesAutoresizingMaskIntoConstraints:NO];
            [l.trailingAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.trailingAnchor].active = YES;
            [l.centerYAnchor constraintEqualToAnchor:self.centeredTextLabel.centerYAnchor].active = YES;
            [l.topAnchor constraintGreaterThanOrEqualToAnchor:self.contentView.layoutMarginsGuide.topAnchor].active = YES;
            [l.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.centeredTextLabel.trailingAnchor constant:8.f].active = YES;
            l;
        });
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
