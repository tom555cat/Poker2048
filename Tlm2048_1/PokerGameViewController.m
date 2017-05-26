//
//  FinalPokerGameViewController.m
//  Tlm2048_1
//
//  Created by tom555cat on 15/12/1.
//  Copyright © 2015年 tom555cat. All rights reserved.
//

#import "PokerGameViewController.h"
#import "PokerGameBoardView.h"
#import "PokerGameManager.h"
#import "CardBackScrollViewController.h"
#import "HelpViewController.h"
#import "ResultViewController.h"
#import "MyUIButton.h"
#import "PokerView.h"
#import "CardBackView.h"
#import "AppSpecificValues.h"
#import "DirectView.h"
#import "DirectViewController.h"
#import "PokerGameConstants.h"

@interface PokerGameViewController () <PokerGameDelegate, ChooseCardBackDelegate>

@property (strong, nonatomic) PokerGameBoardView *gameboard;
@property (strong, nonatomic) PokerGameManager *manager;
@property (strong, nonatomic) UILabel *leftCardLabel;
@property (weak, nonatomic) UILabel *scoreLabel;
@property (strong, nonatomic) UIView *sideBar;
@property (strong, nonatomic) MyUIButton *achivementBtn;
@property (strong, nonatomic) UIView *achivementBtnImageView;
@property (strong, nonatomic) UIButton *leftCardNumBtn;
@property (strong, nonatomic) CardBackView *cardImageView;
@property (strong, nonatomic) MyUIButton *recycleBin;
@property (nonatomic) CGFloat cellWidth;
@property (nonatomic) CGFloat cellHeight;
@property (nonatomic) CGFloat padding;
@property (nonatomic) NSInteger moveNumber;
@property (nonatomic) BOOL isStraight;
@property (nonatomic) BOOL isFlush;
@property (nonatomic) BOOL isSameKind;

@property (strong, nonatomic) GameCenterManager *gameCenterManager;
@property (nonatomic) NSInteger erasedDiamondNumber;
@property (nonatomic) NSInteger erasedClubNumber;
@property (nonatomic) NSInteger erasedSpadeNumber;
@property (nonatomic) NSInteger erasedHeartNumber;
@property (nonatomic) NSInteger erasedJokerNumber;

@end

@implementation PokerGameViewController

#pragma mark - create game board

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialize values
    [self initializeValues];
    [self authenticateUser];
    [self setupSwipeControls];
    [self setupGame];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.gameboard.trashFrame = CGRectMake(self.sideBar.frame.origin.x+self.recycleBin.frame.origin.x, self.sideBar.frame.origin.y+self.recycleBin.frame.origin.y, self.sideBar.frame.size.width, self.sideBar.frame.size.height);
    
    // 弹出指引页面
    [self directGame];
    
    // 检查整个面板是否有subview poker残留
    for (UIView *subview in self.gameboard.subviews) {
        if ([subview isMemberOfClass:[PokerView class]]) {
            NSLog(@"There is a Poker View!");
            //[subview removeFromSuperview];
        }
    }
}

- (void)initializeValues
{
    self.moveNumber = 0;
    self.isStraight = NO;
    self.isFlush = NO;
    self.isSameKind = NO;
    
    self.erasedClubNumber = 0;
    self.erasedDiamondNumber = 0;
    self.erasedHeartNumber = 0;
    self.erasedSpadeNumber = 0;
    self.erasedJokerNumber = 0;
}

- (void)authenticateUser
{
    if ([GameCenterManager isGameCenterAvailable]) {
        self.gameCenterManager = [[GameCenterManager alloc] init];
        //[self.gameCenterManager setDelegate:self];
        [self.gameCenterManager authenticateLocalUser];
    } else {
        // THe current device does not support Game Center
    }
}

static const NSInteger dimension = 4;
static const NSInteger threshold = 52;
static const NSInteger defaultCardBack = -1;

