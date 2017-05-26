//
//  CardBackScrollViewController.m
//  Tlm2048_1
//
//  Created by tom555cat on 15/12/13.
//  Copyright © 2015年 tom555cat. All rights reserved.
//

#import "CardBackScrollViewController.h"
#import "CardBackScrollView.h"
#import "CardBackView.h"
#import "CardBackViewDisplay.h"
#import "PokerGameViewController.h"
#import "AppSpecificValues.h"
#import "WeixinActivity.h"

#define NUMBER_OF_VISIBLE_VIEWS 5
#define COLOR [UIColor colorWithRed:0/255.0 green:175/255.0 blue:240/255.0 alpha:1]

@interface CardBackScrollViewController () <CardBackScrollViewDelegate, CardBackScrollViewDataSource>
@property (nonatomic, strong) CardBackScrollView *scrollView;
@property (nonatomic, strong) CardBackViewDisplay *displayCardBackView;
@property (nonatomic, strong) UIImageView *lockImageView;
@property (nonatomic, strong) UILabel *achievementNameLabel;
@property (nonatomic) NSInteger tag;
@property (nonatomic, strong) UIButton *returnBtn;
@property (nonatomic) CGFloat viewSize;
@property (nonatomic, strong) UIButton *chooseBtn;
@property (nonatomic, strong) UIButton *shareBtn;
@property (nonatomic, strong) UIPopoverController *sharePopoverVC;

// 微信分享
@property (nonatomic, strong) NSArray *activity;

@end

@implementation CardBackScrollViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.activity = @[[[WeixinSessionActivity alloc] init], [[WeixinTimelineActivity alloc] init]];
}

///NSInteger CARDBACK_NUMBER = 5;
NSInteger CARDBACK_NUMBER = 25;

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.view.backgroundColor = [UIColor whiteColor];
    self.viewSize = CGRectGetWidth(self.view.bounds) / NUMBER_OF_VISIBLE_VIEWS;
    
    // 布局
    // 4/5部分用来战士卡牌 (9/16H高，)
    // .. 19/160H ----> padding
    // ..  8/16H  ----> 卡背
    // .. 19/160H * 1/5 -----> padding
    // .. 19/160H * 2.5/5 -----> 选择卡背按钮
    // .. 19/160H * 1/5 -----> padding
    // .. 19/160H * 0.5/5 -----> 一条灰色透明装饰
    // 1/5部分用来滚动视图
    
    // 展示视图部分
    CGSize winSize = self.view.bounds.size;
    CGFloat currentTop = winSize.height*19.0f/160.0f;
    
    // 返回按钮
    CGFloat returnBtnWidth =  winSize.width / 13.0f;
    CGFloat returnBtnHeight = returnBtnWidth; //returnBtnWidth * 127.0f / 98.0f;
    CGFloat padding = returnBtnHeight;
    self.returnBtn = [[UIButton alloc] initWithFrame:CGRectMake(padding*2.0f/3.0f, padding, returnBtnWidth, returnBtnHeight)];
    [self.returnBtn setBackgroundImage:[UIImage imageNamed:@"arrow"] forState:UIControlStateNormal];
    [self.returnBtn addTarget:self action:@selector(returnToMain:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.returnBtn];
    
    // 达成成就数量标签
    CGFloat reachedAchivementLabelWidth = winSize.width / 6.0f;
    CGFloat reachedAchivementLabelHeight = reachedAchivementLabelWidth;
    CGFloat labelPadding = padding*2.0f/3.0f;
    CGFloat fontSize = winSize.height*18.0f/667.0f;
    UIButton *reachedAchivementLabel = [[UIButton alloc] initWithFrame:CGRectMake(winSize.width-labelPadding-reachedAchivementLabelWidth, padding+returnBtnHeight/2.0f-reachedAchivementLabelHeight/2.0f, reachedAchivementLabelWidth, reachedAchivementLabelHeight)];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld/%ld", (long)[self accomplishedAchievementNum], (long)CARDBACK_NUMBER] attributes:@{NSForegroundColorAttributeName:[UIColor grayColor],NSFontAttributeName:[UIFont fontWithName:@"Verdana-Bold" size:fontSize],
        NSParagraphStyleAttributeName:paragraphStyle}];
    [reachedAchivementLabel setAttributedTitle:attributeString forState:UIControlStateNormal];
    [self.view addSubview:reachedAchivementLabel];
    

    // 小锁和名字占用了  1.8/16.0f的高度
    CGFloat achievementTop = winSize.height * 0.07f;
    // ......小锁 0.7/16
    CGFloat lockImageWidth = CGRectGetHeight(self.view.bounds)*0.7f/16.0f;
    CGFloat lockImageHeight = lockImageWidth;
    UIImageView *lockImageView = [[UIImageView alloc] initWithFrame:CGRectMake(winSize.width/2.0f-lockImageWidth/2.0f, achievementTop, lockImageWidth, lockImageHeight)];
    lockImageView.image = [UIImage imageNamed:@"lock"];
    [self.view addSubview:lockImageView];
    self.lockImageView = lockImageView;
    achievementTop += lockImageHeight + CGRectGetHeight(self.view.bounds)*0.1f/16.0f;
    
    // ......卡牌名字
    CGFloat cardNameWidth = winSize.width;
    CGFloat cardNameHeight = CGRectGetHeight(self.view.bounds)*0.7f/16.0f;
    UILabel *cardNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(winSize.width/2.0f-cardNameWidth/2.0f, achievementTop, cardNameWidth, cardNameHeight)];
    [self.view addSubview:cardNameLabel];
    self.achievementNameLabel = cardNameLabel;
     
    // 卡背展示部分
    currentTop += CGRectGetHeight(self.view.bounds)*1.0f/16.0f;
    CGFloat displayCardBackHeight = CGRectGetHeight(self.view.bounds)*8.0f/16.0f;
    CGFloat displayCardBackWidth = displayCardBackHeight*0.6;
    self.displayCardBackView = [CardBackViewDisplay cardBackPosition:CGPointMake(CGRectGetWidth(self.view.bounds)/2.0f-displayCardBackWidth/2.0f, currentTop) sideWidth:displayCardBackWidth sideHeight:displayCardBackHeight cornerRadius:3.0];
    //self.displayCardBackView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:self.displayCardBackView];
    currentTop += displayCardBackHeight + winSize.height*0.2f*19.0f/160.0f;
    
    // 选择当前卡牌按钮
    CGFloat btnHeight = winSize.height*0.5f*19.0f/160.0f;
    CGFloat btnWidth = btnHeight*426.0f/141.0f;
    UIButton *chooseBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.5f*CGRectGetWidth(self.view.bounds)-0.5f*btnWidth, currentTop, btnWidth, btnHeight)];
    [chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button"] forState:UIControlStateNormal];
    [chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button-pressed"] forState:UIControlStateHighlighted];
    [chooseBtn addTarget:self action:@selector(chooseCurrentCard:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:chooseBtn];
    self.chooseBtn = chooseBtn;
    NSLog(@"chooseBtn width: %f, height: %f", chooseBtn.frame.size.width, chooseBtn.frame.size.height);
    currentTop += btnHeight + winSize.height*0.2f*19.0f/160.0f;
    
    // 共享按钮
    CGFloat shareBtnWidth = btnHeight*0.8f;   // 高度是选择卡背按钮高度的0.9
    CGFloat shareBtnHeight = shareBtnWidth;
    CGFloat shareBtnPadding = btnWidth / 12.0f;
    UIButton *shareBtn = [[UIButton alloc] initWithFrame:CGRectMake(chooseBtn.frame.origin.x+btnWidth+shareBtnPadding, chooseBtn.frame.origin.y+btnHeight/2.0f-shareBtnHeight/2.0f, shareBtnWidth, shareBtnHeight)];
    [shareBtn setBackgroundImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
    [shareBtn addTarget:self action:@selector(shareContent) forControlEvents:UIControlEventTouchUpInside];
    NSLog(@"share btn width:%f, height: %f", shareBtn.frame.size.width, shareBtn.frame.size.height);
    [self.view addSubview:shareBtn];
    self.shareBtn = shareBtn;
    
    // 添加一条透明的装饰条
    CGFloat decorateHeight = 5.0f;
    UIView *decorate = [[UIView alloc] initWithFrame:CGRectMake(0, winSize.height-CGRectGetHeight(self.view.bounds)/5.0f-decorateHeight, winSize.width, decorateHeight)];
    decorate.backgroundColor = [UIColor colorWithRed:0.3f green:0.3f blue:0.3f alpha:0.5f];
    [self.view addSubview:decorate];
    
    // 滚动视图部分
    self.scrollView = [[CardBackScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds)*4.0f/5.0f, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)/5.0f)];
    
    [self.view addSubview:self.scrollView];
    self.scrollView.delegate = self;
    self.scrollView.dataSource = self;
    self.scrollView.pagingEnabled = NO;
    self.scrollView.backgroundColor = [UIColor grayColor];
    
    // 重新加载滚动视图
    [self.scrollView reloadData];
}

- (void)returnToMain:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)chooseCurrentCard:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(changeBackgroundWithTag:)]) {
        [self.delegate changeBackgroundWithTag:self.tag];
    }
}

