//
//  ResultViewController.m
//  Tlm2048_1
//
//  Created by tom555cat on 15/12/22.
//  Copyright © 2015年 tom555cat. All rights reserved.
//

#import "ResultViewController.h"
#import "JWBlurView.h"
#import "AchivementView.h"
#import "CardBackScrollViewController.h"
#import "AppSpecificValues.h"
#import "WeixinActivity.h"

// 定义成就key
NSString *const AchivementTestKey=@"ArchivementTest";

// 弹出视图变量定义
static CGFloat const kAnimationDuration = .4f;
static CGFloat const kRotationAngle = 70.f;

// 字体设置
static const CGFloat coefficent = 28.0f/72.0f;

static NSInteger const kENPopUpOverlayViewTag   = 351301;
static NSInteger const kENPopUpViewTag          = 351302;
static NSInteger const kENPopUpBluredViewTag    = 351303;

@interface ResultViewController ()
@property (nonatomic, strong) UILabel *resultLabel;
@property (nonatomic, strong) UILabel *scoreLabel;
@property (nonatomic, strong) UILabel *recordLabel;
@property (nonatomic, strong) UIButton *gameCenterBtn;
@property (nonatomic, strong) NSMutableArray *achivementArray;

// 本次游戏达成的成就个数
@property (nonatomic) NSInteger count;

// 微信分享
@property (nonatomic, strong) NSArray *activity;

@end

@implementation ResultViewController

- (NSMutableArray *)achivementArray
{
    if (_achivementArray == nil) {
        _achivementArray = [[NSMutableArray alloc] init];
    }
    return _achivementArray;
}

/*
+ (instancetype)initWithHasWon:(BOOL)hasWon
                         score:(NSInteger)score
{
    ResultViewController *vc = [[ResultViewController alloc] init];
    vc.hasWon = hasWon;
    vc.score = score;
    vc.view.backgroundColor = [UIColor whiteColor];
    return vc;
}
 */

+ (instancetype)initWithHasWon:(BOOL)hasWon
                         score:(NSInteger)score
               leftPokerNumber:(NSInteger)leftPokerNumber
                    moveNumber:(NSInteger)moveNumber
                       isFlush:(BOOL)isFlush
                    isStraight:(BOOL)isStraight
                    isSameKind:(BOOL)isSameKind
           erasedDiamondNumber:(NSInteger)erasedDiamondNumber
              erasedClubNumber:(NSInteger)erasedClubNumber
             erasedSpadeNumber:(NSInteger)erasedSpadeNumber
             erasedHeartNumber:(NSInteger)erasedHeartNumber
             erasedJokerNumber:(NSInteger)erasedJokerNumber
{
    ResultViewController *vc = [[ResultViewController alloc] init];
    vc.hasWon = hasWon;
    vc.score = score;
    vc.view.backgroundColor = [UIColor whiteColor];
    
    vc.leftPokerNumber = leftPokerNumber;
    vc.moveNumber = moveNumber;
    vc.isFlush = isFlush;
    vc.isStraight = isStraight;
    vc.isSameKind = isSameKind;
    vc.erasedDiamondNumber = erasedDiamondNumber;
    vc.erasedClubNumber = erasedClubNumber;
    vc.erasedSpadeNumber = erasedSpadeNumber;
    vc.erasedHeartNumber = erasedHeartNumber;
    vc.erasedJokerNumber = erasedJokerNumber;
    
    [vc checkAchivement];
    
    return vc;
}