- (void)setupGame
{
    CGFloat padding = (dimension > 5) ? 10.0 : 4.0;
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    CGFloat boardHeight = [[UIScreen mainScreen] bounds].size.height*0.65f;
    CGFloat boardWidth = boardHeight * 3.0 / 5.0;
    CGFloat cellWidth = (boardWidth - padding*(dimension+1))/((float)dimension);
    CGFloat cellHeight = (boardHeight - padding*(dimension+1))/((float)dimension);
    
    self.cellWidth = cellWidth;
    self.cellHeight = cellHeight;
    self.padding = padding;
    
    PokerGameBoardView *gameboard = [PokerGameBoardView gameboardWithDimension:dimension
                                                                           cellWidth:cellWidth
                                                                          cellHeight:cellHeight
                                                                         cellPadding:padding
                                                                        cornerRadius:3
                                                                     backgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5f]
                                                                     foregroundColor:[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.5f]];
    
    
    CGRect gameboardFrame = gameboard.frame;
    gameboardFrame.origin.x = 0.5f*([[UIScreen mainScreen] bounds].size.width - gameboardFrame.size.width);
    gameboardFrame.origin.y = 0.5f*((5.0f/6.0f)*[[UIScreen mainScreen] bounds].size.height - gameboardFrame.size.height) + 0.25f*((5.0f/6.0f)*[[UIScreen mainScreen] bounds].size.height - gameboardFrame.size.height);
    gameboard.frame = gameboardFrame;
    gameboard.cardBackImageStr = [NSString stringWithFormat:@"%ld", (long)defaultCardBack];
    gameboard.parentViewController = self;
    [self.view addSubview:gameboard];
    self.gameboard = gameboard;
    
    // 剩余卡牌标签
    // .......卡牌标志
    //CGFloat cardImageViewWidth = screenWidth*0.08f;
    //CGFloat cardImageViewHeight = cardImageViewWidth*5.0f/3.0f;
    CGFloat cardImageViewHeight = screenHeight*0.08f;
    CGFloat cardImageViewWidth = cardImageViewHeight*0.6f;
    CGFloat padding1 = screenWidth*0.01f;
    CardBackView *leftCardView = [CardBackView cardBackPosition:CGPointMake(screenWidth/2.0f-padding1-cardImageViewWidth, gameboardFrame.origin.y - cardImageViewHeight - 10) sideWidth:cardImageViewWidth sideHeight:cardImageViewHeight cornerRadius:3];
    leftCardView.imageNameStr = @"-12";
    self.cardImageView = leftCardView;
    [self.view addSubview:self.cardImageView];
    
    // .......剩余卡牌数量标签
    UIButton *leftCardNumBtn = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth/2.0f+padding1, gameboardFrame.origin.y*2.0f/3.0f-cardImageViewHeight/2.0f, cardImageViewWidth, cardImageViewHeight)];
    
    self.leftCardNumBtn = leftCardNumBtn;
    [self.view addSubview:self.leftCardNumBtn];
    
    // 设置背景纹理图样
    UIImage *backgroundImage = [UIImage imageNamed:@"-12"];
    self.view.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
    
    // 工具bar
    CGFloat sideBarWidth = screenWidth;
    CGFloat sideBarHeight = screenHeight/6.0f;
    UIView *sideBar = [[UIView alloc] initWithFrame:CGRectMake(0, screenHeight-sideBarHeight, sideBarWidth, sideBarHeight)];
    sideBar.backgroundColor = [UIColor grayColor];
    self.sideBar = sideBar;
    [self.view addSubview:self.sideBar];
    
    // 工具bar装饰条
    CGFloat decorateViewWidth = screenWidth;
    CGFloat decorateViewHeight = 5.0f;
    UIView *decorateView = [[UIView alloc] initWithFrame:CGRectMake(0, screenHeight-sideBarHeight-decorateViewHeight, decorateViewWidth, decorateViewHeight)];
    decorateView.backgroundColor = [UIColor colorWithRed:0.3f green:0.3f blue:0.3f alpha:0.5f];
    [self.view addSubview:decorateView];
    
    // sideBar区域
    // 中间5/6区域用来放置5个按钮
    // 计算5个放置按钮的区域空间大小
    CGFloat ration = 5.0f/6.0f;
    CGFloat areaWidthForBtn = screenWidth*ration/5.0f;
    CGFloat btnPadding = areaWidthForBtn/12.0f;    // 在每个区域中，卡牌左右的空白区域
    NSString *deviceType = [UIDevice currentDevice].model;
    CGFloat btnHeight = 0.0;
    CGFloat btnWidth = 0.0;
    if ([deviceType isEqualToString:@"iPhone"]) {
        btnHeight = self.sideBar.frame.size.height*0.8f;
        btnWidth = btnHeight*0.6f;
    } else {
        btnPadding = areaWidthForBtn/7.0f;
        btnWidth = areaWidthForBtn-2.0f*btnPadding;
        btnHeight = btnWidth*5.0f/3.0f;
    }
    
    CGFloat btnTop = screenHeight/12.0f-btnHeight/2.0f;
    
    // 成就按钮
    MyUIButton *achivementBtn = [[MyUIButton alloc] initWithFrame:CGRectMake((1.0f-ration)*0.5f*screenWidth+btnPadding,  btnTop, btnWidth, btnHeight)];
    UITapGestureRecognizer *achivementTapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeCardBack:)];
    [achivementBtn addGestureRecognizer:achivementTapGR];
    CGFloat borderPadding = btnWidth/10.0f;
    UIView *cardBackImageView = [[UIView alloc] initWithFrame:CGRectMake(borderPadding, borderPadding, btnWidth-2.0f*borderPadding, btnHeight-2.0f*borderPadding)];
    cardBackImageView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"-12q"]];
    [achivementBtn addSubview:cardBackImageView];
    self.achivementBtnImageView = cardBackImageView;
    self.achivementBtn = achivementBtn;
    [self.sideBar addSubview:self.achivementBtn];
    
    // 得分按钮
    MyUIButton *scoreBtn = [[MyUIButton alloc] initWithFrame:CGRectMake((1.0f-ration)*0.5f*screenWidth+areaWidthForBtn+btnPadding, btnTop, btnWidth, btnHeight)];
    UILabel *scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, btnWidth, btnHeight)];
    scoreLabel.numberOfLines = 0;
    self.scoreLabel = scoreLabel;
    [scoreBtn addSubview:self.scoreLabel];
    [self.sideBar addSubview:scoreBtn];
    
    // 游戏排名按钮
    MyUIButton *gameCenterBtn = [[MyUIButton alloc] initWithFrame:CGRectMake((1.0f-ration)*0.5f*screenWidth+areaWidthForBtn*2+btnPadding, btnTop, btnWidth, btnHeight)];
    UITapGestureRecognizer *gameCenterTapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gameCenterView:)];
    [gameCenterBtn addGestureRecognizer:gameCenterTapGR];
    CGFloat gameCenterImageViewWidth = btnWidth*0.8f;
    CGFloat gameCenterImageViewHeight = gameCenterImageViewWidth;
    UIImageView *gameCenterImageView = [[UIImageView alloc] initWithFrame:CGRectMake(btnWidth/2.0f-gameCenterImageViewWidth/2.0f, btnHeight/2.0f-gameCenterImageViewHeight/2.0f, gameCenterImageViewWidth, gameCenterImageViewHeight)];
    gameCenterImageView.image = [UIImage imageNamed:@"gamecenter"];
    [gameCenterBtn addSubview:gameCenterImageView];
    [self.sideBar addSubview:gameCenterBtn];
    
    // 帮助按钮
    MyUIButton *gameHelpBtn = [[MyUIButton alloc] initWithFrame:CGRectMake((1.0f-ration)*0.5f*screenWidth+areaWidthForBtn*3+btnPadding, btnTop, btnWidth, btnHeight)];
    UITapGestureRecognizer *helpTapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showHelpView:)];
    [gameHelpBtn addGestureRecognizer:helpTapGR];
    CGFloat questionImageViewWidth = btnWidth*0.8f;
    CGFloat questionImageViewHeight = questionImageViewWidth;
    UIImageView *questionImageView = [[UIImageView alloc] initWithFrame:CGRectMake(btnWidth/2.0f-questionImageViewWidth/2.0f, btnHeight/2.0f-questionImageViewHeight/2.0f, questionImageViewWidth, questionImageViewHeight)];
    questionImageView.image = [UIImage imageNamed:@"help"];
    [gameHelpBtn addSubview:questionImageView];
    [self.sideBar addSubview:gameHelpBtn];
    
    // 垃圾箱按钮
    MyUIButton *recycleBtn = [[MyUIButton alloc] initWithFrame:CGRectMake((1.0f-ration)*0.5f*screenWidth+areaWidthForBtn*4+btnPadding, btnTop, btnWidth, btnHeight)];
    CGFloat recycleImageViewWidth = btnWidth*0.7f;
    CGFloat recycleImageViewHeight = recycleImageViewWidth*127.0f/112.0f;
    UIImageView *recycleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(btnWidth/2.0f-recycleImageViewWidth/2.0f, btnHeight/2.0f-recycleImageViewHeight/2.0f, recycleImageViewWidth, recycleImageViewHeight)];
    recycleImageView.image = [UIImage imageNamed:@"trash"];
    self.recycleBin = recycleBtn;
    [recycleBtn addSubview:recycleImageView];
    [self.sideBar addSubview:recycleBtn];
    
    // 创建Manager
    self.manager = [[PokerGameManager alloc] initWithDimension:dimension winValue:threshold delegate:(id<PokerGameDelegate>)self];
    
    // 随机插入两张牌
    for (NSInteger i = 0; i < 2; i++) {
        NSMutableArray *poker = [self pokerRandom:self.manager.library];
        if (!poker) {
            return;
        }
        NSInteger color = [[poker objectAtIndex:0] integerValue];
        NSInteger number = [[poker objectAtIndex:1] integerValue];
        __weak __typeof(self)wself = self;
        [self.manager insertAtRandomLocationPokerWithColor:(int)color number:(int)number completion: ^{
            [wself.manager.library removeObject:poker];
        }];
        
    }
}

