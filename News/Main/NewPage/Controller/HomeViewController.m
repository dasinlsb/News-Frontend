//
//  HomeViewController.m
//  News
//
//  Created by tplish on 2019/12/15.
//  Copyright © 2019 Team09. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HomeViewController.h"
#import "../View/NavTitleView.h"
#import "../Model/TabModel.h"
#import "SearchViewController.h"
#import "TabCollectionViewController.h"
#import "ContentPageViewController.h"
#import "Base/Controller/DownloadViewController.h"
#import "Base/GlobalVariable.h"
#import "Base/NetRequest.h"
#import "Masonry.h"

@interface HomeViewController()
@property (nonatomic, strong) NavTitleView * navTitleView;
@property (nonatomic, strong) UIBarButtonItem * rightBarBtnItem;
@property (nonatomic, strong) TabCollectionViewController * tabCVC;
@property (nonatomic, strong) ContentPageViewController * contentPVC;
@property (nonatomic, strong) NSMutableArray * tabs;
@property (nonatomic, strong) NSMutableArray * contents;

@property (nonatomic, strong) TabModel * tabModel;
@end

@implementation HomeViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.navigationItem.titleView = self.navTitleView;
    self.navigationItem.rightBarButtonItem = self.rightBarBtnItem;
    
    [self.view addSubview:self.tabCVC.view];
    [self.view addSubview:self.contentPVC.view];
    [self.tabCVC configArray:self.tabs TabWeight:120 TabHeight:50 Index:0 Block:^(NSInteger index) {
        [self.contentPVC updateIndex:index];
    }];
    [self.contentPVC configArray:self.contents Index:0 Block:^(NSInteger index) {
        [self.tabCVC updateIndex:index];
    }];
    [self.tabCVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.width.mas_equalTo(self.view);
        make.height.mas_equalTo(60);
    }];
    [self.contentPVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.tabCVC.view.mas_bottom);
        make.width.bottom.equalTo(self.view);
    }];
}

- (NavTitleView *)navTitleView{
    if (_navTitleView == nil){
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToSearchPage)];
        _navTitleView = [[NavTitleView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
        _navTitleView.userInteractionEnabled = YES;
        [_navTitleView addGestureRecognizer:tap];
        
        UISearchBar * bar = [[UISearchBar alloc] init];
        bar.userInteractionEnabled = NO;
        [_navTitleView addSubview:bar];
        
        [bar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.width.height.mas_equalTo(self.navTitleView);
        }];
    }
    return _navTitleView;
}

- (UIBarButtonItem *)rightBarBtnItem{
    if (_rightBarBtnItem == nil){
        _rightBarBtnItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"home_tab"] style:UIBarButtonItemStyleDone target:self action:@selector(goToDownloadPage)];
    }
    return _rightBarBtnItem;
}

- (TabCollectionViewController *)tabCVC{
    if (_tabCVC == nil){
        _tabCVC = [[TabCollectionViewController alloc] init];
    }
    return _tabCVC;
}

- (ContentPageViewController *)contentPVC{
    if (_contentPVC == nil){
        _contentPVC = [[ContentPageViewController alloc] init];
    }
    return _contentPVC;
}

- (TabModel *)tabModel{
    if (_tabModel == nil){
        _tabModel = [[TabModel alloc] init];
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        [[NetRequest shareInstance] GET:[BaseUrl stringByAppendingString:@"/news/tabs"] params:nil progress:^(id downloadProgress) {
        } success:^(id responseObject) {
            self->_tabModel.len = [[responseObject objectForKey:@"len"] integerValue];
            self->_tabModel.names = [responseObject objectForKey:@"names"];
            dispatch_semaphore_signal(sema);
        } failues:^(id error) {
            dispatch_semaphore_signal(sema);
        }];
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }
    return _tabModel;
}

- (NSMutableArray *)tabs{
    if (_tabs == nil){
        _tabs = [NSMutableArray array];
        for (int i=0; i<self.tabModel.len; i++){
            [_tabs addObject:self.tabModel.names[i]];
        }
    }
    return _tabs;
}

- (NSMutableArray *)contents{
    if (_contents == nil){
        _contents = [NSMutableArray array];
        for (int i=0; i<self.tabModel.len; i++){
            double r = (arc4random() % 256);
            double g = (arc4random() % 256);
            double b = (arc4random() % 256);
            UIViewController * vc = [[UIViewController alloc] init];
            vc.view.backgroundColor = [UIColor colorWithRed:r/255 green:g/255 blue:b/255 alpha:1];
            [_contents addObject:vc];
        }
    }
    return _contents;
}

- (void)goToSearchPage{
    [self.navigationController pushViewController:[[SearchViewController alloc] init] animated:YES];
}

- (void)goToDownloadPage{
    [self.navigationController pushViewController:[[DownloadViewController alloc] init] animated:YES];
}

@end