// 布局
// 10%  空余
// 10%  丝带
// 2%   空余
// 30%  成绩
// 5%   记录
// 13%  空余
// 8%  成就按钮
// 2%   padding
// 10%  再来一盘按钮
// 10%  空余
- (void)setup
{
    CGSize winSize = [[UIScreen mainScreen] bounds].size;
    CGFloat currentTop = winSize.height * 0.1f;
    
    // 胜负标签
    CGFloat ribbonHeight = winSize.height * 0.1f;
    CGFloat ribbonWidth = ribbonHeight * 3500.0f / 801.0f;
    UIButton *ribbon = [[UIButton alloc] initWithFrame:CGRectMake(winSize.width/2.0f-ribbonWidth/2.0f, currentTop, ribbonWidth, ribbonHeight)];
    NSString *resultStr = @"";
    NSString *resultImage = @"";
    UIColor *fontColor = nil;
    if (self.hasWon == YES) {
        resultStr = @"You Win!";
        resultImage = @"ribbon";
        fontColor = [UIColor yellowColor];
    } else {
        resultStr = @"You Lose!";
        resultImage = @"ribbon-lose";
        fontColor = [UIColor blackColor];
    }
    
    CGFloat fontSize = winSize.height*35/667;
    [ribbon setBackgroundImage:[UIImage imageNamed:resultImage] forState:UIControlStateNormal];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSMutableAttributedString *btnAttributeString = [[NSMutableAttributedString alloc] initWithString:resultStr attributes:@{NSForegroundColorAttributeName:fontColor,NSFontAttributeName:[UIFont fontWithName:@"HiraKakuProN-W6" size:fontSize],NSParagraphStyleAttributeName:paragraphStyle}];
    [ribbon setAttributedTitle:btnAttributeString forState:UIControlStateNormal];
    [self.view addSubview:ribbon];
    currentTop += ribbonHeight + winSize.height*0.02f;
    
    // 分数标签
    CGFloat scoreLabelHeight = winSize.height * 0.3f;
    CGFloat scoreLabelWidth = winSize.width;
    CGFloat fontSize11 = winSize.height*140/667;
    UIButton *scoreLabel = [[UIButton alloc] initWithFrame:CGRectMake(winSize.width/2.0f-scoreLabelWidth/2.0f, currentTop, scoreLabelWidth, scoreLabelHeight)];
    NSMutableAttributedString *scoreLabelAttributeString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld", (long)self.score] attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:0 green:31.0f/255.0f blue:86.0f/255.0f alpha:1.0],NSFontAttributeName:[UIFont fontWithName:@"MarkerFelt-Thin" size:fontSize11],NSParagraphStyleAttributeName:paragraphStyle}];
    //scoreLabel.backgroundColor = [UIColor grayColor];
    //scoreLabel.attributedText = scorelabelAttributeString;
    //self.scoreLabel = scoreLabel;
    [scoreLabel setAttributedTitle:scoreLabelAttributeString forState:UIControlStateNormal];
    [self.view addSubview:scoreLabel];
    currentTop += scoreLabelHeight;
    
    // 最高记录
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger recordScore = [defaults integerForKey:kGameTopScore];
    CGFloat recordLabelHeight = winSize.height * 0.05f;
    CGFloat recordLabelWidth = winSize.width * 0.5f;
    CGFloat fontSize1 = winSize.height*20/667;
    UILabel *recordLabel = [[UILabel alloc] initWithFrame:CGRectMake(winSize.width/2.0f-recordLabelWidth/2.0f, currentTop, recordLabelWidth, recordLabelHeight)];
    NSMutableAttributedString *recordLabelAttributeString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Top Score %ld", (long)(recordScore > self.score ? recordScore : self.score)] attributes:@{NSForegroundColorAttributeName:[UIColor blackColor],NSFontAttributeName:[UIFont fontWithName:@"HiraKakuProN-W3" size:fontSize1],NSParagraphStyleAttributeName:paragraphStyle}];
    recordLabel.attributedText = recordLabelAttributeString;
    [self.view addSubview:recordLabel];
    currentTop += winSize.height * 0.13f + recordLabelHeight;
    
    // 成就按钮
    CGFloat achivementHeight = winSize.height * 0.08f;
    CGFloat achivementWidth = achivementHeight * 4.0f;
    UIButton *achivement = [[UIButton alloc] initWithFrame:CGRectMake(winSize.width/2.0f-achivementWidth/2.0f, currentTop, achivementWidth, achivementHeight)];
    [achivement setBackgroundImage:[UIImage imageNamed:@"achivementCheck"] forState:UIControlStateNormal];
    NSMutableAttributedString *achivementBtnAttributeString = [[NSMutableAttributedString alloc] initWithString:@"Achivement" attributes:@{NSForegroundColorAttributeName:[UIColor blackColor],NSFontAttributeName:[UIFont fontWithName:@"MarkerFelt-Thin" size:20],NSParagraphStyleAttributeName:paragraphStyle}];
    [achivement setAttributedTitle:achivementBtnAttributeString forState:UIControlStateNormal];
    [achivement addTarget:self action:@selector(changeCardBack:) forControlEvents:UIControlEventTouchUpInside];
    //[self.view addSubview:achivement];
    currentTop += achivementHeight + 0.02f*winSize.height;
    
    // 在来一盘按钮
    CGFloat playAgainBtnHeight = winSize.height * 0.1f;
    CGFloat playAgainBtnWidth = playAgainBtnHeight * 2.0f;
    UIButton *playAgainBtn = [[UIButton alloc] initWithFrame:CGRectMake(winSize.width/2.0f-playAgainBtnWidth/2.0f, currentTop, playAgainBtnWidth, playAgainBtnHeight)];
    [playAgainBtn setBackgroundImage:[UIImage imageNamed:@"home1"] forState:UIControlStateNormal];
    [playAgainBtn setBackgroundImage:[UIImage imageNamed:@"home1-pressed"] forState:UIControlStateHighlighted];
    [playAgainBtn addTarget:self action:@selector(returnToMain:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:playAgainBtn];
    
    // 返回主界面左边的gamecenter按钮
    CGFloat gameCenterWidth = playAgainBtnWidth * 0.4f;
    CGFloat gameCenterHeight = gameCenterWidth;
    CGFloat padding = winSize.width * 0.06f;
    UIButton *gameCenter = [[UIButton alloc] initWithFrame:CGRectMake(playAgainBtn.frame.origin.x-padding-gameCenterWidth, currentTop+playAgainBtnHeight/2.0f-gameCenterHeight/2.0f, gameCenterWidth, gameCenterHeight)];
    [gameCenter setBackgroundImage:[UIImage imageNamed:@"gamecenter"] forState:UIControlStateNormal];
    [gameCenter addTarget:self action:@selector(showAchievements) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:gameCenter];
    self.gameCenterBtn = gameCenter;
    
    // 返回主界面右边的分享按钮
    CGFloat shareWidth = playAgainBtnWidth * 0.4f;
    CGFloat shareHeight = shareWidth * 127.0f / 125.0f;
    UIButton *share = [[UIButton alloc] initWithFrame:CGRectMake(playAgainBtn.frame.origin.x+playAgainBtnWidth+padding, currentTop+playAgainBtnHeight/2.0f-shareHeight/2.0f, shareWidth, shareHeight)];
    [share setBackgroundImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
    [share addTarget:self action:@selector(shareContent) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:share];
}

- (void)showAchievements
{
    GKGameCenterViewController *achievements = [[GKGameCenterViewController alloc] init];
    if (achievements != NULL) {
        //achievements.achievementDelegate = self;
        achievements.gameCenterDelegate = self;
        //[self presentModalViewController:achievements animated:YES];
        [self presentViewController:achievements animated:YES completion:nil];
    }
}

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
- (void)achievementViewControllerDidFinish:(GKGameCenterViewController *)viewController
{
    //[self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}
 */

- (void)changeCardBack:(id)sender
{
    CardBackScrollViewController *cardBackScrollViewController = [[CardBackScrollViewController alloc] init];
    [self presentViewController:cardBackScrollViewController animated:YES completion:nil];
}

- (void)shareContent
{
    NSString *description = [NSString stringWithFormat:@"I got score:%ld in Poker2048!", (long)self.score];
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

// 返回主界面
- (void)returnToMain:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

// 检查是否达成了成就，如果达成成就，就弹出响应的卡背奖励
- (void)checkAchivement
{
    CGFloat fontSize = coefficent * self.resultLabel.frame.size.height;
    
    // 弹出成就界面的尺寸
    CGSize winSize = self.view.bounds.size;
    CGFloat achievementViewHeight = winSize.height * 0.6f;
    CGFloat achievementViewWidth = achievementViewHeight * 0.6f;
    
    // 居中显示
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    // 是否胜利的标签设置
    NSLog(@"height is %f", self.resultLabel.frame.size.height);
    NSString *hasWonString = self.hasWon ? @"You Win" : @"You Lose";
    NSMutableAttributedString *hasWonAttributeString = [[NSMutableAttributedString alloc] initWithString:hasWonString];
    [hasWonAttributeString addAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor],
                                     NSFontAttributeName:[UIFont fontWithName:@"Verdana-Bold" size:fontSize],
                                     NSParagraphStyleAttributeName:paragraphStyle}
                             range:NSMakeRange(0, [hasWonString length])];
    self.resultLabel.attributedText = hasWonAttributeString;
    
    // 得分标签的设置
    NSString *scoreString = [NSString stringWithFormat:@"Final Score: %ld", (long)self.score];
    NSMutableAttributedString *scoreAttributeString = [[NSMutableAttributedString alloc] initWithString:scoreString attributes:@{NSForegroundColorAttributeName:[UIColor blackColor],
                                                                                                                                 NSFontAttributeName:[UIFont fontWithName:@"Verdana-Bold" size:fontSize],
                                                                                                                                 NSParagraphStyleAttributeName:paragraphStyle}];
    self.scoreLabel.attributedText= scoreAttributeString;
    
    // 获取本地保存数据
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // 检查是否获取了新的得分记录
    NSInteger recordScore = [defaults integerForKey:kGameTopScore];
    if (self.score > recordScore) {
        NSMutableAttributedString *recordAttributeString = [[NSMutableAttributedString alloc] initWithString:@"New Record Score!" attributes:@{NSForegroundColorAttributeName:[UIColor blackColor],
                                                                                                                                     NSFontAttributeName:[UIFont fontWithName:@"Verdana-Bold" size:fontSize/2],
                                                                                                                                     NSParagraphStyleAttributeName:paragraphStyle}];
        self.recordLabel.attributedText = recordAttributeString;
        [defaults setInteger:self.score forKey:kGameTopScore];
    }
    
    // 提交游戏成就
    [self.gameCenterManager reportScore:self.score > recordScore ? self.score : recordScore forCategory:kLeaderboardID];
    
    // 更新游戏次数本地数据
    NSInteger gameTimes = [defaults integerForKey:kGameTimes];
    [defaults setInteger:++gameTimes forKey:kGameTimes];
    
    // 更新游戏成功次数本地数据
    NSInteger gameWinTimes = [defaults integerForKey:kGameWinTimes];
    
    // 获得游戏胜利成就，当gameWinTimes为0时，并且当前hasWon为YES，获取这个成就
    NSInteger isWinOnce = [defaults integerForKey:kGameWinOnce];
    if (self.hasWon == YES && isWinOnce == 0) {
        // 获得了“获胜成就”
        AchivementView *achivementView = [AchivementView achivementWithPosition:CGPointZero sideWidth:achievementViewWidth sideHeight:achievementViewHeight cardBackImageStr:@"-11" achivementDiscription:@"You Win One Time"];
        [self.achivementArray addObject:achivementView];
        
        // Game Center提交达成就成
        [self.gameCenterManager submitAchievement:kAchievementWinOnce percentComplete:100.0];
        [defaults setInteger:1 forKey:kGameWinOnce];
        NSLog(@"Reach the achivement: win a game");
    }
    [defaults setInteger:++gameWinTimes forKey:kGameWinTimes];
    
    // 赢得游戏100次成就，当gameWinTimes为100时获取
    NSInteger isWin100 = [defaults integerForKey:kGameWin100];
    if (self.hasWon == YES && gameWinTimes == 100 && isWin100 == 0) {
        AchivementView *achivementView = [AchivementView achivementWithPosition:CGPointZero sideWidth:achievementViewWidth sideHeight:achievementViewHeight cardBackImageStr:@"-10" achivementDiscription:@"You Win 100 Times"];
        [self.achivementArray addObject:achivementView];
        [self.gameCenterManager submitAchievement:kAchievementWin100 percentComplete:100.0];
        [defaults setInteger:1 forKey:kGameWin100];
        NSLog(@"Reach the achivement: win 100 games");
    }
    
    // 赢得游戏500次成就，当gameWinTimes为500时获取
    NSInteger isWin500 = [defaults integerForKey:kGameWin500];
    if (self.hasWon == YES && gameWinTimes == 500 && isWin500 == 0) {
        AchivementView *achivementView = [AchivementView achivementWithPosition:CGPointZero sideWidth:achievementViewWidth sideHeight:achievementViewHeight cardBackImageStr:@"-9" achivementDiscription:@"You Win 500 Time"];
        [self.achivementArray addObject:achivementView];
        [self.gameCenterManager submitAchievement:kAchievementWin500 percentComplete:100.0];
        [defaults setInteger:1 forKey:kGameWin500];
        NSLog(@"Reach the achivement: win 500 games");
    }
    
    // 获取积分40分以上成就
    NSInteger isGotScoreOver40 = [defaults integerForKey:kScoreMoreThan40];
    if (self.hasWon == YES && self.score >= 40 && isGotScoreOver40 == 0) {
        AchivementView *achivementView = [AchivementView achivementWithPosition:CGPointZero sideWidth:achievementViewWidth sideHeight:achievementViewHeight cardBackImageStr:@"-8" achivementDiscription:@"Score Over 40"];
        [self.achivementArray addObject:achivementView];
        [self.gameCenterManager submitAchievement:kAchievementScoreMoreThan40 percentComplete:100.0];
        [defaults setInteger:1 forKey:kScoreMoreThan40];
        NSLog(@"Reach the achivement: game over 40");
    }
    
    // 获得积分50分以上成就
    NSInteger isGotScoreOver50 = [defaults integerForKey:kScoreMoreThan50];
    if (self.hasWon == YES && self.score >= 50 && isGotScoreOver50 == 0) {
        AchivementView *achivementView = [AchivementView achivementWithPosition:CGPointZero sideWidth:achievementViewWidth sideHeight:achievementViewHeight cardBackImageStr:@"-7" achivementDiscription:@"Score Over 50"];
        [self.achivementArray addObject:achivementView];
        [self.gameCenterManager submitAchievement:kAchievementScoreMoreThan50 percentComplete:100.0];
        [defaults setInteger:1 forKey:kScoreMoreThan50];
        NSLog(@"Reach the achivement: game over 50");
    }
    
    // 获得积分60分以上成就
    NSInteger isGotScoreOver60 = [defaults integerForKey:kScoreMoreThan60];
    if (self.hasWon == YES && self.score >= 60 && isGotScoreOver60 == 0) {
        AchivementView *achivementView = [AchivementView achivementWithPosition:CGPointZero sideWidth:achievementViewWidth sideHeight:achievementViewHeight cardBackImageStr:@"-6" achivementDiscription:@"Score Over 60"];
        [self.achivementArray addObject:achivementView];
        [self.gameCenterManager submitAchievement:kAchievementScoreMoreThan60 percentComplete:100.0];
        [defaults setInteger:1 forKey:kScoreMoreThan60];
        NSLog(@"Reach the achivement: game over 60");
    }
    
    // 桌面剩余卡牌少于4张
    NSInteger isLeftCardsNumLessThan4 = [defaults integerForKey:kIsLeftCardsNumLessThan4];
    if (isLeftCardsNumLessThan4 == 0) {
        // 桌面剩余卡牌小于4
        if (self.leftPokerNumber <= 4) {
            AchivementView *achivementView = [AchivementView achivementWithPosition:CGPointZero sideWidth:achievementViewWidth sideHeight:achievementViewHeight cardBackImageStr:@"-5" achivementDiscription:@"Cleaner"];
            [self.achivementArray addObject:achivementView];
            [self.gameCenterManager submitAchievement:kAchievementCleaner percentComplete:100.0];
            [defaults setInteger:1 forKey:kIsLeftCardsNumLessThan4];
        }
        
        // 桌面剩余卡牌为0
        if (self.leftPokerNumber == 0) {
            AchivementView *achivementView = [AchivementView achivementWithPosition:CGPointZero sideWidth:achievementViewWidth sideHeight:achievementViewHeight cardBackImageStr:@"-4" achivementDiscription:@"Super Cleaner"];
            [self.achivementArray addObject:achivementView];
            [self.gameCenterManager submitAchievement:kAchievementSuperCleaner percentComplete:100.0];
            [defaults setInteger:1 forKey:kIsLeftCardsNumEqualTo0];
        }
    }
    
    // 移动次数52次
    /*
    NSInteger isMoveNumEqualTo52 = [defaults integerForKey:kIsMoveNumberEqualTo52];
    if (isMoveNumEqualTo52 == 0 && self.hasWon == YES) {
        if (self.moveNumber == 51) {
            AchivementView *achivementView = [AchivementView achivementWithPosition:CGPointZero sideWidth:achievementViewWidth sideHeight:achievementViewHeight cardBackImageStr:@"-3" achivementDiscription:@"Speedy"];
            [self.achivementArray addObject:achivementView];
            [self.gameCenterManager submitAchievement:kAchievementSpeedy percentComplete:100.0];
            [defaults setInteger:1 forKey:kIsMoveNumberEqualTo52];
        }
    }
    */
    
    // 4顺子，4同花，4samekind
    NSInteger isFlush = [defaults integerForKey:kIsGotFlush];
    NSInteger isStraight = [defaults integerForKey:kIsGotStraight];
    NSInteger isSameKind = [defaults integerForKey:kIsGotSameKind];
    if (self.hasWon == YES) {
        if (isFlush == 0 && self.isFlush == YES) {
            AchivementView *achivementView = [AchivementView achivementWithPosition:CGPointZero sideWidth:achievementViewWidth sideHeight:achievementViewHeight cardBackImageStr:@"-2" achivementDiscription:@"Flush King"];
            [self.achivementArray addObject:achivementView];
            [self.gameCenterManager submitAchievement:kAchievementFlushKing percentComplete:100.0];
            [defaults setInteger:1 forKey:kIsGotFlush];
        }
        
        if (isStraight == 0 && self.isStraight == YES) {
            AchivementView *achivementView = [AchivementView achivementWithPosition:CGPointZero sideWidth:achievementViewWidth sideHeight:achievementViewHeight cardBackImageStr:@"-1" achivementDiscription:@"Straight King"];
            [self.achivementArray addObject:achivementView];
            [self.gameCenterManager submitAchievement:kAchievementStraightKing percentComplete:100.0];
            [defaults setInteger:1 forKey:kIsGotStraight];
        }
        
        if (isSameKind == 0 && self.isSameKind == YES) {
            AchivementView *achivementView = [AchivementView achivementWithPosition:CGPointZero sideWidth:achievementViewWidth sideHeight:achievementViewHeight cardBackImageStr:@"0" achivementDiscription:@"Same Kind King"];
            [self.achivementArray addObject:achivementView];
            [self.gameCenterManager submitAchievement:kAchievementSameKind percentComplete:100.0];
            [defaults setInteger:1 forKey:kIsGotSameKind];
        }
    }
    
    // 红桃杀手，黑桃杀手，方片杀手，草花杀手
    NSInteger isClubKiller = [defaults integerForKey:kIsClubKiller];
    NSInteger isDiamondKiller = [defaults integerForKey:kIsDiamondKiller];
    NSInteger isHeartKiller = [defaults integerForKey:kIsHeartKiller];
    NSInteger isSpadeKiller = [defaults integerForKey:kIsSpadeKiller];
    NSInteger isJokerKiller = [defaults integerForKey:kIsJokerKiller];
    if (self.hasWon == YES) {
        if (isClubKiller == 0 && self.erasedClubNumber == 13) {
            AchivementView *achivementView = [AchivementView achivementWithPosition:CGPointZero sideWidth:achievementViewWidth sideHeight:achievementViewHeight cardBackImageStr:@"1" achivementDiscription:@"Club Killer"];
            [self.achivementArray addObject:achivementView];
            [self.gameCenterManager submitAchievement:kAchievementClubKiller percentComplete:100.0];
            [defaults setInteger:1 forKey:kIsClubKiller];
        }
        
        if (isHeartKiller == 0 && self.erasedHeartNumber == 13) {
            AchivementView *achivementView = [AchivementView achivementWithPosition:CGPointZero sideWidth:achievementViewWidth sideHeight:achievementViewHeight cardBackImageStr:@"2" achivementDiscription:@"Heart Killer"];
            [self.achivementArray addObject:achivementView];
            [self.gameCenterManager submitAchievement:kAchievementHeartKiller percentComplete:100.0];
            [defaults setInteger:1 forKey:kIsHeartKiller];
        }
        
        if (isSpadeKiller == 0 && self.erasedSpadeNumber == 13) {
            AchivementView *achivementView = [AchivementView achivementWithPosition:CGPointZero sideWidth:achievementViewWidth sideHeight:achievementViewHeight cardBackImageStr:@"3" achivementDiscription:@"Spade Killer"];
            [self.achivementArray addObject:achivementView];
            [self.gameCenterManager submitAchievement:kAchievementSpadeKiller percentComplete:100.0];
            [defaults setInteger:1 forKey:kIsSpadeKiller];
        }
        
        if (isDiamondKiller == 0 && self.erasedDiamondNumber == 13) {
            AchivementView *achivementView = [AchivementView achivementWithPosition:CGPointZero sideWidth:achievementViewWidth sideHeight:achievementViewHeight cardBackImageStr:@"4" achivementDiscription:@"Diamond Killer"];
            [self.achivementArray addObject:achivementView];
            [self.gameCenterManager submitAchievement:kAchievementDiamondKiller percentComplete:100.0];
            [defaults setInteger:1 forKey:kIsDiamondKiller];
        }
        
        if (isJokerKiller == 0 && self.erasedJokerNumber == 2) {
            AchivementView *achivementView = [AchivementView achivementWithPosition:CGPointZero sideWidth:achievementViewWidth sideHeight:achievementViewHeight cardBackImageStr:@"5" achivementDiscription:@"Joker Killer"];
            [self.achivementArray addObject:achivementView];
            [self.gameCenterManager submitAchievement:kAchievementJokerKiller percentComplete:100.0];
            [defaults setInteger:1 forKey:kIsJokerKiller];
        }
    }
    
    // 弹出成就
    if ([self.achivementArray count]) {
        AchivementView *achivementView = [self.achivementArray firstObject];
        [self presentPopUpView:achivementView];
        [self.achivementArray removeObjectAtIndex:0];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // 微信分享
    self.activity = @[[[WeixinSessionActivity alloc] init], [[WeixinTimelineActivity alloc] init]];
    [self setup];
}

#pragma mark - Public Methods
- (void)presentPopUpViewController:(UIViewController *)popupViewController
{
    [self presentPopUpView:popupViewController.view];
}

- (void)dismissPopUpViewController
{
    [self dismissingAnimation];
}

#pragma mark - View Handling
- (void)presentPopUpView:(UIView *)popUpView
{
    UIView *sourceView = [self topView];
    
    // Check if source view controller is not in destination
    if ([sourceView.subviews containsObject:popUpView]) return;
    
    // Add overlay
    UIView *overlayView = [[UIView alloc] initWithFrame:sourceView.bounds];
    overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    overlayView.tag = kENPopUpOverlayViewTag;
    overlayView.backgroundColor = [UIColor clearColor];
    
    // Add Blured View
    JWBlurView *bluredView = [[JWBlurView alloc] initWithFrame:self.view.bounds];
    bluredView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    bluredView.tag = kENPopUpBluredViewTag;
    [bluredView setBlurAlpha:.0f];
    [bluredView setAlpha:.0f];
    [bluredView setBlurColor:[UIColor clearColor]];
    bluredView.backgroundColor = [UIColor clearColor];
    [overlayView addSubview:bluredView];
    
    // Make the background clickable
    UIButton * dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
    dismissButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    dismissButton.backgroundColor = [UIColor clearColor];
    dismissButton.frame = sourceView.bounds;
    [overlayView addSubview:dismissButton];
    
    [dismissButton addTarget:self action:@selector(dismissPopUpViewController)
            forControlEvents:UIControlEventTouchUpInside];
    
    // Customize popUpView
    popUpView.layer.cornerRadius = 3.5f;
    popUpView.layer.masksToBounds = YES;
    popUpView.layer.zPosition = 99;
    popUpView.tag = kENPopUpViewTag;
    popUpView.center = overlayView.center;
    [popUpView setNeedsLayout];
    [popUpView setNeedsDisplay];
    
    [overlayView addSubview:popUpView];
    [sourceView addSubview:overlayView];
    
    [self setAnimationStateFrom:popUpView];
    [self appearingAnimation];
}


#pragma mark - Animation
- (void)setAnimationStateFrom:(UIView *)view
{
    CALayer *layer = view.layer;
    layer.transform = [self transform3d];
}

- (CATransform3D)transform3d
{
    CATransform3D transform = CATransform3DIdentity;
    transform = CATransform3DTranslate(transform, 0, 200.f, 0);
    transform.m34 = 1.0/800.0;
    transform = CATransform3DRotate(transform, kRotationAngle*M_PI/180.f, 1.f, .0f, .0f);
    CATransform3D scale = CATransform3DMakeScale(.7f, .7f, .7f);
    return CATransform3DConcat(transform, scale);
}

- (void)appearingAnimation
{
    
    CATransform3D transform;
    transform = CATransform3DIdentity;
    [UIView animateWithDuration:kAnimationDuration
                     animations:^ {
                         [[self bluredView] setAlpha:1.f];
                         [self popUpView].layer.transform   = transform;
                     }
                     completion:nil];
}


- (void)dismissingAnimation
{
    CATransform3D transform = [self transform3d];
    [UIView animateWithDuration:kAnimationDuration
                     animations:^ {
                         [[self bluredView] setAlpha:0.f];
                         [self popUpView].layer.transform   = transform;
                     }
                     completion:^(BOOL finished) {
                         [[self popUpView] removeFromSuperview];
                         [[self bluredView]  removeFromSuperview];
                         [[self overlayView]  removeFromSuperview];
                         
                         if ([self.achivementArray count]) {
                             AchivementView *achivementView = [self.achivementArray firstObject];
                             [self presentPopUpView:achivementView];
                             [self.achivementArray removeObjectAtIndex:0];
                         }
                     }];
}

#pragma mark - Getters
- (UIView *)popUpView
{
    return [self.view viewWithTag:kENPopUpViewTag];
}

- (UIView *)overlayView
{
    return [self.view viewWithTag:kENPopUpOverlayViewTag];
}

- (JWBlurView *)bluredView
{
    return (JWBlurView *)[self.view viewWithTag:kENPopUpBluredViewTag];
}

- (GameCenterManager *)gameCenterManager
{
    if ([GameCenterManager isGameCenterAvailable]) {
        if (_gameCenterManager == nil) {
            _gameCenterManager = [[GameCenterManager alloc] init];
        }
        return _gameCenterManager;
    } else {
        return nil;
    }
}

- (UIView*)topView {
    UIViewController *recentView = self;
    while (recentView.parentViewController != nil) {
        recentView = recentView.parentViewController;
    }
    return recentView.view;
}


@end
