//
//  GameCenterManager.h
//  GameCenterTest
//
//  Created by tom555cat on 16/2/9.
//  Copyright © 2016年 tom555cat. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GKLeaderboard, GKAchievement, GKPlayer;

@protocol GameCenterManagerDelegate <NSObject>
@optional
- (void) processGameCenterAuth: (NSError*) error;
- (void) scoreReported: (NSError*) error;
- (void) reloadScoresComplete: (GKLeaderboard*) leaderBoard error: (NSError*) error;
- (void) achievementSubmitted: (GKAchievement*) ach error:(NSError*) error;
- (void) achievementResetResult: (NSError*) error;
- (void) mappedPlayerIDToPlayer: (GKPlayer*) player error: (NSError*) error;
@end

@interface GameCenterManager : NSObject

@property (strong, atomic) NSMutableDictionary *earnedAchievementCache;
@property (nonatomic) id <GameCenterManagerDelegate> delegate;

+ (BOOL)isGameCenterAvailable;
- (void)authenticateLocalUser;

- (void)reportScore:(int64_t)score forCategory:(NSString *)category;
- (void)reloadHighScoresForCategory:(NSString *)category;

- (void)submitAchievement:(NSString *)identifier percentComplete:(double)percentComplete;
- (void)resetAchievements;

- (void)mapPlayerIDtoPlayer:(NSString *)playerID;
@end
