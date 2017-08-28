//
//  HtmlWebVC.h
//  CashLoan
//
//  Created by user on 16/9/8.
//  Copyright © 2016年 user. All rights reserved.
//

#import "BaseViewController.h"

@interface HtmlWebVC : BaseViewController

@property (nonatomic, strong) NSString *urlStr;
@property (nonatomic, strong) NSString *titleStr;
@property (nonatomic, strong) UIWebView *webView;

@property (nonatomic,assign) BOOL needRefresh;
@end