- (void)directGame
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSInteger isFirstStart = [defaults integerForKey:kIsFirstStart];
    if (isFirstStart == 0) {
        // 弹出指引页面
        DirectView *s = [[DirectView alloc] init];
        [s show];
        [defaults setInteger:1 forKey:kIsFirstStart];
    }
}

- (NSMutableArray *)pokerRandom:(NSMutableArray*)libary
{
    NSInteger libraryNumber = [libary count];
    if (libraryNumber <= 0) {
        return nil;
    }
    NSInteger value = arc4random() % libraryNumber;
    return [libary objectAtIndex:value];
}

- (void)gameCenterView:(id)sender
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

- (void)changeCardBack:(id)sender
{
    CardBackScrollViewController *cardBackScrollViewController = [[CardBackScrollViewController alloc] init];
    cardBackScrollViewController.delegate = self;
    [self presentViewController:cardBackScrollViewController animated:YES completion:^{cardBackScrollViewController.pokerGameViewController = self;}];
}

- (void)showHelpView:(id)sender
{
    HelpViewController *helpViewController = [[HelpViewController alloc] init];
    [self presentViewController:helpViewController animated:YES completion:nil];
}

- (NSInteger)checkLeftPokerNumber
{
    NSInteger leftNumber = [[self.gameboard subviews] count] - 16;
    return leftNumber;
}

