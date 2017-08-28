//
//  BaseViewController.h
//  QianbaoMerchantApp
//
//  Created by user on 15/8/11.
//  Copyright (c) 2015年 user. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseUI.h"
#import "MyToast.h"

typedef enum {
    NOLOAN,
    HAVEPAY,   // 已结请
    LOANING,
    REVIEWFAIL,
    LOANREVIEW,
    REVIEWSUCESS,
    MONEYFAIL,
    MONEYSUCESS,
    MONEYING,
    NOACTIVATION,
    HAVEPAYNOMIT=88,
    INFORIGHTNOMIT=89,
    NOIDCARD=90,
    NOBANKCARD=92,
    NOVERYINFO=100,
}LOANSTATUS;


@interface BaseViewController : UIViewController

@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *backBtn;

@property (nonatomic, strong) UIView *contenView;
@property (nonatomic, strong) UIButton *rightBtn;
@property (nonatomic, strong) UIButton *clickBtn;

@property (nonatomic,strong) UIView *nodataView;

- (void)backBtnPress; 
///
- (void)setTextFieldLeftPadding:(UITextField *)textField forWidth:(CGFloat)leftWidth;

+ (CGSize)getTextSize:(NSString *)str font:(float)font size:(CGSize)size;

- (void)showQuestions;

- (NSString *)getAppName;

-(NSString *)getQuestionImageStr;

- (UIButton *)getClick_y:(float)y enabled:(BOOL)enabled target:(nullable id)target action:(SEL)action title:(NSString *)title;



@end
