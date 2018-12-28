//
//  YCFavoriteListView.m
//  youngcity
//
//  Created by chenxiaosong on 2018/4/22.
//  Copyright © 2018年 Zhitian Network Tech. All rights reserved.
//

#import "YCFavoriteListView.h"

#import "ISWCategory.h"
#import <Masonry.h>

#import "IndoorMapBaseCell.h"

@interface YCFavoriteCell : IndoorMapBaseCell

@property (nonatomic,strong) UILabel      *floorLabel;
@property (nonatomic,strong) UILabel      *titleLabel;

@end

@implementation YCFavoriteCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
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
        make.top.equalTo(self.contentView).offset(12);
    }];

    UILabel *floorLabel = [UILabel initWithLabelFont:[UIFont isw_Pingfang:12] textColor:kColorGray];
    _floorLabel = floorLabel;
    floorLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:floorLabel];
    [floorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(42);
        make.top.equalTo(titlelabel.mas_bottom);
    }];
    
    UIImageView *starIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"YCIndoorMap.bundle/icon_search_collect"]];
    [self.contentView addSubview:starIcon];
    [starIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(16);
        make.top.equalTo(self.contentView).offset(22.5);
    }];

    UIImageView *slashArrowIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"YCIndoorMap.bundle/map_go_normal"]];
    [self.contentView addSubview:slashArrowIcon];
    [slashArrowIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.contentView).offset(-14.4);
        make.top.equalTo(self.contentView).offset(16);
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


- (void)setupContent:(NSString*)title floor:(NSString*)floor
{
    _titleLabel.text = title;
    _floorLabel.text = floor;
}

@end

@interface YCFavoriteListView()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation YCFavoriteListView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
{
    NSMutableArray  *_cellArr;
    
    UITableView     *_tableView;
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = kColorNone;
        [self buildUI];
    }
    return self;
}

- (void)buildUI
{
    WEAKSELF
    
    UIView *maskView = [[UIView alloc]init];
    maskView.backgroundColor = kColorBlack;
    maskView.alpha = 0.35;
    [self addSubview:maskView];
    [maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self);
    }];
    UITapGestureRecognizer *tapBgGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bgViewTapped)];
    [maskView addGestureRecognizer:tapBgGesture];

    UIView *bgView          = [[UIView alloc] initWithFrame:CGRectZero];
    bgView.backgroundColor  = kColorWhite;
    [self addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(weakSelf);
        make.bottom.equalTo(weakSelf);
        make.height.equalTo(@(325));
    
    }];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn isw_titleForAllState:@"取消"];
    [cancelBtn isw_titleColorForAllState:kColorBlack];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [cancelBtn isw_addClickAction:@selector(cancelBtnPressed) target:self];
    [bgView addSubview:cancelBtn];
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@40);
        make.leading.trailing.equalTo(bgView);
        make.bottom.equalTo(bgView);
    }];
    
    UIView *separator = [[UIView alloc] initWithFrame:CGRectZero];
    separator.backgroundColor     = kColorSeparator;
    [bgView addSubview:separator];
    [separator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(bgView);
        make.top.equalTo(cancelBtn);

        make.height.equalTo(@(kOnePixel));
    }];
    
    _tableView = [[UITableView alloc] init];
    [_tableView isw_noSeparator];
    _tableView.bounces  = NO;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.separatorColor = kColorSeparator;
    _tableView.backgroundColor = kColorPageBg;
    _tableView.rowHeight = 56.0;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [bgView addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(bgView);
        make.bottom.equalTo(bgView).offset(-40);
        make.top.equalTo(bgView).offset(5.5);
    }];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _cellArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return _cellArr[indexPath.row];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    IndoorMapBaseCell *clickedCell = _cellArr[indexPath.row];

    if(clickedCell.clickecBlock!=nil) {
        clickedCell.clickecBlock();
    }
    
}

- (void)cancelBtnPressed
{
    self.hidden = YES;
}

- (void)bgViewTapped
{
    self.hidden = YES;
}

- (void)setupContent:(NSArray *)poiArr
{
    WEAKSELF
    
    _cellArr = [[NSMutableArray alloc] init];
    
    for(NSString *catPoi in poiArr) {
        YCFavoriteCell *routeCell = [[YCFavoriteCell alloc] init];
        
        NSArray *poiInfo = [catPoi componentsSeparatedByString:@"|"];

        [routeCell setupContent:poiInfo[0] floor:poiInfo[1]];

        routeCell.clickecBlock = ^() {
            weakSelf.hidden = YES;
            if(weakSelf.inputCompleted) _inputCompleted(catPoi);
        };

        [_cellArr addObject:routeCell];
    }

    UITableViewCell *lastCell = [_cellArr lastObject];
    [lastCell isw_noSeparator];

    [_tableView reloadData];
    
    NSIndexPath * idxPathFirstCell = [NSIndexPath indexPathForRow:0 inSection:0];
    [_tableView scrollToRowAtIndexPath:idxPathFirstCell
                      atScrollPosition:UITableViewScrollPositionTop
                              animated:NO];
}

@end