- (void)resetGame
{
    [self initializeValues];
    [self.gameboard reset];
    [self.manager reset];
    
    // 重新随机放入两张牌
    for (NSInteger i = 0; i < 2; i++) {
        NSMutableArray *poker = [self pokerRandom:self.manager.library];
        if (!poker) {
            return;
        }
        NSInteger color = [[poker objectAtIndex:0] integerValue];
        NSInteger number = [[poker objectAtIndex:1] integerValue];
        __weak __typeof(self)wself = self;
        [self.manager insertAtRandomLocationPokerWithColor:(int)color number:(int)number completion:^{
            if (!wself) return;
            __strong PokerGameViewController *sself = wself;
            [sself.manager.library removeObject:poker];
        }];
    }
}

- (void)setupSwipeControls
{
    UISwipeGestureRecognizer *upSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                  action:@selector(upButtonTapped)];
    upSwipe.numberOfTouchesRequired = 1;
    upSwipe.direction = UISwipeGestureRecognizerDirectionUp;
    [self.view addGestureRecognizer:upSwipe];
    
    UISwipeGestureRecognizer *downSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(downButtonTapped)];
    downSwipe.numberOfTouchesRequired = 1;
    downSwipe.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:downSwipe];
    
    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(leftButtonTapped)];
    leftSwipe.numberOfTouchesRequired = 1;
    leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:leftSwipe];
    
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(rightButtonTapped)];
    rightSwipe.numberOfTouchesRequired = 1;
    rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:rightSwipe];
}

#pragma mark - Initial

- (void)setCardBackImageStr:(NSString *)cardBackImageStr
{
    // 更改成就按钮的卡背
    _cardBackImageStr = cardBackImageStr;
    
    
    NSString *deviceType = [UIDevice currentDevice].model;
    if ([deviceType isEqualToString:@"iPhone"]) {
        self.achivementBtnImageView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@q", cardBackImageStr]]];
    } else {
        self.achivementBtnImageView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@", cardBackImageStr]]];
    }
    
    
    
    // 更改剩余卡牌部分的卡背
    self.cardImageView.imageNameStr = cardBackImageStr;
    
    // 更改gameboard的卡背
    self.gameboard.cardBackImageStr = _cardBackImageStr;
}

