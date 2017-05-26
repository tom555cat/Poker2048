//
//  ResultViewController.h
//  Tlm2048_1
//
//  Created by tom555cat on 15/12/22.
//  Copyright © 2015年 tom555cat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameCenterManager.h"
#import <GameKit/GameKit.h>

@class GameCenterManager;


// 成就key
extern NSString * const AchivementTestKey;  // 测试成就Key

@interface ResultViewController : UIViewController <GameCenterManagerDelegate, GKGameCenterControllerDelegate>

@property (nonatomic) BOOL hasWon;
@property (nonatomic) NSInteger score;
@property (nonatomic) NSInteger leftPokerNumber;
@property (nonatomic) NSInteger moveNumber;
@property (nonatomic) BOOL isFlush;
@property (nonatomic) BOOL isStraight;
@property (nonatomic) BOOL isSameKind;
@property (nonatomic) NSInteger erasedDiamondNumber;
@property (nonatomic) NSInteger erasedClubNumber;
@property (nonatomic) NSInteger erasedSpadeNumber;
@property (nonatomic) NSInteger erasedHeartNumber;
@property (nonatomic) NSInteger erasedJokerNumber;
@property (nonatomic, strong) GameCenterManager *gameCenterManager;


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
             erasedJokerNumber:(NSInteger)erasedJokerNumber;


- (void)presentPopUpViewController:(UIViewController *)popupViewController;
- (void)dismissPopUpViewController;
@end
