//
//  ObjectCell.m
//  CommonViewControllers
//
//  Created by Lessica <82flex@gmail.com> on 2022/1/20.
//  Copyright © 2022 Zheng Wu. All rights reserved.
//

#import "ObjectCell.h"

@implementation ObjectCell

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