- (void)purchaseCardBack:(id)sender
{
    NSLog(@"Purchse the Card Back!!!");
    NSString *backgoundImageStr = [NSString stringWithFormat:@"%ld", (long)self.tag];
    NSLog(@"Buy the card back, %@", backgoundImageStr);
}

# pragma mark - LTInfiniteScrollView dataSource
- (NSInteger)numberOfViews
{
    // 当每页显示5张成就卡背时，还需要额外4张空白卡背来弥补滚动到最左或最右边的空白
    //return 9;
    return 29;
}

- (NSInteger)numberOfVisibleViews
{
    return NUMBER_OF_VISIBLE_VIEWS;
}

// 卡牌宽高比为3:5
- (UIView *)viewAtIndex:(NSInteger)index reusingView:(UIView *)view;
{
    if (view) {
        ((CardBackView*)view).imageNameStr = [NSString stringWithFormat:@"%ld", (long)index];
        return view;
    }
    
    CardBackView *aView = [CardBackView cardBackPosition:CGPointMake(0, 0) sideWidth:self.viewSize*0.7f sideHeight:self.viewSize*0.7f*((CGFloat)self.displayCardBackView.frame.size.height/(CGFloat)self.displayCardBackView.frame.size.width) cornerRadius:2.0];
    return aView;
}

# pragma mark - LTInfiniteScrollView delegate
- (void)updateView:(UIView *)view withDistanceToCenter:(CGFloat)distance scrollDirection:(ScrollDirection)direction
{
    // you can appy animations duration scrolling here
    CGFloat percent;
    percent = distance / CGRectGetWidth(self.view.bounds) * NUMBER_OF_VISIBLE_VIEWS;
    
    CATransform3D transform = CATransform3DIdentity;
    
    // scale
    CGPoint center = view.center;
    view.center = center;
    //size = size * (1.4 - 0.3 * (fabs(percent)));
    //view.frame = CGRectMake(0, 0, size, size);
    //view.layer.cornerRadius = size / 2;
    view.center = center;
    
    // translate
    CGFloat translate = self.viewSize / 3 * percent;
    if (percent > 1) {
        translate = self.viewSize / 3;
    } else if (percent < -1) {
        translate = -self.viewSize / 3;
    }
    transform = CATransform3DTranslate(transform,translate, 0, 0);
    
    // rotate
    CardBackView *cardBackView = (CardBackView*) view;
    if (fabs(percent) < 1) {
        CGFloat angle = 0;
        if( percent > 0) {
            angle = - M_PI * (1-fabs(percent));
        } else {
            angle =  M_PI * (1-fabs(percent));
        }
        transform.m34 = 1.0/-600;
        if (fabs(percent) <= 0.5) {
            //angle =  M_PI * percent;
            //UILabel *label = (UILabel*) view;
            cardBackView.imageNameStr = [NSString stringWithFormat:@"%d",(int)view.tag];
            //cardBackView.backgroundColor = COLOR;
        } else {
            //UILabel *label = (UILabel*) view;
            cardBackView.imageNameStr = [NSString stringWithFormat:@"%d",(int)view.tag];
            //cardBackView.backgroundColor = COLOR;
        }
        //transform = CATransform3DRotate(transform, angle , 0.0f, 1.0f, 0.0f);
    } else {
        //UILabel *label = (UILabel *)view;
        cardBackView.imageNameStr = [NSString stringWithFormat:@"%d",(int)view.tag];
        [self setLockAndAchievementName:self.tag];
        //cardBackView.backgroundColor = COLOR;
    }
    
    //view.layer.transform = transform;
    
    if (ABS(distance) < self.viewSize / 2.0f) {
        // 如果是最左边的-12，而且往右拉
        if (view.tag <= -12 && direction == ScrollDirectionRight) {
            self.displayCardBackView.imageNameStr = [NSString stringWithFormat:@"%d",-12];
            self.tag = -12;
        } else if (view.tag >= 12 && direction == ScrollDirectionLeft) {
            self.displayCardBackView.imageNameStr = [NSString stringWithFormat:@"%d",12];
            self.tag = 12;
        } else {
            self.displayCardBackView.imageNameStr = [NSString stringWithFormat:@"%d",(int)view.tag];
            self.tag = (int)view.tag;
        }
    }
}

# pragma mark - config views
- (void)configureForegroundOfLabel:(UILabel *)label
{
    NSString *text = [NSString stringWithFormat:@"%d",(int)label.tag];
    if ([label.text isEqualToString:text]) {
        return;
    }
    label.text = text;
    //label.backgroundColor = COLOR;
}

- (void)configureBackgroundOfLabel:(UILabel *)label
{
    NSString* text = @"back";
    if ([label.text isEqualToString:text]) {
        return;
    }
    label.text = text;
    label.backgroundColor = [UIColor blackColor];
}

