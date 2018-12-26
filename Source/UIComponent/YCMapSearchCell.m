//
//  YCMapSearchCell.m
//  youngcity
//
//  Created by zhitian on 2017/9/7.
//  Copyright © 2017年 Zhitian Network Tech. All rights reserved.
//

#import "YCMapSearchCell.h"

#import "ISWCategory.h"
#import "Masonry.h"
#import "YCDefines.h"

@interface YCMapSearchCell()

@property (nonatomic,strong) UILabel      *floorLabel;
@property (nonatomic,strong) UILabel      *titleLabel;
@property (nonatomic,strong) UIImageView  *starIcon;

@end

@implementation YCMapSearchCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = kColorWhite;
        self.contentView.backgroundColor = kColorWhite;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self favSeparatorInset];
        [self setupUI];
        
    }
    return self;
}

- (void)setupUI
{
    UILabel *titlelabel = [UILabel initWithLabelFont:[UIFont isw_Pingfang:15] textColor:kColorDeepDark];
    _titleLabel = titlelabel;
    [self.contentView addSubview:titlelabel];
    [titlelabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(42);
        make.top.equalTo(self.contentView).offset(14);
    }];
    
    UILabel *floorLabel = [UILabel initWithLabelFont:[UIFont isw_Pingfang:12] textColor:kColorGray];
    _floorLabel = floorLabel;
    floorLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:floorLabel];
    [floorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(42);
        make.top.equalTo(titlelabel.mas_bottom);
    }];
    
    _starIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_record"]];
    [self.contentView addSubview:_starIcon];
    [_starIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(16);
        make.top.equalTo(self.contentView).offset(23.5);
    }];
    
    UIImageView *slashArrowIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_go_normal"]];
    [self.contentView addSubview:slashArrowIcon];
    [slashArrowIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.contentView).offset(-14.4);
        make.top.equalTo(self.contentView).offset(22);
    }];
}

- (void)favSeparatorInset
{
    if ([self respondsToSelector:@selector(setLayoutMargins:)]) {
        [self setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
    }
    
    if ([self respondsToSelector:@selector(setSeparatorInset:)]) {
        [self setSeparatorInset:UIEdgeInsetsMake(0,42,0,10)];
    }
}

- (void)setupContent:(NSString*)title floor:(NSString*)floor icon:(NSString*)icon
{
    _titleLabel.text = title;
    _floorLabel.text = floor;
    _starIcon.image  = [UIImage imageNamed:icon];
}

@end
