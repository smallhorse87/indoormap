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
}

@property (nonatomic, strong) YCIndoorSearchViewModel *viewModel;

@property (nonatomic, strong)UITableView *tableView;//stony debug

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

    // 设置导航控制器的代理为self
    //self.navigationController.delegate = self;
    self.navigationController.navigationBarHidden = YES;

    //导航栏设置
    [self buildSearchNav];

    [self buildTableView];
    
    [self buildFavoriteListView];
    
    [self keywordValueUpdated];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

//导航栏隐藏
//- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
//{
//    BOOL showSelf = [viewController isKindOfClass:[self class]];
//    [self.navigationController setNavigationBarHidden:showSelf animated:YES];
//}
//
//- (void)dealloc {
//    self.navigationController.delegate = nil;
//}

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
//stony debug
//             [weakSelf popToast:[viewModel.ntReqPhase unsignedIntegerValue]
//                          title:viewModel.ntReqPrompt];
             
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

//    stony debug self.navBar.hidden = YES;
    
    YCSearchNavBar *searchNavBar = [[YCSearchNavBar alloc] init];
    
    [self.view addSubview:searchNavBar];
    [searchNavBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(weakSelf.view).offset(12);
        make.trailing.equalTo(weakSelf.view).offset(-12);

        make.top.equalTo(weakSelf.view).offset(29);
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
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(12, 147, kScreenWidth-(12*2), kScreenHeight - 147) style:UITableViewStylePlain];
    self.tableView.contentInset        = UIEdgeInsetsMake(0, 0, 20, 0);
    self.tableView.rowHeight           = 56.0;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.dataSource = self;
    self.tableView.delegate   = self;
    [self.view addSubview:self.tableView];
    self.tableView.backgroundColor = kColorPageBg;
    self.view.backgroundColor = kColorPageBg;
    
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }

    //表格外形
    [self.tableView setSeparatorColor:kColorSeparator];
    [self.tableView isw_noSeparator];
}

#pragma mark - pop/dismiss UI
//stony debug
//- (void)popToast:(NtPhaseType)type title:(NSString*)title
//{
//    switch (type) {
//        case NtPhaseNone:
//            [ISWToast dismissToast];
//            break;
//
//        case NtPhaseResponseSuc:
//            [ISWToast dismissToast];
//            break;
//
//        case NtPhaseConnectionTimeout:
//        case NtPhaseNoConnection:
//        case NtPhaseResponseFail:
//            [ISWToast showFailToast:title];
//            break;
//
//        case NtPhaseRequesting:
//            [ISWToast showLoadingToast];
//            break;
//
//        default:
//            break;
//    }
//}

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

    [self.tableView setTableFooterView:cleanHistoryBtn];
}

- (void)dismissTableFooter
{
    [self.tableView setTableFooterView:nil];
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
    
    [self.tableView reloadData];

}

- (void)searchedPoiArrayValueUpdated
{
    [self constructSearchTable];

    [self dismissTableFooter];
    
    [self.tableView reloadData];
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

    [self.tableView reloadData];
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
    BaseCell *clickedCell = cellArr[indexPath.row];
    
    if(clickedCell.clickecBlock!=nil) {
        clickedCell.clickecBlock(clickedCell);
    }

}

#pragma mark - utilities

@end