- (void)shareContent
{
    NSString *description = [NSString stringWithFormat:@"I got the achievement: ⌈%@⌋ in Poker2048!", self.achievementNameLabel.text];
    NSURL *appURL = [NSURL URLWithString:@"https://appsto.re/cn/GcrJab.i"];
    NSArray *activityItems = [[NSArray alloc] initWithObjects:
                              description,
                              appURL,
                              [self getViewImage],nil];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:self.activity];
    
    // 写一个bolck，用于completionHandler的初始化
    __weak UIActivityViewController *weakActivityVC = activityVC;
    if ([activityVC respondsToSelector:@selector(completionWithItemsHandler)]) {
        activityVC.completionWithItemsHandler = ^(NSString *activityType, BOOL completed,
                                                  NSArray *returnedItems, NSError *activityError){
            NSLog(@"%@", activityType);
            if (completed) {
                NSLog(@"completed");
            } else
            {
                NSLog(@"cancled");
            }
            
            [weakActivityVC dismissViewControllerAnimated:YES completion:Nil];
        };
    }
    
    // 适配ipad
    if ([activityVC respondsToSelector:@selector(popoverPresentationController)]) {
        activityVC.popoverPresentationController.sourceView = self.view;
    }
    [self presentViewController:activityVC animated:YES completion:nil];

}


// 获取当前屏幕的截图
- (UIImage *)getViewImage
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.view.frame.size.width, self.view.frame.size.height), NO, 1.0);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