#pragma mark - Control View Protocol

- (void)upButtonTapped
{
    self.moveNumber++;
    [self.manager performMoveInDirection:MoveDirectionUp completionBlock:^(BOOL changed) {
        if (changed)
            [self followUp];
    }];
}

- (void)downButtonTapped {
    self.moveNumber++;
    [self.manager performMoveInDirection:MoveDirectionDown completionBlock:^(BOOL changed) {
        if (changed) [self followUp];
    }];
}

- (void)leftButtonTapped {
    self.moveNumber++;
    [self.manager performMoveInDirection:MoveDirectionLeft completionBlock:^(BOOL changed) {
        if (changed) [self followUp];
    }];
}

- (void)rightButtonTapped {
    self.moveNumber++;
    [self.manager performMoveInDirection:MoveDirectionRight completionBlock:^(BOOL changed) {
        if (changed) [self followUp];
    }];
}

- (void)followUp
{
    // This is the earlist point the user can win
    if ([self.manager userHasWon]) {
        [self.delegate gameFinishedWithVictory:YES score:self.manager.score];
        
        ResultViewController *resultVC = [ResultViewController initWithHasWon:YES
                                                                        score:self.manager.score
                                                              leftPokerNumber:[self checkLeftPokerNumber]
                                                                   moveNumber:self.moveNumber
                                                                      isFlush:self.isFlush
                                                                   isStraight:self.isStraight
                                                                   isSameKind:self.isSameKind
                                                          erasedDiamondNumber:self.erasedDiamondNumber
                                                             erasedClubNumber:self.erasedClubNumber
                                                            erasedSpadeNumber:self.erasedSpadeNumber
                                                            erasedHeartNumber:self.erasedHeartNumber
                                                            erasedJokerNumber:self.erasedJokerNumber];
        
        
        // 重置游戏
        [self resetGame];
        [self presentViewController:resultVC animated:YES completion:nil];
    } else {
        // 插入一张牌
        NSMutableArray *poker = [self pokerRandom:self.manager.library];
        if (!poker) {
            return;
        }
        NSInteger color = [[poker objectAtIndex:0] integerValue];
        NSInteger number = [[poker objectAtIndex:1] integerValue];
        
        __weak __typeof(self)wself = self;
        [self.manager insertAtRandomLocationPokerWithColor:(int)color number:(int)number completion: ^{
            __strong PokerGameViewController *sself = wself;
            [sself.manager.library removeObject:poker];
            // At this point, the user may lose
            if ([sself.manager userHasLost]) {
                [sself.delegate gameFinishedWithVictory:NO score:self.manager.score];
                ResultViewController *resultVC = [ResultViewController initWithHasWon:NO
                                                                                score:self.manager.score
                                                                      leftPokerNumber:[self checkLeftPokerNumber]
                                                                           moveNumber:self.moveNumber
                                                                              isFlush:self.isFlush
                                                                           isStraight:self.isStraight
                                                                           isSameKind:self.isSameKind
                                                                  erasedDiamondNumber:self.erasedDiamondNumber
                                                                     erasedClubNumber:self.erasedClubNumber
                                                                    erasedSpadeNumber:self.erasedSpadeNumber
                                                                    erasedHeartNumber:self.erasedHeartNumber
                                                                    erasedJokerNumber:self.erasedJokerNumber];
                
                // 重置游戏
                [sself resetGame];
                [sself presentViewController:resultVC animated:YES completion:nil];
            }
        }];
        
    }
}

#pragma mark - ChangeCardBackDelegate

- (void)changeBackgroundWithTag:(NSInteger)tag {
    NSString *backgoundImageStr = [NSString stringWithFormat:@"%ld", (long)tag];
    UIImage *backgroundImage = [UIImage imageNamed:backgoundImageStr];
    self.view.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
    self.cardBackImageStr = [NSString stringWithFormat:@"%ld", (long)tag];
}

#pragma mark - Model Protocol

- (void)movePokerFromIndexPath:(NSIndexPath *)fromPath toIndexPath:(NSIndexPath *)toPath
{
    [self.gameboard movePokerFromIndexPath:fromPath toIndexPath:toPath ];
}

