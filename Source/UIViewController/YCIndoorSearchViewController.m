//
//  YCIndoorSearchViewController.m
//  youngcity
//
//  Created by zhitian on 2017/9/7.
//  Copyright © 2017年 Zhitian Network Tech. All rights reserved.
//

#import "YCIndoorSearchViewController.h"

#import "KVOController.h"
#import "YCIndoorSearchViewModel.h"

#import "ISWCategory.h"
#import "ISWToast.h"

#import <Masonry.h>

#import "RTLbsMapView.h"
#import "RTLbs3DWebService.h"
#import "RTLbs3DPOIMessageClass.h"

#import "YCSearchNavBar.h"
#import "YCMapSearchCell.h"
#import "YCFavoriteListView.h"

@interface YCIndoorSearchViewController ()<UINavigationControllerDelegate,UITableViewDataSource,UITableViewDelegate>
{
    YCFavoriteListView   *_favoriteListView;

    NSMutableArray       *cellArr;
    
    YCSearchNavBar       *searchNavBar;
    UITableView          *tableView;
}

@property (nonatomic, strong) YCIndoorSearchViewModel *viewModel;

@end

@implementation YCIndoorSearchViewController

#pragma mark - viewcontroller life cycle

- (instancetype)initWithKeyword:(NSString*)keyword
{
    self = [super init];
    if (self) {
        [self bindWithViewModel:keyword];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    //导航栏设置
    [self buildSearchNav];

    [self buildTableView];
    
    [self buildFavoriteListView];
    
    [self keywordValueUpdated];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

#pragma mark - bind with viewmodel

- (void)bindWithViewModel:(NSString*)keyword
{
    if(self.viewModel)
        return;

    self.viewModel = [[YCIndoorSearchViewModel alloc] initWithKeyword:keyword];
    
    WEAKSELF
    FBKVOController *KVOController = [FBKVOController controllerWithObserver:self];
    self.KVOController = KVOController;
    [self.KVOController observe:self.viewModel
                       keyPaths:@[@"ntReqPhase",
                                  @"searchedPoiArray",
                                  @"keyword",
                                  @"specificPoiMc"]
                        options:NSKeyValueObservingOptionNew
                          block:
     ^(id observer, YCIndoorSearchViewModel *viewModel, NSDictionary *change) {
         
         NSString *key = [change objectForKey:@"FBKVONotificationKeyPathKey"];
         
         if([key isEqualToString:@"ntReqPhase"]) {

             [weakSelf popToast:[viewModel.ntReqPhase unsignedIntegerValue]
                          title:viewModel.ntReqPrompt];
             
         } else if ([key isEqualToString:@"searchedPoiArray"]) {
             [weakSelf searchedPoiArrayValueUpdated];

         } else if ([key isEqualToString:@"keyword"]) {
             [weakSelf keywordValueUpdated];

         } else if ([key isEqualToString:@"specificPoiMc"]) {
             [weakSelf specificPoiMcValueUpdated];

         }
         
         
     }];
}

#pragma mark - build UI

- (void)buildFavoriteListView
{
    WEAKSELF
    
    _favoriteListView = [[YCFavoriteListView alloc] init];
    [self.view addSubview:_favoriteListView];
    [_favoriteListView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self.view);
    }];
    
    _favoriteListView.hidden = YES;
    
    _favoriteListView.inputCompleted = ^(NSString *str) {
        NSArray *poiInfo = [str componentsSeparatedByString:@"|"];
        [weakSelf specificPOIPressed:poiInfo[0] floor:poiInfo[1]];

    };
}

- (void)buildSearchNav
{
    WEAKSELF

    searchNavBar = [[YCSearchNavBar alloc] init];

    [self.view addSubview:searchNavBar];
    [searchNavBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(weakSelf.view).offset(12);
        make.trailing.equalTo(weakSelf.view).offset(-12);

        if (@available(iOS 11.0, *))
        {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        }
        else
        {
            make.top.equalTo(weakSelf.view).offset(29);
        }
    }];
    
    searchNavBar.backBtnClicked = ^{
        [weakSelf cancelBtnPressed];
    };
    
    searchNavBar.pinBtnClicked = ^{
        [weakSelf pinModeBtnPressed];
    };
    
    searchNavBar.favBtnClicked = ^{
        [weakSelf favBtnPressed];
    };
    
    searchNavBar.inputDidChange = ^(NSString *str) {
        [weakSelf didFinishInput:str];
    };
}

- (void)buildTableView
{
    // Do any additional setup after loading the view.
    tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tableView.contentInset        = UIEdgeInsetsMake(0, 0, 20, 0);
    tableView.rowHeight           = 56.0;
    tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    tableView.showsVerticalScrollIndicator = NO;
    tableView.dataSource = self;
    tableView.delegate   = self;
    [self.view addSubview:tableView];
    tableView.backgroundColor = kColorPageBg;
    self.view.backgroundColor = kColorPageBg;

    [self.view addSubview:tableView];
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view).offset(12);
        make.trailing.equalTo(self.view).offset(-12);
        make.top.equalTo(searchNavBar.mas_bottom).offset(20);
        make.bottom.equalTo(self.view);
    }];

    if (@available(iOS 11.0, *)) {
        tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }

    //表格外形
    [tableView setSeparatorColor:kColorSeparator];
    [tableView isw_noSeparator];
}

#pragma mark - pop/dismiss UI

