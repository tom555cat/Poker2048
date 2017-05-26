//
//  GameCenterManager.m
//  GameCenterTest
//
//  Created by tom555cat on 16/2/9.
//  Copyright © 2016年 tom555cat. All rights reserved.
//

#import "GameCenterManager.h"
#import <GameKit/GameKit.h>

@implementation GameCenterManager

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

- (id)init
{
    self = [super init];
    if (self != nil) {
        self.earnedAchievementCache = nil;
    }
    return self;
}

- (void)callDelegate:(SEL)selector withArg:(id)arg error:(NSError*)err
{
    assert([NSThread isMainThread]);
    if ([self.delegate respondsToSelector:selector]) {
        if (arg != NULL) {
            SuppressPerformSelectorLeakWarning(
                [self.delegate performSelector:selector withObject:arg withObject:err];
            );
        } else {
            SuppressPerformSelectorLeakWarning(
                [self.delegate performSelector:selector withObject:err];
            );
        }
    } else {
        NSLog(@"Missed Method");
    }
}

- (void)callDelegateOnMainThread:(SEL)selector withArg:(id)arg error:(NSError *)err
{
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [self callDelegate:selector withArg:arg error:err];
    });
}

+ (BOOL)isGameCenterAvailable
{
    // check for presence of GKLocalPlayer API
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
    
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);

    return (gcClass && osVersionSupported);
}

- (void)authenticateLocalUser
{
    if ([GKLocalPlayer localPlayer].authenticated == NO) {
        GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
        localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error){
            [self callDelegateOnMainThread:@selector(processGameCenterAuth:) withArg:NULL error:error];
        };
        /*
        [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:^(NSError * _Nullable error) {
            [self callDelegateOnMainThread:@selector(processGameCenterAuth:) withArg:NULL error:error];
        }];
         */
    }
}

- (void)reloadHighScoresForCategory:(NSString *)category
{
    GKLeaderboard *leaderBoard = [[GKLeaderboard alloc] init];
    //leaderBoard.category = category;
    leaderBoard.identifier = category;      // 3.12修改
    leaderBoard.timeScope = GKLeaderboardTimeScopeAllTime;
    leaderBoard.range = NSMakeRange(1, 1);
    
    [leaderBoard loadScoresWithCompletionHandler:^(NSArray *scores, NSError *error){
        [self callDelegateOnMainThread:@selector(reloadScoresComplete:error:) withArg:leaderBoard error:error];
    }];
}

- (void)reportScore:(int64_t)score forCategory:(NSString *)category
{
    //GKScore *scoreReporter = [[GKScore alloc] initWithCategory:category];
    GKScore *scoreReporter = [[GKScore alloc] initWithLeaderboardIdentifier:category];
    scoreReporter.value = score;
    scoreReporter.context = 0;
    
    NSArray *scores = @[scoreReporter];
    [GKScore reportScores:scores withCompletionHandler:^(NSError * _Nullable error) {
        [self callDelegateOnMainThread:@selector(scoreReported:) withArg:NULL error:error];
    }];
    
    /*
    [scoreReporter reportScoreWithCompletionHandler:^(NSError *error){
        [self callDelegateOnMainThread:@selector(scoreReported:) withArg:NULL error:error];
    }];
     */
}

- (void)submitAchievement:(NSString *)identifier percentComplete:(double)percentComplete
{
    if (self.earnedAchievementCache == NULL) {
        [GKAchievement loadAchievementsWithCompletionHandler:^(NSArray *scores, NSError *error){
            if (error == NULL) {
                NSMutableDictionary *tempCache = [NSMutableDictionary dictionaryWithCapacity:[scores count]];
                for (GKAchievement *score in scores) {
                    [tempCache setObject:score forKey:score.identifier];
                }
                self.earnedAchievementCache = tempCache;
                [self submitAchievement:identifier percentComplete:percentComplete];
            } else {
                [self callDelegateOnMainThread:@selector(achievementSubmitted:error:) withArg:NULL error:error];
            }

        }];
    } else {
        // Search the list for the ID we're using...
        GKAchievement *achievement = [self.earnedAchievementCache objectForKey:identifier];
        if (achievement != NULL) {
            if ((achievement.percentComplete >= 100.0) || achievement.percentComplete >= percentComplete) {
                // Achievement has already been earned so we're done.
                achievement = NULL;
            }
            achievement.percentComplete = percentComplete;
        } else {
            achievement = [[GKAchievement alloc] initWithIdentifier:identifier];
            achievement.percentComplete = percentComplete;
            // Add achievement to achievement cache...
            [self.earnedAchievementCache setObject:achievement forKey:achievement.identifier];
        }
        
        if (achievement != NULL) {
            // Submit the Achievement
            [GKAchievement reportAchievements:@[achievement] withCompletionHandler:^(NSError * _Nullable error) {
                if (error != nil)
                {
                    NSLog(@"Error in reporting achievements: %@", error);
                }
            }];
            
            /*
            [achievement reportAchievementWithCompletionHandler:^(NSError *error){
                [self callDelegateOnMainThread:@selector(achievementSubmitted:error:) withArg:achievement error:error];
            }];
             */
        }
    }
}

- (void)resetAchievements
{
    self.earnedAchievementCache = NULL;
    [GKAchievement resetAchievementsWithCompletionHandler:^(NSError *error) {
        [self callDelegateOnMainThread:@selector(achievementResetResult:) withArg:NULL error:error];
    }];
}

- (void)mapPlayerIDtoPlayer:(NSString *)playerID
{
    [GKPlayer loadPlayersForIdentifiers:[NSArray arrayWithObject: playerID] withCompletionHandler:^(NSArray *playerArray, NSError *error) {
        GKPlayer *player = NULL;
        for (GKPlayer *tempPlayer in playerArray) {
            if ([tempPlayer.playerID isEqualToString:playerID]) {
                player = tempPlayer;
                break;
            }
        }
        [self callDelegateOnMainThread:@selector(mappedPlayerIDToPlayer:error:) withArg:player error:error];
    }];
}

@end
