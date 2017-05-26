//
//  F3HPokerGameModel.h
//  Tlm2048
//
//  Created by tom555cat on 15/9/25.
//  Copyright © 2015年 tom555cat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PokerModel.h"
#import "PreDefine.h"

@protocol PokerGameDelegate <NSObject>

- (void)scoreChanged:(NSInteger)newScore;

- (void)leftCardsChanged:(NSInteger)newCardsNum;

- (void)movePokerFromIndexPath:(NSIndexPath *)fromPath
                   toIndexPath:(NSIndexPath *)toPath;

- (void)movePokerFromIndexPath:(NSIndexPath *)fromPath
                   toIndexPath:(NSIndexPath *)toPath
                         delay:(CGFloat)delay;

- (void)erasePokers:(NSMutableArray *)pathArray;


- (void)insertPokerAtIndexPath:(NSIndexPath *)path
                         color:(NSInteger)color
                        number:(NSInteger)number
                    completion:(void(^)())completion;

- (void)insertPokerAtIndexPath:(NSIndexPath *)path
                         color:(NSInteger)color
                        number:(NSInteger)number
                         delay:(CGFloat)delay
                    completion:(void(^)())completion;

@end

@interface PokerGameManager : NSObject

@property (nonatomic) NSInteger score;

@property (nonatomic, strong) NSMutableArray *library;

+ (PokerGameManager *)sharedManager;

- (instancetype)initWithDimension:(NSUInteger)dimension
                         winValue:(NSUInteger)value
                         delegate:(id <PokerGameDelegate>)delegate;


- (void)reset;

- (void)insertAtRandomLocationPokerWithColor:(PokerColor)color
                                      number:(PokerNumber)number
                                  completion:(void(^)())completion;


- (void)insertPokerWithColor:(PokerColor)color
                      number:(PokerNumber)number
                atIndexPath:(NSIndexPath *)path
                  completion:(void(^)())completion;


- (void)performMoveInDirection:(MoveDirection)direction
               completionBlock:(void(^)(BOOL))completion;

- (NSArray *)mergeGroup:(NSArray *)group;

- (BOOL)userHasLost;
- (BOOL)userHasWon;


@end