- (void)popToast:(YcNtPhaseType)type title:(NSString*)title
{
    switch (type) {
        case YcNtPhaseNone:
            [ISWToast dismissToast];
            break;

        case YcNtPhaseResponseSuc:
            [ISWToast dismissToast];
            break;

        case YcNtPhaseConnectionTimeout:
        case YcNtPhaseNoConnection:
        case YcNtPhaseResponseFail:
            [ISWToast showFailToast:title];
            break;

        case YcNtPhaseRequesting:
            [ISWToast showLoadingToast];
            break;

        default:
            break;
    }
}

- (void)popFavoriteListView
{
    _favoriteListView.hidden = NO;

    [_favoriteListView setupContent:_viewModel.favoritePoiArray];
}

- (void)popTableFooter
{
    UIButton *cleanHistoryBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cleanHistoryBtn.frame = CGRectMake(0, 0, kScreenWidth-(12*2), 46);
    cleanHistoryBtn.backgroundColor = kColorWhite;
    [cleanHistoryBtn isw_titleForAllState:@"清除搜索记录"];
    cleanHistoryBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [cleanHistoryBtn isw_titleColorForAllState:kColorGray];
    [cleanHistoryBtn isw_addClickAction:@selector(cleanHistoryBtnPressed) target:self];
    
    UIView *separatorLine = [[UIView alloc] initWithFrame:CGRectZero];
    separatorLine.backgroundColor     = kColorSeparator;
    [cleanHistoryBtn addSubview:separatorLine];
    [separatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(cleanHistoryBtn);
        make.height.equalTo(@(kOnePixel));
    }];

    [tableView setTableFooterView:cleanHistoryBtn];
}

- (void)dismissTableFooter
{
    [tableView setTableFooterView:nil];
}

#pragma mark - ui event

- (void)cleanHistoryBtnPressed
{
    [_viewModel onCleanHistoryReq];
}

- (void)favBtnPressed
{
    [self popFavoriteListView];
}

- (void)pinModeBtnPressed
{
    [self navBack];
}

- (void)cancelBtnPressed
{
    [self navBack];
}

- (void)didFinishInput:(NSString *)keyword
{
    [_viewModel onKeywordChanged:keyword];
}

- (void)searchRltPressed:(RTLbs3DPOIMessageClass*) poiMc
{
    self.selectedPoi(poiMc);

    [_viewModel onSaveSearchHistoryReq:poiMc.POI_Name floor:poiMc.POI_Floor];
    
    [self navBack];
}

- (void)specificPOIPressed:(NSString*)name floor:(NSString*)floor
{
    [_viewModel onPOISearchReq:name floor:floor];
}

#pragma mark - viewmodel event

- (void)specificPoiMcValueUpdated
{
    if(_viewModel.specificPoiMc==nil)
        return;
    
    RTLbs3DPOIMessageClass *poiMc = _viewModel.specificPoiMc;
    
    self.selectedPoi(poiMc);

    [_viewModel onSaveSearchHistoryReq:poiMc.POI_Name floor:poiMc.POI_Floor];

    [self navBack];
}

- (void)keywordValueUpdated
{
    if(!isEmptyString(_viewModel.keyword))
        return;
    
    NSArray *arr = _viewModel.historyPoiArray;
    
    [self constructHistoryTable];
    
    if(arr.count>3)
        [self popTableFooter];
    else
        [self dismissTableFooter];
    
    [tableView reloadData];

}

- (void)searchedPoiArrayValueUpdated
{
    [self constructSearchTable];

    [self dismissTableFooter];
    
    [tableView reloadData];
}

#pragma mark - router

- (void)navBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - table

- (void)constructSearchTable
{
    WEAKSELF
    
    cellArr = [[NSMutableArray alloc] init];
    
    for(int idx=0; idx<_viewModel.searchedPoiArray.count; idx++) {
        RTLbs3DPOIMessageClass *poiMc = _viewModel.searchedPoiArray[idx];
        YCMapSearchCell        *cell  = [[YCMapSearchCell alloc] init];

        [cell setupContent:poiMc.POI_Name floor:poiMc.POI_Floor icon:@"icon_search_local_1"];
        
        cell.clickecBlock = ^(UITableViewCell *cell) {
            [weakSelf searchRltPressed:poiMc];
        };
        
        [cellArr addObject:cell];
    }

    [tableView reloadData];
}

- (void)constructHistoryTable
{
    WEAKSELF

    cellArr = [[NSMutableArray alloc] init];
    
    NSArray *historyArr = _viewModel.historyPoiArray;
    
    for(int idx=0; idx<historyArr.count; idx++) {
        NSString *historyPoi    = historyArr[idx];
        NSArray *sepHisPoi      = [historyPoi componentsSeparatedByString:@"|"];

        YCMapSearchCell  *cell  = [[YCMapSearchCell alloc] init];
        [cell setupContent:sepHisPoi[0] floor:sepHisPoi[1] icon:@"icon_record"];

        cell.clickecBlock = ^(UITableViewCell *cell) {
            [weakSelf specificPOIPressed:sepHisPoi[0] floor:sepHisPoi[1]];
        };

        [cellArr addObject:cell];
    }

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return cellArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return cellArr[indexPath.row];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    IndoorMapBaseCell *clickedCell = cellArr[indexPath.row];
    
    if(clickedCell.clickecBlock!=nil) {
        clickedCell.clickecBlock(clickedCell);
    }

}

#pragma mark - utilities

@end
