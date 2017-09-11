//
//  HtmlWebVC.m
//  CashLoan
//
//  Created by user on 16/9/8.
//  Copyright © 2016年 user. All rights reserved.
//

#import "HtmlWebVC.h"
#import "UIColor+MyColor.h"
#import "SDRefresh.h"
#import "ActivityView.h"

@interface HtmlWebVC ()<UIWebViewDelegate>
{
    BOOL isRefreshing;
}


@property (nonatomic, strong) SDRefreshHeaderView *freshHeaderView;

@end

@implementation HtmlWebVC

-(void)dealloc
{
    //[_webView.scrollView removeObserver:_freshHeaderView forKeyPath:SDRefreshViewObservingkeyPath];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //更改到这里
//    [[ActivityView shareAcctivity] showActivity];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.titleLabel.text=_titleStr;
//    self.titleLabel.textColor=[UIColor blackColor];
//    self.titleView.backgroundColor=[UIColor whiteColor];
    //self.titleView.backgroundColor=UIColorFromRGB(0xffd200);
    
   // [[NSURLCache sharedURLCache] removeCachedResponseForRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_urlStr]]];
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    for (UIView *view in self.titleView.subviews) {
        if ([view isMemberOfClass:[UIButton class]]) {
            [view removeFromSuperview];
        }
    }
    self.view.backgroundColor = [UIColor myColorWithString:@"#f8f8f8"];
    
    UIWebView *webView=[[UIWebView alloc]initWithFrame:CGRectMake(0,64,SCREEN_WIDTH,SCREEN_HEIGHT-64)];
    webView.scalesPageToFit=YES;
    webView.backgroundColor= [UIColor myColorWithString:@"#f8f8f8"];
    webView.delegate=self;
    [self.view addSubview:webView];
    self.webView=webView;
    if (_urlStr!=nil) {
//        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_urlStr]]];
        //超时时间15s
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_urlStr]
                                 
                                                      cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                 
                                                  timeoutInterval:15];

        [webView loadRequest:request];

    }
//    self.titleView.backgroundColor=[UIColor whiteColor];
    
    self.titleView.backgroundColor=UIColorFromRGB(NAV_BAR_COLOR);
    
    if (![_titleStr isEqualToString:@"发现"]) {
//        UIButton *backBtn=[UIButton buttonWithType:UIButtonTypeCustom];
//        [backBtn setFrame:CGRectMake(8,20, 44,44)];
//        [backBtn setImage:[UIImage imageNamed:@"back_btn"] forState:UIControlStateNormal];
//        [backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        [backBtn addTarget:self action:@selector(backPress) forControlEvents:UIControlEventTouchUpInside];
//        [self.titleView addSubview:backBtn];
        
        UIButton *closeBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        [closeBtn setFrame:CGRectMake(SCREEN_WIDTH-44-10,20, 44,44)];
        [closeBtn setTitle:@"关闭" forState:UIControlStateNormal];
        if (self.needRefresh==YES) {
            [closeBtn setTitle:@"刷新" forState:UIControlStateNormal];
        }
        
        [closeBtn setTitleColor:UIColorFromRGB(0x000000) forState:UIControlStateNormal];
        BOOL isDark = [self isDarkColor:self.titleView.backgroundColor];
        if (isDark==YES) {
            [closeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        else
        {
            [closeBtn setTitleColor:UIColorFromRGB(0x000000) forState:UIControlStateNormal];
        }
        
        [closeBtn addTarget:self action:@selector(closeBtnPress) forControlEvents:UIControlEventTouchUpInside];
        [self.titleView addSubview:closeBtn];
    }
    else
    {
        [webView setFrame:CGRectMake(0,64,SCREEN_WIDTH,SCREEN_HEIGHT-64-49)];
    }
   
   // [self setHeaderView];
}

-(void)setHeaderView
{
    SDRefreshHeaderView *refreshHeader = [SDRefreshHeaderView refreshView];
    
    _freshHeaderView=refreshHeader;
    
    // 默认是在navigationController环境下，如果不是在此环境下，请设置 refreshHeader.isEffectedByNavigationController = NO;
    [refreshHeader addToScrollView:self.webView.scrollView];
    __block HtmlWebVC *weakSelf=self;
    refreshHeader.beginRefreshingOperation = ^{
        [weakSelf reloadWebData];
    };
    
}

-(void)reloadWebData
{
    isRefreshing=YES;
    [_webView reload];
}

-(void)endRefresh
{
    if (isRefreshing) {
        isRefreshing=NO;
        [_freshHeaderView endRefreshing];
    }
}


-(void)backBtnPress
{
    //当做还款计划
//    if (self.needRefresh==YES) {
//        [self.navigationController popViewControllerAnimated:YES];
//    }
//    else
//    {
        if ([_webView canGoBack]) {
            [_webView goBack];
        }
        else
        {
            [self.navigationController popViewControllerAnimated:YES];
        }

//    }
    
}

-(void)webViewDidStartLoad:(UIWebView *)webView
{
   // [self endRefresh];
    if (self.needRefresh==YES) {
        return;
    }
    [[ActivityView shareAcctivity] showActivity];
     self.nodataView.hidden = YES;
}
-(void)webViewDidFinishLoad:(UIWebView *)webView
{
   // [self endRefresh];
    [[ActivityView shareAcctivity] hiddeActivity];
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
   // [self endRefresh];
    [[ActivityView shareAcctivity] hiddeActivity];
    self.nodataView.hidden = NO;
}

-(void)closeBtnPress
{
     if (self.needRefresh==YES) {
         [self.webView reload];
     }
    else
    {
        [[ActivityView shareAcctivity] hiddeActivity];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

//重写父类的方法
-(BOOL)isDarkColor:(UIColor *)newColor{
    
    const CGFloat *componentColors = CGColorGetComponents(newColor.CGColor);
    CGFloat colorBrightness = ((componentColors[0] * 299) + (componentColors[1] * 587) + (componentColors[2] * 114)) / 1000;
    if (colorBrightness < 0.8){
        
        return YES;
    }
    else{
        return NO;
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