- (void)movePokerFromIndexPath:(NSIndexPath *)fromPath
                   toIndexPath:(NSIndexPath *)toPath
                         delay:(CGFloat)delay
{
    [self.gameboard movePokerFromIndexPath:fromPath toIndexPath:toPath delay:delay];
}


- (void)erasePokers:(NSMutableArray *)pathArray
{
    
    if ([pathArray count] == 4) {
        PokerView *pokerView0 = self.gameboard.boardPokers[pathArray[0]];
        PokerView *pokerView1 = self.gameboard.boardPokers[pathArray[1]];
        PokerView *pokerView2 = self.gameboard.boardPokers[pathArray[2]];
        PokerView *pokerView3 = self.gameboard.boardPokers[pathArray[3]];
        
        if (pokerView0.tilePokerNumber == pokerView1.tilePokerNumber &&
            pokerView2.tilePokerNumber == pokerView3.tilePokerNumber &&
            pokerView0.tilePokerNumber == pokerView2.tilePokerNumber) {
            self.isSameKind = YES;
        }
        
        if (pokerView0.tilePokerColor == pokerView1.tilePokerColor &&
            pokerView2.tilePokerColor == pokerView3.tilePokerColor &&
            pokerView0.tilePokerColor == pokerView2.tilePokerColor) {
            self.isFlush = YES;
        }
        
        if ((pokerView0.tilePokerNumber-pokerView1.tilePokerNumber == pokerView1.tilePokerNumber-pokerView2.tilePokerNumber) &&
            (pokerView1.tilePokerNumber-pokerView2.tilePokerNumber == pokerView2.tilePokerNumber-pokerView3.tilePokerNumber)) {
            self.isStraight = YES;
        }
    }
    
    for (NSIndexPath *path in pathArray) {
        PokerView *pokerView = self.gameboard.boardPokers[path];
        switch (pokerView.tilePokerColor) {
            case PokerColorClub:
                self.erasedClubNumber++;
                break;
            
            case PokerColorDiamond:
                self.erasedDiamondNumber++;
                break;
                
            case PokerColorHeart:
                self.erasedHeartNumber++;
                break;
                
            case PokerColorSpade:
                self.erasedSpadeNumber++;
                break;
                
            case PokerColorJoker:
                self.erasedJokerNumber++;
                break;
                
            default:
                break;
        }
    }
    
    [self.gameboard erasePokers:pathArray];
}

- (void)insertPokerAtIndexPath:(NSIndexPath *)path
                         color:(NSInteger)color
                        number:(NSInteger)number
                    completion:(void(^)())completion
{
    [self.gameboard insertPokerAtIndexPath:path color:color number:number completion:completion];
}

- (void)insertPokerAtIndexPath:(NSIndexPath *)path
                         color:(NSInteger)color
                        number:(NSInteger)number
                         delay:(CGFloat)delay
                    completion:(void(^)())completion
{
    [self.gameboard insertPokerAtIndexPath:path color:color number:number delay:delay completion:completion];
}

- (void)scoreChanged:(NSInteger)newScore
{
    //self.scoreView.score = newScore;
    CGFloat fontSize = self.view.frame.size.height*25.0f/667.0f;
    NSString *scoreString = [NSString stringWithFormat:@"⭐️\n%ld", (long)newScore];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:scoreString];
    //[attributeString addAttributes:@{NSParagraphStyleAttributeName:paragraphStyle, NSFontAttributeName:[UIFont fontWithName:@"Verdana-Bold" size:10]} range:NSMakeRange(0, 2)];
    [attributeString addAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor], NSFontAttributeName:[UIFont fontWithName:@"Verdana-Bold" size:fontSize], NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, [scoreString length])];
    self.scoreLabel.attributedText = attributeString;
    //self.scoreLabel.text = [NSString stringWithFormat:@"⭐️\n %d", newScore];
}

- (void)leftCardsChanged:(NSInteger)newCardsNum
{
    CGFloat fontSize = self.view.frame.size.height*20.0f/667.0f;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld", (long)newCardsNum] attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSStrokeColorAttributeName:[UIColor blackColor],NSStrokeWidthAttributeName:[NSNumber numberWithFloat:-8.0],NSFontAttributeName:[UIFont fontWithName:@"Verdana-Bold" size:fontSize], NSParagraphStyleAttributeName:paragraphStyle}];
    //self.leftCardLabel.attributedText = attributeString;
    [self.leftCardNumBtn setAttributedTitle:attributeString forState:UIControlStateNormal];
}

@end