- (void)setLockAndAchievementName:(NSInteger)tag
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    // 按钮上的字体
    CGFloat btnFontSize = self.view.bounds.size.height*(20.0f/667.0f);
    NSMutableAttributedString *btnAttributeString = [[NSMutableAttributedString alloc]
                                                     initWithString:@"$0.99"
                                                     attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],
                                                                  NSFontAttributeName:[UIFont fontWithName:@"Verdana-Bold" size:btnFontSize],
                                                                  NSParagraphStyleAttributeName:paragraphStyle}
                                                     ];
    
    // 667屏幕高度对应着15大小的字体
    CGFloat fontSize = self.view.bounds.size.height*(15.0f/667.0f);
    
    switch (self.tag) {
        case -12:
        {
            self.lockImageView.image = nil;
            NSString *labelText = @"tom555cat";
            btnAttributeString = nil;
            NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:labelText];
            [attributeString addAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor],
                                             NSFontAttributeName:[UIFont fontWithName:@"Verdana-Bold" size:fontSize],
                                             NSParagraphStyleAttributeName:paragraphStyle}
                                     range:NSMakeRange(0, [labelText length])];
            self.achievementNameLabel.attributedText = attributeString;
            [self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button"] forState:UIControlStateNormal];
            [self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button-pressed"] forState:UIControlStateHighlighted];
            [self.chooseBtn setEnabled:YES];
            [self.chooseBtn setAttributedTitle:btnAttributeString forState:UIControlStateNormal];
            [self.chooseBtn addTarget:self action:@selector(chooseCurrentCard:) forControlEvents:UIControlEventTouchUpInside];
            [self.shareBtn setHidden:NO];
            break;
        }
            
        case -11:
        {
            //NSInteger gameWinTimes = [defaults integerForKey:kGameWinTimes];
            NSInteger isWinOnce = [defaults integerForKey:kGameWinOnce];
            NSString *labelText = @"Win Once";
            btnAttributeString = nil;
            NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:labelText];
            [attributeString addAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor],
                                             NSFontAttributeName:[UIFont fontWithName:@"Verdana-Bold" size:fontSize],
                                             NSParagraphStyleAttributeName:paragraphStyle}
                                     range:NSMakeRange(0, [labelText length])];
            self.achievementNameLabel.attributedText = attributeString;
            [self.chooseBtn setAttributedTitle:btnAttributeString forState:UIControlStateNormal];
            if (isWinOnce == 1) {
                self.lockImageView.image = nil;
                [self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button"] forState:UIControlStateNormal];
                [self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button-pressed"] forState:UIControlStateHighlighted];
                [self.chooseBtn setEnabled:YES];
                [self.chooseBtn addTarget:self action:@selector(chooseCurrentCard:) forControlEvents:UIControlEventTouchUpInside];
                [self.shareBtn setHidden:NO];
            } else {
                //self.lockImageView.image = [UIImage imageNamed:@"lock"];
                [self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button-lock"] forState:UIControlStateNormal];
                [self.chooseBtn setEnabled:NO];
                [self.shareBtn setHidden:YES];
            }
            break;
        }
            
        case -10:
        {
            //NSInteger gameWinTimes = [defaults integerForKey:kGameWinTimes];
            NSInteger isWin100 = [defaults integerForKey:kGameWin100];
            NSString *labelText = @"Win 100 Times";
            btnAttributeString = nil;
            NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:labelText];
            [attributeString addAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor],
                                             NSFontAttributeName:[UIFont fontWithName:@"Verdana-Bold" size:fontSize],
                                             NSParagraphStyleAttributeName:paragraphStyle}
                                     range:NSMakeRange(0, [labelText length])];
            self.achievementNameLabel.attributedText = attributeString;
            [self.chooseBtn setAttributedTitle:btnAttributeString forState:UIControlStateNormal];
            if (isWin100 == 1) {
                self.lockImageView.image = nil;
                [self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button"] forState:UIControlStateNormal];
                [self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button-pressed"] forState:UIControlStateHighlighted];
                [self.chooseBtn setEnabled:YES];
                [self.chooseBtn addTarget:self action:@selector(chooseCurrentCard:) forControlEvents:UIControlEventTouchUpInside];
                [self.shareBtn setHidden:NO];
            } else {
                //self.lockImageView.image = [UIImage imageNamed:@"lock"];
                [self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button-lock"] forState:UIControlStateNormal];
                [self.chooseBtn setEnabled:NO];
                [self.shareBtn setHidden:YES];
            }
            break;
        }
            
        case -9:
        {
            //NSInteger gameWinTimes = [defaults integerForKey:kGameWinTimes];
            NSInteger isWin500 = [defaults integerForKey:kGameWin500];
            NSString *labelText = @"Win 500 Times";
            btnAttributeString = nil;
            NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:labelText];
            [attributeString addAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor],
                                             NSFontAttributeName:[UIFont fontWithName:@"Verdana-Bold" size:fontSize],
                                             NSParagraphStyleAttributeName:paragraphStyle}
                                     range:NSMakeRange(0, [labelText length])];
            self.achievementNameLabel.attributedText = attributeString;
            [self.chooseBtn setAttributedTitle:btnAttributeString forState:UIControlStateNormal];
            if (isWin500 == 500) {
                self.lockImageView.image = nil;
                [self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button"] forState:UIControlStateNormal];
                [self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button-pressed"] forState:UIControlStateHighlighted];
                [self.chooseBtn setEnabled:YES];
                [self.chooseBtn addTarget:self action:@selector(chooseCurrentCard:) forControlEvents:UIControlEventTouchUpInside];
                [self.shareBtn setHidden:NO];
            } else {
                //self.lockImageView.image = [UIImage imageNamed:@"lock"];
                [self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button-lock"] forState:UIControlStateNormal];
                [self.chooseBtn setEnabled:NO];
                [self.shareBtn setHidden:YES];
            }
            break;
        }
            
        case -8:
        {
            NSInteger scoreMoreThan40 = [defaults integerForKey:kScoreMoreThan40];
            NSString *labelText = @"Score Over 40";
            btnAttributeString = nil;
            NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:labelText];
            [attributeString addAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor],
                                             NSFontAttributeName:[UIFont fontWithName:@"Verdana-Bold" size:fontSize],
                                             NSParagraphStyleAttributeName:paragraphStyle}
                                     range:NSMakeRange(0, [labelText length])];
            self.achievementNameLabel.attributedText = attributeString;
            [self.chooseBtn setAttributedTitle:btnAttributeString forState:UIControlStateNormal];
            if (scoreMoreThan40 == 1) {
                self.lockImageView.image = nil;
                [self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button"] forState:UIControlStateNormal];
                [self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button-pressed"] forState:UIControlStateHighlighted];
                [self.chooseBtn setEnabled:YES];
                [self.chooseBtn addTarget:self action:@selector(chooseCurrentCard:) forControlEvents:UIControlEventTouchUpInside];
                [self.shareBtn setHidden:NO];
            } else {
                //self.lockImageView.image = [UIImage imageNamed:@"lock"];
                [self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button-lock"] forState:UIControlStateNormal];
                [self.chooseBtn setEnabled:NO];
                [self.shareBtn setHidden:YES];
            }
            break;
        }
            
        case -7:
        {
            NSInteger scoreMoreThan50 = [defaults integerForKey:kScoreMoreThan50];
            NSString *labelText = @"Score Over 50";
            btnAttributeString = nil;
            NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:labelText];
            [attributeString addAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor],
                                             NSFontAttributeName:[UIFont fontWithName:@"Verdana-Bold" size:fontSize],
                                             NSParagraphStyleAttributeName:paragraphStyle}
                                     range:NSMakeRange(0, [labelText length])];
            self.achievementNameLabel.attributedText = attributeString;
            [self.chooseBtn setAttributedTitle:btnAttributeString forState:UIControlStateNormal];
            if (scoreMoreThan50 == 1) {
                self.lockImageView.image = nil;
                [self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button"] forState:UIControlStateNormal];
                [self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button-pressed"] forState:UIControlStateHighlighted];
                [self.chooseBtn setEnabled:YES];
                [self.chooseBtn addTarget:self action:@selector(chooseCurrentCard:) forControlEvents:UIControlEventTouchUpInside];
                [self.shareBtn setHidden:NO];
            } else {
                //self.lockImageView.image = [UIImage imageNamed:@"lock"];
                [self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button-lock"] forState:UIControlStateNormal];
                [self.chooseBtn setEnabled:NO];
                [self.shareBtn setHidden:YES];
            }
            break;
        }
            
        case -6:
        {
            NSInteger scoreMoreThan60 = [defaults integerForKey:kScoreMoreThan60];
            NSString *labelText = @"Score Over 60";
            btnAttributeString = nil;
            NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:labelText];
            [attributeString addAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor],
                                             NSFontAttributeName:[UIFont fontWithName:@"Verdana-Bold" size:fontSize],
                                             NSParagraphStyleAttributeName:paragraphStyle}
                                     range:NSMakeRange(0, [labelText length])];
            self.achievementNameLabel.attributedText = attributeString;
            [self.chooseBtn setAttributedTitle:btnAttributeString forState:UIControlStateNormal];
            if (scoreMoreThan60 == 1) {
                self.lockImageView.image = nil;
                [self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button"] forState:UIControlStateNormal];
                [self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button-pressed"] forState:UIControlStateHighlighted];
                [self.chooseBtn setEnabled:YES];
                [self.chooseBtn addTarget:self action:@selector(chooseCurrentCard:) forControlEvents:UIControlEventTouchUpInside];
                [self.shareBtn setHidden:NO];
            } else {
                //self.lockImageView.image = [UIImage imageNamed:@"lock"];
                [self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button-lock"] forState:UIControlStateNormal];
                [self.chooseBtn setEnabled:NO];
                [self.shareBtn setHidden:YES];
            }
            break;
        }
            
        case -5:
        {
            NSInteger isLeftCardLessThan4 = [defaults integerForKey:kIsLeftCardsNumLessThan4];
            NSString *labelText = @"Left Cards less than 4";
            btnAttributeString = nil;
            NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:labelText];
            [attributeString addAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor],
                                             NSFontAttributeName:[UIFont fontWithName:@"Verdana-Bold" size:fontSize],
                                             NSParagraphStyleAttributeName:paragraphStyle}
                                     range:NSMakeRange(0, [labelText length])];
            self.achievementNameLabel.attributedText = attributeString;
            [self.chooseBtn setAttributedTitle:btnAttributeString forState:UIControlStateNormal];
            if (isLeftCardLessThan4 == 1) {
                self.lockImageView.image = nil;
                [self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button"] forState:UIControlStateNormal];
                [self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button-pressed"] forState:UIControlStateHighlighted];
                [self.chooseBtn setEnabled:YES];
                [self.chooseBtn addTarget:self action:@selector(chooseCurrentCard:) forControlEvents:UIControlEventTouchUpInside];
                [self.shareBtn setHidden:NO];
            } else {
                //self.lockImageView.image = [UIImage imageNamed:@"lock"];
                [self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button-lock"] forState:UIControlStateNormal];
                [self.chooseBtn setEnabled:NO];
                [self.shareBtn setHidden:YES];
            }
            break;
        }
            
        case -4:
        {
            NSInteger isLeftCardEqualTo0 = [defaults integerForKey:kIsLeftCardsNumEqualTo0];
            NSString *labelText = @"No Cards Left";
            btnAttributeString = nil;
            NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:labelText];
            [attributeString addAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor],
                                             NSFontAttributeName:[UIFont fontWithName:@"Verdana-Bold" size:fontSize],
                                             NSParagraphStyleAttributeName:paragraphStyle}
                                     range:NSMakeRange(0, [labelText length])];
            self.achievementNameLabel.attributedText = attributeString;
            [self.chooseBtn setAttributedTitle:btnAttributeString forState:UIControlStateNormal];
            if (isLeftCardEqualTo0 == 1) {
                self.lockImageView.image = nil;
                [self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button"] forState:UIControlStateNormal];
                [self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button-pressed"] forState:UIControlStateHighlighted];
                [self.chooseBtn setEnabled:YES];
                [self.chooseBtn addTarget:self action:@selector(chooseCurrentCard:) forControlEvents:UIControlEventTouchUpInside];
                [self.shareBtn setHidden:NO];
            } else {
                //self.lockImageView.image = [UIImage imageNamed:@"lock"];
                [self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button-lock"] forState:UIControlStateNormal];
                [self.chooseBtn setEnabled:NO];
                [self.shareBtn setHidden:YES];
            }
            break;
        }
            
        case -3:
        {
            NSInteger is50MoveStep = [defaults integerForKey:kIsMoveNumberEqualTo52];
            NSString *labelText = @"52 Move Steps";
            btnAttributeString = nil;
            NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:labelText];
            [attributeString addAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor],
                                             NSFontAttributeName:[UIFont fontWithName:@"Verdana-Bold" size:fontSize],
                                             NSParagraphStyleAttributeName:paragraphStyle}
                                     range:NSMakeRange(0, [labelText length])];
            self.achievementNameLabel.attributedText = attributeString;
            [self.chooseBtn setAttributedTitle:btnAttributeString forState:UIControlStateNormal];
            if (is50MoveStep == 1) {
                self.lockImageView.image = nil;
                [self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button"] forState:UIControlStateNormal];
                [self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button-pressed"] forState:UIControlStateHighlighted];
                [self.chooseBtn setEnabled:YES];
                [self.chooseBtn addTarget:self action:@selector(chooseCurrentCard:) forControlEvents:UIControlEventTouchUpInside];
                [self.shareBtn setHidden:NO];
            } else {
                //self.lockImageView.image = [UIImage imageNamed:@"lock"];
                [self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button-lock"] forState:UIControlStateNormal];
                [self.chooseBtn setEnabled:NO];
                [self.shareBtn setHidden:YES];
            }
            break;
        }
            
        case -2:
        {
            NSInteger isErase4Flush = [defaults integerForKey:kIsGotFlush];
            NSString *labelText = @"4 Flush";
            btnAttributeString = nil;
            NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:labelText];
            [attributeString addAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor],
                                             NSFontAttributeName:[UIFont fontWithName:@"Verdana-Bold" size:fontSize],
                                             NSParagraphStyleAttributeName:paragraphStyle}
                                     range:NSMakeRange(0, [labelText length])];
            self.achievementNameLabel.attributedText = attributeString;
            [self.chooseBtn setAttributedTitle:btnAttributeString forState:UIControlStateNormal];
            if (isErase4Flush == 1) {
                self.lockImageView.image = nil;
                [self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button"] forState:UIControlStateNormal];
                [self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button-pressed"] forState:UIControlStateHighlighted];
                [self.chooseBtn setEnabled:YES];
                [self.chooseBtn addTarget:self action:@selector(chooseCurrentCard:) forControlEvents:UIControlEventTouchUpInside];
                [self.shareBtn setHidden:NO];
            } else {
                //self.lockImageView.image = [UIImage imageNamed:@"lock"];
                [self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button-lock"] forState:UIControlStateNormal];
                [self.chooseBtn setEnabled:NO];
                [self.shareBtn setHidden:YES];
            }
            break;
        }
            
        case -1:
        {
            NSInteger isErase4Straight = [defaults integerForKey:kIsGotStraight];
            NSString *labelText = @"4 Straight";
            btnAttributeString = nil;
            NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:labelText];
            [attributeString addAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor],
                                             NSFontAttributeName:[UIFont fontWithName:@"Verdana-Bold" size:fontSize],
                                             NSParagraphStyleAttributeName:paragraphStyle}
                                     range:NSMakeRange(0, [labelText length])];
            self.achievementNameLabel.attributedText = attributeString;
            [self.chooseBtn setAttributedTitle:btnAttributeString forState:UIControlStateNormal];
            if (isErase4Straight == 1) {
                self.lockImageView.image = nil;
                [self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button"] forState:UIControlStateNormal];
                [self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button-pressed"] forState:UIControlStateHighlighted];
                [self.chooseBtn setEnabled:YES];
                [self.chooseBtn addTarget:self action:@selector(chooseCurrentCard:) forControlEvents:UIControlEventTouchUpInside];
                [self.shareBtn setHidden:NO];
            } else {
                //self.lockImageView.image = [UIImage imageNamed:@"lock"];
                [self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button-lock"] forState:UIControlStateNormal];
                [self.chooseBtn setEnabled:NO];
                [self.shareBtn setHidden:YES];
            }
            break;
        }
            
        case 0:
        {
            NSInteger isErase4SameKind = [defaults integerForKey:kIsGotSameKind];
            NSString *labelText = @"4 Same Kind";
            btnAttributeString = nil;
            NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:labelText];
            [attributeString addAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor],
                                             NSFontAttributeName:[UIFont fontWithName:@"Verdana-Bold" size:fontSize],
                                             NSParagraphStyleAttributeName:paragraphStyle}
                                     range:NSMakeRange(0, [labelText length])];
            self.achievementNameLabel.attributedText = attributeString;
            [self.chooseBtn setAttributedTitle:btnAttributeString forState:UIControlStateNormal];
            if (isErase4SameKind == 1) {
                self.lockImageView.image = nil;
                [self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button"] forState:UIControlStateNormal];
                [self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button-pressed"] forState:UIControlStateHighlighted];
                [self.chooseBtn setEnabled:YES];
                [self.chooseBtn addTarget:self action:@selector(chooseCurrentCard:) forControlEvents:UIControlEventTouchUpInside];
                [self.shareBtn setHidden:NO];
            } else {
                //self.lockImageView.image = [UIImage imageNamed:@"lock"];
                [self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button-lock"] forState:UIControlStateNormal];
                [self.chooseBtn setEnabled:NO];
                [self.shareBtn setHidden:YES];
            }
            break;
        }
            
        case 1:
        {
            NSInteger isClubKiller = [defaults integerForKey:kIsClubKiller];
            NSString *labelText = @"Erase All Club";
            btnAttributeString = nil;
            NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:labelText];
            [attributeString addAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor],
                                             NSFontAttributeName:[UIFont fontWithName:@"Verdana-Bold" size:fontSize],
                                             NSParagraphStyleAttributeName:paragraphStyle}
                                     range:NSMakeRange(0, [labelText length])];
            self.achievementNameLabel.attributedText = attributeString;
            [self.chooseBtn setAttributedTitle:btnAttributeString forState:UIControlStateNormal];
            if (isClubKiller == 1) {
                self.lockImageView.image = nil;
                [self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button"] forState:UIControlStateNormal];
                [self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button-pressed"] forState:UIControlStateHighlighted];
                [self.chooseBtn setEnabled:YES];
                [self.chooseBtn addTarget:self action:@selector(chooseCurrentCard:) forControlEvents:UIControlEventTouchUpInside];
                [self.shareBtn setHidden:NO];
            } else {
                //self.lockImageView.image = [UIImage imageNamed:@"lock"];
                [self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button-lock"] forState:UIControlStateNormal];
                [self.chooseBtn setEnabled:NO];
                [self.shareBtn setHidden:YES];
            }
            break;
        }
            
        case 2:
        {
            NSInteger isHeartKiller = [defaults integerForKey:kIsHeartKiller];
            NSString *labelText = @"Erase All Heart";
            btnAttributeString = nil;
            NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:labelText];
            [attributeString addAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor],
                                             NSFontAttributeName:[UIFont fontWithName:@"Verdana-Bold" size:fontSize],
                                             NSParagraphStyleAttributeName:paragraphStyle}
                                     range:NSMakeRange(0, [labelText length])];
            self.achievementNameLabel.attributedText = attributeString;
            [self.chooseBtn setAttributedTitle:btnAttributeString forState:UIControlStateNormal];
            if (isHeartKiller == 1) {
                self.lockImageView.image = nil;
                [self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button"] forState:UIControlStateNormal];
                [self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button-pressed"] forState:UIControlStateHighlighted];
                [self.chooseBtn setEnabled:YES];
                [self.chooseBtn addTarget:self action:@selector(chooseCurrentCard:) forControlEvents:UIControlEventTouchUpInside];
                [self.shareBtn setHidden:NO];
            } else {
                //self.lockImageView.image = [UIImage imageNamed:@"lock"];
                [self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button-lock"] forState:UIControlStateNormal];
                [self.chooseBtn setEnabled:NO];
                [self.shareBtn setHidden:YES];
            }
            break;
        }
            
        case 3:
        {
            NSInteger isSpadeKiller = [defaults integerForKey:kIsSpadeKiller];
            NSString *labelText = @"Erase All Spade";
            btnAttributeString = nil;
            NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:labelText];
            [attributeString addAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor],
                                             NSFontAttributeName:[UIFont fontWithName:@"Verdana-Bold" size:fontSize],
                                             NSParagraphStyleAttributeName:paragraphStyle}
                                     range:NSMakeRange(0, [labelText length])];
            self.achievementNameLabel.attributedText = attributeString;
            [self.chooseBtn setAttributedTitle:btnAttributeString forState:UIControlStateNormal];
            if (isSpadeKiller == 1) {
                self.lockImageView.image = nil;
                [self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button"] forState:UIControlStateNormal];
                [self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button-pressed"] forState:UIControlStateHighlighted];
                [self.chooseBtn setEnabled:YES];
                [self.chooseBtn addTarget:self action:@selector(chooseCurrentCard:) forControlEvents:UIControlEventTouchUpInside];
                [self.shareBtn setHidden:NO];
            } else {
                //self.lockImageView.image = [UIImage imageNamed:@"lock"];
                [self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button-lock"] forState:UIControlStateNormal];
                [self.chooseBtn setEnabled:NO];
                [self.shareBtn setHidden:YES];
            }
            break;
        }
            
        case 4:
        {
            NSInteger isDiamondKiller = [defaults integerForKey:kIsDiamondKiller];
            NSString *labelText = @"Erase All Diamond";
            btnAttributeString = nil;
            NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:labelText];
            [attributeString addAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor],
                                             NSFontAttributeName:[UIFont fontWithName:@"Verdana-Bold" size:fontSize],
                                             NSParagraphStyleAttributeName:paragraphStyle}
                                     range:NSMakeRange(0, [labelText length])];
            self.achievementNameLabel.attributedText = attributeString;
            [self.chooseBtn setAttributedTitle:btnAttributeString forState:UIControlStateNormal];
            if (isDiamondKiller == 1) {
                self.lockImageView.image = nil;
                [self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button"] forState:UIControlStateNormal];
                [self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button-pressed"] forState:UIControlStateHighlighted];
                [self.chooseBtn setEnabled:YES];
                [self.chooseBtn addTarget:self action:@selector(chooseCurrentCard:) forControlEvents:UIControlEventTouchUpInside];
                [self.shareBtn setHidden:NO];
            } else {
                //self.lockImageView.image = [UIImage imageNamed:@"lock"];
                [self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button-lock"] forState:UIControlStateNormal];
                [self.chooseBtn setEnabled:NO];
                [self.shareBtn setHidden:YES];
            }
            break;
        }
            
        case 5:
        {
            NSInteger isJokerKiller = [defaults integerForKey:kIsJokerKiller];
            NSString *labelText = @"Erase Two Jokers";
            btnAttributeString = nil;
            NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:labelText];
            [attributeString addAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor],
                                             NSFontAttributeName:[UIFont fontWithName:@"Verdana-Bold" size:fontSize],
                                             NSParagraphStyleAttributeName:paragraphStyle}
                                     range:NSMakeRange(0, [labelText length])];
            self.achievementNameLabel.attributedText = attributeString;
            [self.chooseBtn setAttributedTitle:btnAttributeString forState:UIControlStateNormal];
            if (isJokerKiller == 1) {
                self.lockImageView.image = nil;
                [self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button"] forState:UIControlStateNormal];
                [self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button-pressed"] forState:UIControlStateHighlighted];
                [self.chooseBtn setEnabled:YES];
                [self.chooseBtn addTarget:self action:@selector(chooseCurrentCard:) forControlEvents:UIControlEventTouchUpInside];
                [self.shareBtn setHidden:NO];
            } else {
                //self.lockImageView.image = [UIImage imageNamed:@"lock"];
                [self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button-lock"] forState:UIControlStateNormal];
                [self.chooseBtn setEnabled:NO];
                [self.shareBtn setHidden:YES];
            }
            break;
        }
            
        case 6:
        {
            //self.lockImageView.image = [UIImage imageNamed:@"lock"];
            NSString *labelText = @"Transmit";
            btnAttributeString = nil;
            NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:labelText];
            [attributeString addAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor],
                                             NSFontAttributeName:[UIFont fontWithName:@"Verdana-Bold" size:fontSize],
                                             NSParagraphStyleAttributeName:paragraphStyle}
                                     range:NSMakeRange(0, [labelText length])];
            self.achievementNameLabel.attributedText = attributeString;
            
            //[self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button-lock"] forState:UIControlStateNormal];
            //[self.chooseBtn setEnabled:YES];
            //[self.shareBtn setHidden:YES];
            
            // 如果已经购买,flag为true
            
            BOOL flag = YES;
            if (flag) {
                [self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button"] forState:UIControlStateNormal];
                [self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button-pressed"] forState:UIControlStateHighlighted];
                [self.shareBtn setHidden:NO];
                [self.chooseBtn setEnabled:YES];
                [self.chooseBtn addTarget:self action:@selector(chooseCurrentCard:) forControlEvents:UIControlEventTouchUpInside];
                [self.chooseBtn setAttributedTitle:nil forState:UIControlStateNormal];
            } else {
                [self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button-dollar"] forState:UIControlStateNormal];
                [self.chooseBtn setAttributedTitle:btnAttributeString forState:UIControlStateNormal];
                [self.shareBtn setHidden:YES];
                [self.chooseBtn setEnabled:NO];
                [self.chooseBtn addTarget:self action:@selector(purchaseCardBack:) forControlEvents:UIControlEventTouchUpInside];
            }
            
            
            break;
        }
            
        case 7:
        {
            //self.lockImageView.image = [UIImage imageNamed:@"lock"];
            NSString *labelText = @"Autumn Butterflies";
            btnAttributeString = nil;
            NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:labelText];
            [attributeString addAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor],
                                             NSFontAttributeName:[UIFont fontWithName:@"Verdana-Bold" size:fontSize],
                                             NSParagraphStyleAttributeName:paragraphStyle}
                                     range:NSMakeRange(0, [labelText length])];
            self.achievementNameLabel.attributedText = attributeString;
            
            //[self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button-lock"] forState:UIControlStateNormal];
            //[self.chooseBtn setEnabled:NO];
            //[self.shareBtn setHidden:YES];
            
            // 如果已经购买,flag为true
            BOOL flag = YES;
            if (flag) {
                [self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button"] forState:UIControlStateNormal];
                //[self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button-pressed"] forState:UIControlStateHighlighted];
                [self.shareBtn setHidden:NO];
                [self.chooseBtn setEnabled:YES];
                [self.chooseBtn addTarget:self action:@selector(chooseCurrentCard:) forControlEvents:UIControlEventTouchUpInside];
                [self.chooseBtn setAttributedTitle:nil forState:UIControlStateNormal];
            } else {
                [self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button-dollar"] forState:UIControlStateNormal];
                [self.chooseBtn setAttributedTitle:btnAttributeString forState:UIControlStateNormal];
                [self.shareBtn setHidden:YES];
                [self.chooseBtn setEnabled:NO];
                [self.chooseBtn addTarget:self action:@selector(purchaseCardBack:) forControlEvents:UIControlEventTouchUpInside];
            }
             
            break;
        }
            
        case 8:
        {
            //self.lockImageView.image = [UIImage imageNamed:@"lock"];
            NSString *labelText = @"Plum Pinwheel";
            btnAttributeString = nil;
            NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:labelText];
            [attributeString addAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor],
                                             NSFontAttributeName:[UIFont fontWithName:@"Verdana-Bold" size:fontSize],
                                             NSParagraphStyleAttributeName:paragraphStyle}
                                     range:NSMakeRange(0, [labelText length])];
            self.achievementNameLabel.attributedText = attributeString;
            
            //[self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button-lock"] forState:UIControlStateNormal];
            //[self.chooseBtn setEnabled:NO];
            //[self.shareBtn setHidden:YES];
            
            // 如果已经购买,flag为true
            BOOL flag = YES;
            if (flag) {
                [self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button"] forState:UIControlStateNormal];
                //[self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button-pressed"] forState:UIControlStateHighlighted];
                [self.shareBtn setHidden:NO];
                [self.chooseBtn setEnabled:YES];
                [self.chooseBtn addTarget:self action:@selector(chooseCurrentCard:) forControlEvents:UIControlEventTouchUpInside];
                [self.chooseBtn setAttributedTitle:nil forState:UIControlStateNormal];
            } else {
                [self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button-dollar"] forState:UIControlStateNormal];
                [self.chooseBtn setAttributedTitle:btnAttributeString forState:UIControlStateNormal];
                [self.shareBtn setHidden:YES];
                [self.chooseBtn setEnabled:NO];
                [self.chooseBtn addTarget:self action:@selector(purchaseCardBack:) forControlEvents:UIControlEventTouchUpInside];
            }
            
            break;
        }
            
        case 9:
        {
            //self.lockImageView.image = [UIImage imageNamed:@"lock"];
            NSString *labelText = @"Ruby Sundial";
            btnAttributeString = nil;
            NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:labelText];
            [attributeString addAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor],
                                             NSFontAttributeName:[UIFont fontWithName:@"Verdana-Bold" size:fontSize],
                                             NSParagraphStyleAttributeName:paragraphStyle}
                                     range:NSMakeRange(0, [labelText length])];
            self.achievementNameLabel.attributedText = attributeString;
            
            //[self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button-lock"] forState:UIControlStateNormal];
            //[self.chooseBtn setEnabled:NO];
            //[self.shareBtn setHidden:YES];

            // 如果已经购买,flag为true
            BOOL flag = YES;
            if (flag) {
                [self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button"] forState:UIControlStateNormal];
                //[self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button-pressed"] forState:UIControlStateHighlighted];
                [self.shareBtn setHidden:NO];
                [self.chooseBtn setEnabled:YES];
                [self.chooseBtn addTarget:self action:@selector(chooseCurrentCard:) forControlEvents:UIControlEventTouchUpInside];
                [self.chooseBtn setAttributedTitle:nil forState:UIControlStateNormal];
            } else {
                [self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button-dollar"] forState:UIControlStateNormal];
                [self.chooseBtn setAttributedTitle:btnAttributeString forState:UIControlStateNormal];
                [self.shareBtn setHidden:YES];
                [self.chooseBtn setEnabled:NO];
                [self.chooseBtn addTarget:self action:@selector(purchaseCardBack:) forControlEvents:UIControlEventTouchUpInside];
            }

            break;
        }
            
        case 10:
        {
            //self.lockImageView.image = [UIImage imageNamed:@"lock"];
            btnAttributeString = [[NSMutableAttributedString alloc]
                                  initWithString:@"$1.99"
                                  attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],
                                               NSFontAttributeName:[UIFont fontWithName:@"Verdana-Bold" size:btnFontSize],
                                               NSParagraphStyleAttributeName:paragraphStyle}];
            NSString *labelText = @"Neon Lamp";
            btnAttributeString = nil;
            NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:labelText];
            [attributeString addAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor],
                                             NSFontAttributeName:[UIFont fontWithName:@"Verdana-Bold" size:fontSize],
                                             NSParagraphStyleAttributeName:paragraphStyle}
                                     range:NSMakeRange(0, [labelText length])];
            self.achievementNameLabel.attributedText = attributeString;
            
            //[self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button-lock"] forState:UIControlStateNormal];
            //[self.chooseBtn setEnabled:NO];
            //[self.shareBtn setHidden:YES];

            // 如果已经购买,flag为true
            BOOL flag = YES;
            if (flag) {
                [self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button"] forState:UIControlStateNormal];
                //[self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button-pressed"] forState:UIControlStateHighlighted];
                [self.shareBtn setHidden:NO];
                [self.chooseBtn setEnabled:YES];
                [self.chooseBtn addTarget:self action:@selector(chooseCurrentCard:) forControlEvents:UIControlEventTouchUpInside];
                [self.chooseBtn setAttributedTitle:nil forState:UIControlStateNormal];
            } else {
                [self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button-dollar"] forState:UIControlStateNormal];
                [self.chooseBtn setAttributedTitle:btnAttributeString forState:UIControlStateNormal];
                [self.shareBtn setHidden:YES];
                [self.chooseBtn setEnabled:NO];
                [self.chooseBtn addTarget:self action:@selector(purchaseCardBack:) forControlEvents:UIControlEventTouchUpInside];
            }

            break;
        }
            
        case 11:
        {
            //self.lockImageView.image = [UIImage imageNamed:@"lock"];
            btnAttributeString = [[NSMutableAttributedString alloc]
                                  initWithString:@"$1.99"
                                  attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],
                                               NSFontAttributeName:[UIFont fontWithName:@"Verdana-Bold" size:btnFontSize],
                                               NSParagraphStyleAttributeName:paragraphStyle}];
            NSString *labelText = @"Daisies";
            btnAttributeString = nil;
            NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:labelText];
            [attributeString addAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor],
                                             NSFontAttributeName:[UIFont fontWithName:@"Verdana-Bold" size:fontSize],
                                             NSParagraphStyleAttributeName:paragraphStyle}
                                     range:NSMakeRange(0, [labelText length])];
            self.achievementNameLabel.attributedText = attributeString;
            
            //[self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button-lock"] forState:UIControlStateNormal];
            //[self.chooseBtn setEnabled:NO];
            //[self.shareBtn setHidden:YES];

            // 如果已经购买,flag为true
            BOOL flag = YES;
            if (flag) {
                [self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button"] forState:UIControlStateNormal];
                //[self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button-pressed"] forState:UIControlStateHighlighted];
                [self.shareBtn setHidden:NO];
                [self.chooseBtn setEnabled:YES];
                [self.chooseBtn addTarget:self action:@selector(chooseCurrentCard:) forControlEvents:UIControlEventTouchUpInside];
                [self.chooseBtn setAttributedTitle:nil forState:UIControlStateNormal];
            } else {
                [self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button-dollar"] forState:UIControlStateNormal];
                [self.chooseBtn setAttributedTitle:btnAttributeString forState:UIControlStateNormal];
                [self.shareBtn setHidden:YES];
                [self.chooseBtn setEnabled:NO];
                [self.chooseBtn addTarget:self action:@selector(purchaseCardBack:) forControlEvents:UIControlEventTouchUpInside];
            }
            
            
            
            break;
        }
            
        case 12:
        {
            //self.lockImageView.image = [UIImage imageNamed:@"lock"];
            btnAttributeString = [[NSMutableAttributedString alloc]
                                  initWithString:@"$1.99"
                                  attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],
                                               NSFontAttributeName:[UIFont fontWithName:@"Verdana-Bold" size:btnFontSize],
                                               NSParagraphStyleAttributeName:paragraphStyle}];
            NSString *labelText = @"Prestige";
            btnAttributeString = nil;
            NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:labelText];
            [attributeString addAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor],
                                             NSFontAttributeName:[UIFont fontWithName:@"Verdana-Bold" size:fontSize],
                                             NSParagraphStyleAttributeName:paragraphStyle}
                                     range:NSMakeRange(0, [labelText length])];
            self.achievementNameLabel.attributedText = attributeString;
            
            //[self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button-lock"] forState:UIControlStateNormal];
            //[self.chooseBtn setEnabled:NO];
            //[self.shareBtn setHidden:YES];
 
            // 如果已经购买,flag为true
            BOOL flag = YES;
            if (flag) {
                [self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button"] forState:UIControlStateNormal];
                //[self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button-pressed"] forState:UIControlStateHighlighted];
                [self.shareBtn setHidden:NO];
                [self.chooseBtn setEnabled:YES];
                [self.chooseBtn addTarget:self action:@selector(chooseCurrentCard:) forControlEvents:UIControlEventTouchUpInside];
                [self.chooseBtn setAttributedTitle:nil forState:UIControlStateNormal];
            } else {
                [self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"short-button-dollar"] forState:UIControlStateNormal];
                [self.chooseBtn setAttributedTitle:btnAttributeString forState:UIControlStateNormal];
                [self.shareBtn setHidden:YES];
                [self.chooseBtn setEnabled:NO];
                [self.chooseBtn addTarget:self action:@selector(purchaseCardBack:) forControlEvents:UIControlEventTouchUpInside];
            }

            break;
        }
            
    }

}

