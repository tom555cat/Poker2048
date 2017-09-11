//
//  BaseViewController.m
//  QianbaoMerchantApp
//
//  Created by user on 15/8/11.
//  Copyright (c) 2015年 user. All rights reserved.
//

#import "BaseViewController.h"
#import "ChangeTablebar.h"
#import "UIColor+MyColor.h"
#import "HtmlWebVC.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

-(void)dealloc
{
    if (_titleView!=nil) {
        [_titleView removeObserver:self forKeyPath:@"backgroundColor"];
    }
   
    [_nodataView removeObserver:self forKeyPath:@"hidden"];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _titleView=[[UIView alloc] initWithFrame:CGRectMake(0, 0,SCREEN_WIDTH,64)];
    [_titleView addObserver:self forKeyPath:@"backgroundColor" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    _titleLabel = [BaseUI newLabelWithFrame:CGRectMake(75,20,SCREEN_WIDTH-150,44) titleStr:nil andFont:[UIFont systemFontOfSize:18.0f] andColor:[UIColor whiteColor]];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [_titleView addSubview:_titleLabel];
    
    #ifdef NAV_BAR_COLOR_TWO
    {
        _titleView.backgroundColor = UIColorFromRGB(NAV_BAR_COLOR);
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = CGRectMake(0, 0, SCREEN_WIDTH,64);
        UIColor *color1 = UIColorFromRGB(NAV_BAR_COLOR);
        UIColor *color2 = UIColorFromRGB(NAV_BAR_COLOR_TWO);
        gradient.colors = [NSArray arrayWithObjects:
                           (id)color1.CGColor,
                           (id)color2.CGColor, nil];
        gradient.startPoint = CGPointMake(0, 0);
        gradient.endPoint = CGPointMake(1,0);
        [_titleView.layer insertSublayer:gradient atIndex:0];
    }
    #else
    {
        _titleView.backgroundColor = UIColorFromRGB(NAV_BAR_COLOR);
    }
    #endif
    
    
    [self.view addSubview:_titleView];
    
    //添加右边按钮，默认隐藏
    UIButton *rightBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    self.rightBtn = rightBtn;
    //默认隐藏
    self.rightBtn.hidden=YES;
    [rightBtn setFrame:CGRectMake(SCREEN_WIDTH-44-10,20, 44,44)];
    [rightBtn setTitle:@"关闭" forState:UIControlStateNormal];
    
    [rightBtn setTitleColor:UIColorFromRGB(0x000000) forState:UIControlStateNormal];
    BOOL isDark = [self isDarkColor:self.titleView.backgroundColor];
    if (isDark==YES) {
        [rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    else
    {
        [rightBtn setTitleColor:UIColorFromRGB(0x000000) forState:UIControlStateNormal];
    }
    
    [rightBtn addTarget:self action:@selector(rightBtnPress) forControlEvents:UIControlEventTouchUpInside];
    [self.titleView addSubview:rightBtn];
    
    self.view.backgroundColor = UIColorFromRGB(VIEW_BACK_COLOR);
    
    UIImage *bigImage  = [UIImage imageNamed:@"grapic"];
    float bigBtnWidth  = bigImage.size.width  * SCREEN_SCALE;
    float bigbtnHeight = bigImage.size.height * SCREEN_SCALE;
    
    self.clickBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_clickBtn setFrame:CGRectMake((SCREEN_WIDTH - bigBtnWidth) / 2, 0, bigBtnWidth, bigbtnHeight)];
    [_clickBtn setBackgroundImage:bigImage forState:UIControlStateDisabled];
    [_clickBtn setBackgroundImage:[UIImage imageNamed:@"redpic"] forState:UIControlStateNormal];
    _clickBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [_clickBtn setTintColor:[UIColor whiteColor]];
    
    
    [self addNoDataView];
    
    [_nodataView addObserver:self forKeyPath:@"hidden" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(nullable void *)context
{
    NSLog(@"observeValueForKeyPath");
    
    if ([keyPath isEqualToString:@"hidden"]) {
        for (UIView *subView in self.view.subviews) {
            if ([subView isKindOfClass:[UIWebView class]]) {
                [self.view bringSubviewToFront:_nodataView];
            }
        }
    }
    
    
    if ([keyPath isEqualToString:@"backgroundColor"]) {
        if ([self.navigationController.viewControllers count]>1&&[self.navigationController.viewControllers indexOfObject:self] > 0) {
            if (self.backBtn!=nil) {
                [_backBtn removeFromSuperview];
            }
            UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [backBtn setFrame:CGRectMake(8,20, 44,44)];
            if ([self isDarkColor:_titleView.backgroundColor]) {
                [backBtn setImage:[UIImage imageNamed:DARK_BACK_BTN_IMAGE] forState:UIControlStateNormal];
                _titleLabel.textColor=[UIColor whiteColor];
            }
            else
            {
                [backBtn setImage:[UIImage imageNamed:LIGHT_BACK_BTN_IMAGE] forState:UIControlStateNormal];
                _titleLabel.textColor=[UIColor blackColor];
            }
            
            [backBtn setImageEdgeInsets:UIEdgeInsetsMake(12, 11, 12, 11)];
            [backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [backBtn addTarget:self action:@selector(backBtnPress) forControlEvents:UIControlEventTouchUpInside];
            [_titleView addSubview:backBtn];
            self.backBtn = backBtn;
        }

    }
}

-(NSString *)getQuestionImageStr
{
    if ([self isDarkColor:_titleView.backgroundColor]) {
        return DARK_QUESTION_IMAGE;
    }
    else
    {
        return LIGHT_QUESTION_IMAGE;
    }
}


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

-(void)backBtnPress
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    
    
    if (self.navigationController!=nil&&[self.navigationController.viewControllers count]==2) {
        [ChangeTablebar hiddenTableBar];
    }
    else if(self.navigationController!=nil&&[self.navigationController.viewControllers count]==1)
    {
        [ChangeTablebar showTableBar];
    }
    if ([self isDarkColor:_titleView.backgroundColor]) {
        if ([UIApplication sharedApplication].statusBarStyle==UIStatusBarStyleDefault) {
            [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
        }
    }
    else
    {
        if ([UIApplication sharedApplication].statusBarStyle==UIStatusBarStyleLightContent) {
            [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
        }
    }
}

- (void)setTextFieldLeftPadding:(UITextField *)textField forWidth:(CGFloat)leftWidth
{
    CGRect frame = textField.frame;
    frame.size.width = leftWidth;
    UIView *leftview = [[UIView alloc] initWithFrame:frame];
    textField.leftViewMode = UITextFieldViewModeAlways;
    textField.leftView = leftview;
}

-(void)showQuestions
{
    HtmlWebVC *vc = [[HtmlWebVC alloc]init];
    vc.titleStr   = @"常见问题";
    vc.urlStr = @"http://www.baidu.com";
    [self.navigationController pushViewController:vc animated:YES];
}

- (NSString *)getAppName
{
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    return appName;
}

- (void)rightBtnPress
{
    NSLog(@"rightBtnPress");
}

- (UIButton *)getClick_y:(float)y enabled:(BOOL)enabled target:(nullable id)target action:(SEL)action title:(NSString *)title;
{
    [_clickBtn setFrame:CGRectMake((SCREEN_WIDTH - _clickBtn.frame.size.width) / 2, y - _clickBtn.frame.size.height / 2, _clickBtn.frame.size.width, _clickBtn.frame.size.height)];
    [_clickBtn setEnabled:enabled];
    [_clickBtn setTitle:title forState:UIControlStateNormal];
    [_clickBtn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return _clickBtn;
}

+ (CGSize)getTextSize:(NSString *)str font:(float)font size:(CGSize)size
{
    NSDictionary *attribute  = @{NSFontAttributeName:[UIFont systemFontOfSize:font]};
    CGRect frame             = [str boundingRectWithSize:size options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil];
    return frame.size;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addNoDataView
{
    _nodataView = [[UIView alloc] initWithFrame:CGRectMake(0, NAVBARH, SCREENWIDTH, SCREEN_HEIGHT-NAVBARH)];
    _nodataView.hidden = YES;
    
    [self.view addSubview:_nodataView];
    
    UILabel *infoLab = [[UILabel alloc] initWithFrame:CGRectMake(0, (SCREEN_HEIGHT-NAVBARH-TABBARH-20)/2, SCREENWIDTH, 20)];
    infoLab.text = @"暂无数据";
    infoLab.textAlignment = NSTextAlignmentCenter;
    [_nodataView addSubview:infoLab];
    infoLab.textColor = [UIColor lightGrayColor];
}

@end
