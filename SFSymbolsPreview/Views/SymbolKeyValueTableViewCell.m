//
//  SymbolKeyValueTableViewCell.m
//  SFSymbolsPreview
//
//  Created by Lessica on 2022/3/9.
//  Copyright © 2022 YICAI YANG. All rights reserved.
//

#import "SymbolKeyValueTableViewCell.h"

@implementation SymbolKeyValueTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    return [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
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