- (NSInteger)accomplishedAchievementNum
{
    NSInteger achievedNum = 0;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    // -12
    achievedNum++;
    
    // -11
    NSInteger gameWinTimes = [defaults integerForKey:kGameWinTimes];
    if (gameWinTimes >= 1) {
        achievedNum++;
    }
    
    // -10
    if (gameWinTimes >= 100) {
        achievedNum++;
    }
    
    // -9
    if (gameWinTimes >= 500) {
        achievedNum++;
    }
    
    // -8
    NSInteger scoreMoreThan40 = [defaults integerForKey:kScoreMoreThan40];
    if (scoreMoreThan40 == 1) {
        achievedNum++;
    }
    
    // -7
    NSInteger scoreMoreThan50 = [defaults integerForKey:kScoreMoreThan50];
    if (scoreMoreThan50 == 1) {
        achievedNum++;
    }
    
    // -6
    NSInteger scoreMoreThan60 = [defaults integerForKey:kScoreMoreThan60];
    if (scoreMoreThan60 == 1) {
        achievedNum++;
    }
    
    // -5
    NSInteger isLeftCardLessThan4 = [defaults integerForKey:kIsLeftCardsNumLessThan4];
    if (isLeftCardLessThan4 == 1) {
        achievedNum++;
    }
    
    // -4
    NSInteger isLeftCardEqualTo0 = [defaults integerForKey:kIsLeftCardsNumEqualTo0];
    if (isLeftCardEqualTo0 == 1) {
        achievedNum++;
    }
    
    // -3
    NSInteger is50MoveStep = [defaults integerForKey:kIsMoveNumberEqualTo52];
    if (is50MoveStep == 1) {
        achievedNum++;
    }
    
    // -2
    NSInteger isErase4Flush = [defaults integerForKey:kIsGotFlush];
    if (isErase4Flush == 1) {
        achievedNum++;
    }
    
    // -1
    NSInteger isErase4Straight = [defaults integerForKey:kIsGotStraight];
    if (isErase4Straight == 1) {
        achievedNum++;
    }
    
    // 0
    //NSInteger isErase4SameKind = [defaults integerForKey:kIsGotSameKind];
    if (isErase4Straight == 1) {
        achievedNum++;
    }
    
    // 1
    NSInteger isClubKiller = [defaults integerForKey:kIsClubKiller];
    if (isClubKiller == 1) {
        achievedNum++;
    }
    
    // 2
    NSInteger isHeartKiller = [defaults integerForKey:kIsHeartKiller];
    if (isHeartKiller) {
        achievedNum++;
    }
    
    // 3
    NSInteger isSpadeKiller = [defaults integerForKey:kIsSpadeKiller];
    if (isSpadeKiller) {
        achievedNum++;
    }
    
    // 4
    NSInteger isDiamondKiller = [defaults integerForKey:kIsDiamondKiller];
    if (isDiamondKiller) {
        achievedNum++;
    }
    
    // 5
    NSInteger isJokerKiller = [defaults integerForKey:kIsJokerKiller];
    if (isJokerKiller) {
        achievedNum++;
    }
    
    // 6,7,8,9,10,11,12被锁住了
    
    return achievedNum;
}

@end







