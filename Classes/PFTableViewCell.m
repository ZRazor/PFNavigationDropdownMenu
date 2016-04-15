//
//  PFTableViewCell.m
//  PFNavigationDropdownMenu
//
//  Created by Cee on 02/08/2015.
//  Copyright (c) 2015 Cee. All rights reserved.
//

#import "PFTableViewCell.h"
#import "PFTableCellContentView.h"

@implementation PFTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
                configuration:(PFConfiguration *)configuration
                   isSelected:(BOOL)isSelected
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.configuration = configuration;
        
        // Setup cell
        self.cellContentFrame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, isSelected ? 0 : self.configuration.cellHeight);
        self.contentView.backgroundColor = self.configuration.cellBackgroundColor;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.textLabel.textAlignment = NSTextAlignmentLeft;
        self.textLabel.textColor = self.configuration.cellTextLabelColor;
        self.textLabel.font = self.configuration.cellTextLabelFont;
        self.textLabel.frame = CGRectMake(20, 0, self.cellContentFrame.size.width, self.cellContentFrame.size.height);
        
        // Checkmark icon
        self.checkmarkIcon = [[UIImageView alloc] initWithFrame:isSelected ? CGRectZero : CGRectMake(self.cellContentFrame.size.width - 50, (self.cellContentFrame.size.height - 30)/2, 30, 30)];
        self.checkmarkIcon.hidden = YES;
        self.checkmarkIcon.layer.masksToBounds = YES;
        self.checkmarkIcon.image = self.configuration.checkMarkImage;
        self.checkmarkIcon.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:self.checkmarkIcon];
        
        // Separator for cell
        PFTableCellContentView *separator = [[PFTableCellContentView alloc] initWithFrame:isSelected ? CGRectZero : self.cellContentFrame];
        separator.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:separator];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.bounds = self.cellContentFrame;
    self.contentView.frame = self.bounds;
}
@end
