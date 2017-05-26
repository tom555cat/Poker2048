//
//  F3HPokerGameModel.m
//  Tlm2048
//
//  Created by tom555cat on 15/9/25.
//  Copyright © 2015年 tom555cat. All rights reserved.
//

#import "PokerGameManager.h"
#import "PokerGameEraseOrder.h"
#import "PokerGameErasePoker.h"
#import "PokerModel.h"
#import "SwipeCommand.h"

// Command queue
#define MAX_COMMANDS 1
#define QUEUE_DELAY  0.3
#define MOVE_DELAY 0.6
#define INSERT_DELAY 0.7

@interface PokerGameManager ()

@property (nonatomic, weak) id<PokerGameDelegate> delegate;

@property (nonatomic, strong) NSMutableArray *gameState;

@property (nonatomic) NSUInteger dimension;
@property (nonatomic) NSUInteger winValue;

@property (nonatomic, strong) NSMutableArray *commandQueue;
@property (nonatomic, strong) NSTimer *queueTimer;

//@property (nonatomic) NSInteger score;
@property (nonatomic) NSInteger leftCardsNum;

@end

@implementation PokerGameManager

+ (PokerGameManager *)sharedManager {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

- (instancetype)initWithDimension:(NSUInteger)dimension
                         winValue:(NSUInteger)value
                         delegate:(id<PokerGameDelegate>)delegate
{
    if ((self = [super init])) {
        self.dimension = dimension;
        self.winValue = value;
        self.delegate = delegate;
        [self reset];
    }
    return self;
}

- (void)reset
{
    self.score = 0;
    self.leftCardsNum = 52;
    self.gameState = nil;
    [self.commandQueue removeAllObjects];
    [self.queueTimer invalidate];
    self.queueTimer = nil;
    // 初始化牌库
    [self.library removeAllObjects];
    [self initLibrary];
}

#pragma mark - Insertion API

- (void)insertAtRandomLocationPokerWithColor:(PokerColor)color
                                      number:(PokerNumber)number
                                  completion:(void(^)())completion
{
    // Check if gameboard is full
    BOOL emptySpotFound = NO;
    for (NSInteger i = 0; i < [self.gameState count]; i++) {
        if (((PokerModel *)self.gameState[i]).empty) {
            emptySpotFound = YES;
            break;
        }
    }
    if (!emptySpotFound) {
        // Board is full, we will never be able to insert a poker
        return;
    }
    
    NSInteger row = 0;
    BOOL shouldExit = NO;
    while (YES) {
        row = arc4random_uniform((uint32_t)self.dimension);
        // Check if row has any empty spots in column
        for (NSInteger i=0; i<self.dimension; i++) {
            if ([self pokerForIndexPath:[NSIndexPath indexPathForRow:row inSection:i]].empty) {
                shouldExit = YES;
                break;
            }
        }
        if (shouldExit) {
            break;
        }
    }
    NSInteger column = 0;
    shouldExit = NO;
    while (YES) {
        column = arc4random_uniform((uint32_t)self.dimension);
        if ([self pokerForIndexPath:[NSIndexPath indexPathForRow:row inSection:column]].empty) {
            shouldExit = YES;
            break;
        }
        if (shouldExit) {
            break;
        }
    }
    // 添加一张牌，牌库的牌就减少一张
    self.leftCardsNum -= 1;
    if ([self pokerForIndexPath:[NSIndexPath indexPathForRow:row inSection:column]].isErased) {
        [self insertPokerWithColor:color number:number atIndexPath:[NSIndexPath indexPathForRow:row inSection:column] delay:INSERT_DELAY completion:completion];
        [self pokerForIndexPath:[NSIndexPath indexPathForRow:row inSection:column]].isErased = NO;
    } else {
        [self insertPokerWithColor:color number:number atIndexPath:[NSIndexPath indexPathForRow:row inSection:column] completion:completion];
    }
    NSLog(@"FinalPokerGame--Insert Poker at row: %ld, column %ld", (long)row, (long)column);
}

// Insert a tile (used by the game to add new poker to the board)
- (void)insertPokerWithColor:(PokerColor)color
                      number:(PokerNumber)number
                 atIndexPath:(NSIndexPath *)path
                  completion:(void(^)())completion
{
    if (![self pokerForIndexPath:path].empty) {
        return;
    }
    PokerModel *poker = [self pokerForIndexPath:path];
    poker.empty = NO;
    poker.pokerColor = color;
    poker.pokerNumber = number;
    [self.delegate insertPokerAtIndexPath:path color:color number:number completion:completion];
}

- (void)insertPokerWithColor:(PokerColor)color
                      number:(PokerNumber)number
                 atIndexPath:(NSIndexPath *)path
                       delay:(CGFloat)delay
                  completion:(void(^)())completion
{
    if (![self pokerForIndexPath:path].empty) {
        return;
    }
    PokerModel *poker = [self pokerForIndexPath:path];
    poker.empty = NO;
    poker.pokerColor = color;
    poker.pokerNumber = number;
    [self.delegate insertPokerAtIndexPath:path color:color number:number delay:delay completion:completion];
}

#pragma mark - Movement API

// Perform a user-initiated move in one of four directions
- (void)performMoveInDirection:(MoveDirection)direction
               completionBlock:(void(^)(BOOL))completion
{
    dispatch_barrier_async(dispatch_get_main_queue(), ^{
        SwipeCommand *command = [SwipeCommand commandWithDirection:direction completionBlock:completion];
        BOOL changed = NO;
        switch (command.direction) {
            case MoveDirectionUp:
                changed = [self performUpMove];
                break;
            case MoveDirectionDown:
                changed = [self performDownMove];
                break;
            case MoveDirectionLeft:
                changed = [self performLeftMove];
                break;
            case MoveDirectionRight:
                changed = [self performRightMove];
                break;
        }
        
        if (command.completion) {
            command.completion(changed);
        }

    });
}

- (BOOL)performUpMove
{
    BOOL atLeastOneMove = NO;
    BOOL atLeastTwoErase = NO;
    
    // Examine each column, down to up ([]-->[]-->[])
    for (NSInteger column = 0; column < self.dimension; column++) {
        NSMutableArray *thisColumnPokers = [NSMutableArray arrayWithCapacity:self.dimension];
        for (NSInteger row = 0; row < self.dimension; row++) {
            [thisColumnPokers addObject:[self pokerForIndexPath:[NSIndexPath indexPathForRow:row inSection:column]]];
        }
        
        // 去除空格后再merge
        NSArray *ordersArray = [self mergeGroup:thisColumnPokers];
        if ([ordersArray count] > 0) {
            atLeastOneMove = YES;
            for (NSInteger i = 0; i < [ordersArray count]; i++) {
                PokerGameEraseOrder *order = ordersArray[i];
                if (order.isMoving) {
                    // 移动poker
                    NSIndexPath *sourcePath = [NSIndexPath indexPathForRow:order.source1 inSection:column];
                    NSIndexPath *destinationPath = [NSIndexPath indexPathForRow:order.destination inSection:column];
                    
                    PokerModel *sourcePoker = [self pokerForIndexPath:sourcePath];
                    sourcePoker.empty = YES;
                    PokerModel *destinationPoker = [self pokerForIndexPath:destinationPath];
                    destinationPoker.empty = NO;
                    destinationPoker.pokerColor = sourcePoker.pokerColor;
                    destinationPoker.pokerNumber = sourcePoker.pokerNumber;
                    
                    // Update delegate
                    if (atLeastTwoErase) {
                        // 如果有消除的扑克，那么移动就延迟一会，以显示出先消除后移动的效果
                        [self.delegate movePokerFromIndexPath:sourcePath toIndexPath:destinationPath delay:MOVE_DELAY];
                    } else {
                        [self.delegate movePokerFromIndexPath:sourcePath toIndexPath:destinationPath];
                    }
                    
                } else {
                    // 消除pokers
                    atLeastTwoErase = YES;
                    NSMutableArray *pathArray = [[NSMutableArray alloc] init];
                    for (NSInteger i = 0; i < [order.sources count]; i++) {
                        NSIndexPath *sourcePath = [NSIndexPath indexPathForRow:[order.sources[i] integerValue] inSection:column];
                        PokerModel *sourcePoker = [self pokerForIndexPath:sourcePath];
                        sourcePoker.empty = YES;
                        sourcePoker.isErased = YES;
                        [pathArray addObject:sourcePath];
                    }
                    
                    // Update delegate
                    [self.delegate erasePokers:pathArray];
                }
            }
        }
    }
    return atLeastOneMove;
}

- (BOOL)performDownMove
{
    BOOL atLeastOneMove = NO;
    BOOL atLeastTwoErase = NO;
    
    // Examine each column, left to right ([]-->[]-->[])
    for (NSInteger column = 0; column<self.dimension; column++) {
        NSMutableArray *thisColumnTiles = [NSMutableArray arrayWithCapacity:self.dimension];
        for (NSInteger row = (self.dimension - 1); row >= 0; row--) {
            [thisColumnTiles addObject:[self pokerForIndexPath:[NSIndexPath indexPathForRow:row inSection:column]]];
        }
        
        NSArray *ordersArray = [self mergeGroup:thisColumnTiles];
        if ([ordersArray count] > 0) {
            atLeastOneMove = YES;
            for (NSInteger i=0; i<[ordersArray count]; i++) {
                PokerGameEraseOrder *order = ordersArray[i];
                NSInteger dim = self.dimension - 1;
                if (order.isMoving) {
                    // 移动poker
                    NSIndexPath *sourcePath = [NSIndexPath indexPathForRow:(dim - order.source1) inSection:column];
                    NSIndexPath *destinationPath = [NSIndexPath indexPathForRow:(dim - order.destination) inSection:column];
                    
                    PokerModel *sourcePoker = [self pokerForIndexPath:sourcePath];
                    sourcePoker.empty = YES;
                    PokerModel *destinationPoker = [self pokerForIndexPath:destinationPath];
                    destinationPoker.empty = NO;
                    destinationPoker.pokerColor = sourcePoker.pokerColor;
                    destinationPoker.pokerNumber = sourcePoker.pokerNumber;
                    
                    // Update delegate
                    if (atLeastTwoErase) {
                        [self.delegate movePokerFromIndexPath:sourcePath toIndexPath:destinationPath delay:MOVE_DELAY];
                    } else {
                        [self.delegate movePokerFromIndexPath:sourcePath toIndexPath:destinationPath];
                    }
                }
                else{
                    // 消除pokers
                    atLeastTwoErase = YES;
                    NSMutableArray *pathArray = [[NSMutableArray alloc] init];
                    for (NSInteger i = 0; i < [order.sources count]; i++) {
                        NSIndexPath *sourcePath = [NSIndexPath indexPathForRow:(dim - [order.sources[i] integerValue]) inSection:column];
                        PokerModel *sourcePoker = [self pokerForIndexPath:sourcePath];
                        sourcePoker.empty = YES;
                        [pathArray addObject:sourcePath];
                    }
                    
                    // Update delegate
                    [self.delegate erasePokers:pathArray];
                    // 释放资源
                    pathArray = nil;
                }
            }
        }
    }
    
    return atLeastOneMove;
}

- (BOOL)performLeftMove
{
    BOOL atLeastOneMove = NO;
    BOOL atLeastTwoErase = NO;
    
    // Examine each row, up to down ([TTT] --> [---] --> [____])
    for (NSInteger row = 0; row<self.dimension; row++) {
        NSMutableArray *thisRowTiles = [NSMutableArray arrayWithCapacity:self.dimension];
        for (NSInteger column = 0; column<self.dimension; column++) {
            [thisRowTiles addObject:[self pokerForIndexPath:[NSIndexPath indexPathForRow:row inSection:column]]];
        }
        
        NSArray *ordersArray = [self mergeGroup:thisRowTiles];
        if ([ordersArray count] > 0) {
            atLeastOneMove = YES;
            for (NSInteger i = 0; i < [ordersArray count]; i++) {
                PokerGameEraseOrder *order = ordersArray[i];
                if (order.isMoving) {
                    // 移动poker
                    NSIndexPath *sourcePath = [NSIndexPath indexPathForRow:row inSection:order.source1];
                    NSIndexPath *destinationPath = [NSIndexPath indexPathForRow:row inSection:order.destination];
                    
                    PokerModel *sourcePoker = [self pokerForIndexPath:sourcePath];
                    sourcePoker.empty = YES;
                    PokerModel *destinationPoker = [self pokerForIndexPath:destinationPath];
                    destinationPoker.empty = NO;
                    destinationPoker.pokerColor = sourcePoker.pokerColor;
                    destinationPoker.pokerNumber = sourcePoker.pokerNumber;
                    
                    // Update delegate
                    if (atLeastTwoErase) {
                        [self.delegate movePokerFromIndexPath:sourcePath toIndexPath:destinationPath delay:MOVE_DELAY];
                    } else {
                        [self.delegate movePokerFromIndexPath:sourcePath toIndexPath:destinationPath];
                    }
                }
                else{
                    // 消除pokers
                    atLeastTwoErase = YES;
                    NSMutableArray *pathArray = [[NSMutableArray alloc] init];
                    for (NSInteger i = 0; i < [order.sources count]; i++) {
                        NSIndexPath *sourcePath = [NSIndexPath indexPathForRow:row inSection:[order.sources[i] integerValue]];
                        PokerModel *sourcePoker = [self pokerForIndexPath:sourcePath];
                        sourcePoker.empty = YES;
                        [pathArray addObject:sourcePath];
                    }
                    
                    // Update delegate
                    [self.delegate erasePokers:pathArray];
                }
            }
        }
    }

    
    return atLeastOneMove;
}

- (BOOL)performRightMove
{
    BOOL atLeastOneMove = NO;
    BOOL atLeastTwoErase = NO;
    
    // Examine each row, up to down ([TTT] --> [---] --> [____])
    for (NSInteger row = 0; row<self.dimension; row++) {
        NSMutableArray *thisRowTiles = [NSMutableArray arrayWithCapacity:self.dimension];
        for (NSInteger column = (self.dimension - 1); column >= 0; column--) {
            [thisRowTiles addObject:[self pokerForIndexPath:[NSIndexPath indexPathForRow:row inSection:column]]];
        }
        
        NSArray *ordersArray = [self mergeGroup:thisRowTiles];
        if ([ordersArray count] > 0) {
            NSInteger dim = self.dimension - 1;
            atLeastOneMove = YES;
            for (NSInteger i=0; i<[ordersArray count]; i++) {
                PokerGameEraseOrder *order = ordersArray[i];
                if (order.isMoving) {
                    // 移动poker
                    NSIndexPath *sourcePath = [NSIndexPath indexPathForRow:row inSection:(dim - order.source1)];
                    NSIndexPath *destinationPath = [NSIndexPath indexPathForRow:row inSection:(dim - order.destination)];
                    
                    PokerModel *sourcePoker = [self pokerForIndexPath:sourcePath];
                    sourcePoker.empty = YES;
                    PokerModel *destinationPoker = [self pokerForIndexPath:destinationPath];
                    destinationPoker.empty = NO;
                    destinationPoker.pokerColor = sourcePoker.pokerColor;
                    destinationPoker.pokerNumber = sourcePoker.pokerNumber;
                    
                    // Update delegate
                    if (atLeastTwoErase) {
                        [self.delegate movePokerFromIndexPath:sourcePath toIndexPath:destinationPath delay:MOVE_DELAY];
                    } else {
                        [self.delegate movePokerFromIndexPath:sourcePath toIndexPath:destinationPath];
                    }
                }
                else{
                    // 消除pokers
                    atLeastTwoErase = YES;
                    NSMutableArray *pathArray = [[NSMutableArray alloc] init];
                    for (NSInteger i = 0; i < [order.sources count]; i++) {
                        NSIndexPath *sourcePath = [NSIndexPath indexPathForRow:row inSection:(dim - [order.sources[i] integerValue])];
                        PokerModel *sourcePoker = [self pokerForIndexPath:sourcePath];
                        sourcePoker.empty = YES;
                        [pathArray addObject:sourcePath];
                    }
                    
                    // Update delegate
                    [self.delegate erasePokers:pathArray];
                }
            }
        }
    }
    
    
    return atLeastOneMove;
}

#pragma mark - Game State API

- (BOOL)userHasLost
{
    for (NSInteger i = 0; i < [self.gameState count]; i++) {
        if (((PokerModel *) self.gameState[i]).empty) {
            return NO;
        }
    }
    // This is a stupid algorithm, but given how small the game board is it should work just fine
    // Every tile compares its value to that of the tiles to the right and below (if possible)
    for (NSInteger i=0; i<self.dimension; i++) {
        for (NSInteger j=0; j<self.dimension; j++) {
            PokerModel *poker = [self pokerForIndexPath:[NSIndexPath indexPathForRow:i inSection:j]];
            if (j != (self.dimension - 1)
                && poker.pokerNumber == [self pokerForIndexPath:[NSIndexPath indexPathForRow:i inSection:j+1]].pokerNumber) {
                return NO;
            }
            if (i != (self.dimension - 1)
                && poker.pokerNumber == [self pokerForIndexPath:[NSIndexPath indexPathForRow:i+1 inSection:j]].pokerNumber) {
                return NO;
            }
        }
    }
    return YES;
}

- (BOOL)userHasWon
{
    if ([self.library count] == 0) {
        return YES;
    }
    else{
        return NO;
    }
}


#pragma mark - Private Methods
- (PokerModel *)pokerForIndexPath:(NSIndexPath *)indexPath {
    NSInteger idx = (indexPath.row*self.dimension + indexPath.section);
    if (idx >= [self.gameState count]) {
        return nil;
    }
    return self.gameState[idx];
}

- (void)setPoker:(PokerModel *)poker forIndexPath:(NSIndexPath *)indexPath
{
    NSInteger idx = (indexPath.row*self.dimension + indexPath.section);
    if (!poker || idx >= [self.gameState count]) {
        return;
    }
    self.gameState[idx] = poker;
}

- (NSMutableArray *)commandQueue {
    if (!_commandQueue) {
        _commandQueue = [NSMutableArray array];
    }
    return _commandQueue;
}

- (NSMutableArray *)gameState {
    if (!_gameState) {
        _gameState = [NSMutableArray array];
        for (NSInteger i=0; i<(self.dimension * self.dimension); i++) {
            [_gameState addObject:[PokerModel emptyPoker]];
        }
    }
    return _gameState;
}

- (void)setScore:(NSInteger)score
{
    _score = score;
    [self.delegate scoreChanged:score];
}

- (void)setLeftCardsNum:(NSInteger)leftCardsNum
{
    _leftCardsNum = leftCardsNum;
    [self.delegate leftCardsChanged:leftCardsNum];
}

// 设置牌库
- (void)initLibrary
{
    for (NSInteger i = 1; i <= 4; i++) {
        for (NSInteger j = 1; j <= 13; j++) {
            NSMutableArray *poker = [[NSMutableArray alloc] init];
            [poker addObject:[[NSNumber alloc] initWithInteger:i]];
            [poker addObject:[[NSNumber alloc] initWithInteger:j]];
            [self.library addObject:poker];
        }
    }
}

- (NSMutableArray *)library
{
    if (!_library) {
        _library = [[NSMutableArray alloc] init];
    }
    return  _library;
}

// 消除一列的空余tiles
- (NSArray *)removeEmptyTiles:(NSArray *)group
{
    // Step 1: move empty tiles
    NSInteger ctr = 0;
    NSMutableArray *stack1 = [NSMutableArray array];
    for (NSInteger i = 0; i < self.dimension; i++) {
        PokerModel *poker = group[i];
        if (poker.empty) {
            continue;
        }
        PokerGameErasePoker *erasePoker = [PokerGameErasePoker erasePoker];
        [erasePoker.originalIndexArray addObject:[NSNumber numberWithInteger:i]];
        [erasePoker.pokerArray addObject:poker];
        if (i == ctr) {
            erasePoker.mode = PokerEraseModeNoAction;
        } else {
            erasePoker.mode = PokerEraseModeMove;
        }
        [stack1 addObject:erasePoker];
        ctr++;
    }
    if ([stack1 count] == 0) {
        return nil;
    } else if([stack1 count] == 1){
        if (((PokerGameErasePoker *)stack1[0]).mode == PokerEraseModeMove) {
            PokerGameErasePoker *mPoker = (PokerGameErasePoker *)stack1[0];
            return @[[PokerGameEraseOrder pokerMoveWithSource:[mPoker.originalIndexArray[0] integerValue] destination:0 poker:mPoker.pokerArray[0]]];
        } else {
            return nil;
        }
    }
    
    // create move orders for each tiles
    NSMutableArray *stack2 = [NSMutableArray array];
    for (NSInteger i = 0; i < [stack1 count]; i++) {
        PokerGameErasePoker *mPoker = stack1[i];
        switch (mPoker.mode) {
            case PokerEraseModeEmpty:
                continue;
            case PokerEraseModeNoAction:
                break;
            case PokerEraseModeMove:
                [stack2 addObject:[PokerGameEraseOrder pokerMoveWithSource:[mPoker.originalIndexArray[0] integerValue] destination:i poker:mPoker.pokerArray[0]]];
                break;
            case PokerEraseModeErase:
                break;
            default:
                break;
        }
    }
    
    return [NSArray arrayWithArray:stack2];
}

// Merge some items to the left
// "Group" is an array of tile objects
- (NSArray *)mergeGroup:(NSArray *)group
{
    NSInteger ctr = 0;                                          // ctr是消除空格后该行(列)的长度
    
    // STEP 1: collapse all tiles (remove any interstital space)
    // e.g. |[2] [ ] [ ] [4]| becomes |[2] [4]|
    // At this point, tiles either move or don't move, and their value remains the same
    // 挑选出这一列需要移动的tiles,放在数组中,将空格弃掉.
    NSMutableArray *stack1 = [NSMutableArray array];            // stack1是消除空格后的扑克牌构成的数组
    for (NSInteger i = 0; i < self.dimension; i++) {
        PokerModel *poker = group[i];
        if (poker.empty) {
            continue;
        }
        PokerGameErasePoker *erasePoker = [PokerGameErasePoker erasePoker];
        [erasePoker.originalIndexArray addObject:[NSNumber numberWithInteger:i]];
        [erasePoker.pokerArray addObject:poker];
        if (i == ctr) {
            erasePoker.mode = PokerEraseModeNoAction;
        }
        else{
            erasePoker.mode = PokerEraseModeMove;
        }
        [stack1 addObject:erasePoker];
        ctr++;
    }
    
    if ([stack1 count] == 0) {
        return nil;
    } else if([stack1 count] == 1){
        if (((PokerGameErasePoker *)stack1[0]).mode == PokerEraseModeMove) {
            PokerGameErasePoker *mPoker = (PokerGameErasePoker *)stack1[0];
            return @[[PokerGameEraseOrder pokerMoveWithSource:[mPoker.originalIndexArray[0] integerValue] destination:0 poker:mPoker.pokerArray[0]]];
        } else{
            return nil;
        }
    }
    
    // step 2
    // 从stack1中找出最长有效序列，并消除
    // 规则：从前往后，例如[1,1,3,2,2,2]-->[3]；
    // 以后可能会添加其他消除规则
    // 如果存在不止一条最长的可消除的路径，则将它们都消除掉；
    NSInteger straightLen = 0;         // 顺子长度
    NSInteger flushLen = 0;            // 同花长度
    NSInteger sameNumberLen = 0;       // 数字一致长度
    NSMutableArray *stack2;
    // 通过深度拷贝stack1来测试哪一种消除方法能够消除更多poker
    NSMutableArray *stack1Number = [self copyPokerModleArray:stack1];
    NSMutableArray *stack1Color = [self copyPokerModleArray:stack1];
    NSMutableArray *stack1Straight = [self copyPokerModleArray:stack1];
    
    NSMutableArray *stack2Number = [self erasePokerWithNumber:stack1Number];
    NSMutableArray *stack2Color = [self erasePokerWithColor:stack1Color];
    NSMutableArray *stack2Straight = [self erasePokerWithStraight:stack1Straight];
    
    if (!stack2Color) {
        // 设置一个比较大的值
        flushLen = 99999;
    } else {
        flushLen = [stack2Color count];             // 同花最大长度为stack1的长度
    }
    
    if (!stack2Straight) {
        straightLen = 99999;
    } else {
        straightLen = [stack2Straight count];       // 顺子最大长度为stack1的长度
    }
    
    sameNumberLen = [stack2Number count];           // 数字一致最大长度为stack1的长度
    
    if (sameNumberLen <= straightLen && sameNumberLen <= flushLen) {
        stack2 = [self erasePokerWithNumber:stack1];
    } else if (straightLen <= sameNumberLen && straightLen <= flushLen) {
        stack2 = [self erasePokerWithStraight:stack1];
    } else if (flushLen <= sameNumberLen && flushLen <= straightLen) {
        stack2 = [self erasePokerWithColor:stack1];
    }
    
    // STEP 3: create move orders for each mergeTile that did change this round
    NSMutableArray *stack3 = [NSMutableArray new];
    //NSInteger movePokerDestination = 0;   // 主要为了统计移动的poker需要移动到什么位置
    // 计算每一个poker的最终位置
    NSMutableDictionary *pokerLocation = [[NSMutableDictionary alloc] init];
    NSInteger location = 0;                 // 最后每个poker的位置
    for (NSInteger i = 0; i < [stack2 count]; i++) {
        if (((PokerGameErasePoker *)stack2[i]).mode != PokerEraseModeErase ) {
            [pokerLocation setObject:[NSNumber numberWithInteger:location] forKey:[NSString stringWithFormat:@"%ld", (long)i]];
            location += 1;
        }
    }
    for (NSInteger i = 0; i < [stack2 count]; i++) {
        PokerGameErasePoker *mPoker = stack2[i];
        BOOL isSameKind = NO;
        BOOL isFlush = NO;
        BOOL isStraight = NO;
        switch (mPoker.mode) {
            case PokerEraseModeEmpty:
                continue;
            case PokerEraseModeNoAction:
                // 因为前面有不移动的poker，所以移动位置增1
                //movePokerDestination += 1;
                break;
            case PokerEraseModeMove:
                // Move Poker
                [stack3 addObject:[PokerGameEraseOrder pokerMoveWithSource:[mPoker.originalIndexArray[0] integerValue]
                                                         destination:[pokerLocation[[NSString stringWithFormat:@"%ld", (long)i]] integerValue]
                                                               poker:mPoker.pokerArray[0]]];
                // Poker下一个移动位置+1
                //movePokerDestination += 1;
                break;
            case PokerEraseModeErase:
                [stack3 addObject:[PokerGameEraseOrder erasePokersWithSources:mPoker.originalIndexArray
                                                                 pokers:mPoker.pokerArray]];
                // 计算得分
                NSInteger eraseCount = [mPoker.originalIndexArray count];
                switch (eraseCount) {
                    case 2:
                        self.score += 1;
                        break;
                    case 3:
                        // same kind:8分，flush：4分，straight：12分
                        isSameKind = [self isSameKind:mPoker.pokerArray];
                        isFlush = [self isFlush:mPoker.pokerArray];
                        isStraight = [self isStraight:mPoker.pokerArray];
                        
                        if (isFlush) {
                            self.score += 4;
                        }
                        
                        if (isStraight) {
                            self.score += 6;
                        }
                        
                        if (isSameKind) {
                            self.score += 8;
                        }
                        
                        break;
                    case 4:
                        // same kind:16分，flush:8分，straight：12分
                        isSameKind = [self isSameKind:mPoker.pokerArray];
                        isFlush = [self isFlush:mPoker.pokerArray];
                        isStraight = [self isStraight:mPoker.pokerArray];
                        
                        if (isFlush) {
                            self.score += 8;
                        }
                        
                        if (isStraight) {
                            self.score += 12;
                        }
                        
                        if (isSameKind) {
                            self.score += 16;
                        }
                        
                        break;
                }
                
                //self.score += [mPoker.originalIndexArray count];
                break;
                
            default:
                break;
        }
    }
    // Return the finalized array
    return [NSArray arrayWithArray:stack3];
}

// 判断pokerArray是否是同花
- (BOOL)isFlush:(NSArray *)pokerArray
{
    PokerModel *tempPokerModel = pokerArray[0];
    for (PokerModel *pokerModel in pokerArray) {
        if (pokerModel.pokerColor != tempPokerModel.pokerColor) {
            return NO;
        }
    }
    
    return YES;
}

// 判断pokerArray是否是顺子
- (BOOL)isStraight:(NSArray *)pokerArray
{
    PokerModel *pm1 = nil;
    PokerModel *pm2 = nil;
    PokerModel *pm3 = nil;
    PokerModel *pm4 = nil;
    
    if ([pokerArray count] == 3) {
        pm1 = pokerArray[0];
        pm2 = pokerArray[1];
        pm3 = pokerArray[2];
        
        if ((pm1.pokerNumber - pm2.pokerNumber) == (pm2.pokerNumber - pm3.pokerNumber)) {
            return YES;
        } else {
            return NO;
        }
    } else {
        pm1 = pokerArray[0];
        pm2 = pokerArray[1];
        pm3 = pokerArray[2];
        pm4 = pokerArray[3];
        
        if ((pm1.pokerNumber - pm2.pokerNumber) == (pm2.pokerNumber - pm3.pokerNumber) &&
            (pm2.pokerNumber - pm3.pokerNumber) == (pm3.pokerNumber - pm4.pokerNumber)) {
            return YES;
        } else {
            return NO;
        }
    }
}

// 判断pokerArray是否是same kind
- (BOOL)isSameKind:(NSArray *)pokerArray
{
    PokerModel *tempPokerModel = pokerArray[0];
    for (PokerModel *pokerModel in pokerArray) {
        if (pokerModel.pokerNumber != tempPokerModel.pokerNumber) {
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)isInArray:(NSMutableArray *)stack poker:(PokerGameErasePoker *)p
{
    for (NSInteger i = 0; i < [stack count]; i++) {
        if (stack[i] == p) {
            return YES;
        }
    }
    return NO;
}

// 根据数字的相同来消除poker(消除对，3个一样，炸弹)
- (NSMutableArray *)erasePokerWithNumber:(NSMutableArray *)stack1
{
    BOOL priorEraseHappened = NO;      // 如果前边的发生了Erase，那么后边的状态就会变成move
    NSMutableArray *stack2 = [NSMutableArray array];
    NSInteger start = 0;
    NSInteger end = 1;
    for (end = 1; end < [stack1 count]; end++) {
        PokerGameErasePoker *p1 = (PokerGameErasePoker *)stack1[start];
        PokerModel *p1Model = p1.pokerArray[0];
        PokerGameErasePoker *p2 = (PokerGameErasePoker *)stack1[end];
        PokerModel *p2Model = p2.pokerArray[0];
        if (p1Model.pokerNumber == p2Model.pokerNumber) {
            // 查找p1是否已经加入stack2,这里将p1加入stack2主要是为了考虑如果2个相同的牌在末尾，就会
            // 跳过else中的p1添加stack2语句。
            if (![self isInArray:stack2 poker:p1]) {
                [stack2 addObject:p1];
            }
            
            [p1.originalIndexArray addObject:p2.originalIndexArray[0]];
            [p1.pokerArray addObject:p2.pokerArray[0]];
            // erasePoker中的originalIndexArray个数大于1，说明需要消除
            p1.mode = PokerEraseModeErase;
            priorEraseHappened = YES;
            
        } else {
            /*
             if ([p1.originalIndexArray count] > 1) {
             p1.mode = PokerGameErasePokerModeErase;
             }
             */
            // [stack2 addObject:p1];
            
            if (![self isInArray:stack2 poker:p1]) {
                [stack2 addObject:p1];
            }
            // 如果已经发生过Erase，则当前的ErasePoker的状态要修改为move
            if (p1.mode == PokerEraseModeNoAction && priorEraseHappened == YES) {
                p1.mode = PokerEraseModeMove;
            }
            
            start = end;
        }
    }
    // 这种情况就是最后一个没有被消除，如果之前的扑克被消除了的话，需要移动该扑克
    if(start == [stack1 count] - 1)
    {
        PokerGameErasePoker *p = (PokerGameErasePoker *)stack1[start];
        if (p.mode == PokerEraseModeNoAction && priorEraseHappened == YES) {
            p.mode = PokerEraseModeMove;
        }
        [stack2 addObject:stack1[start]];
    }
    return stack2;
}


// 消除同花（3个同花，4个同花）
- (NSMutableArray *)erasePokerWithColor:(NSMutableArray *)stack1
{
    if ([stack1 count] < 3) {
        return nil;
    }
    NSMutableArray *stack2 = [NSMutableArray array];
    BOOL priorEraseHappened = NO;      // 如果前边的发生了Erase，那么后边的状态就会变成move
    NSInteger begin = 0;
    NSInteger accNum = 1;              // 花色相同扑克的累计
    for (int i = 1; i < [stack1 count]; i++) {
        PokerGameErasePoker *p1 = (PokerGameErasePoker *)stack1[begin];
        PokerModel *p1Model = p1.pokerArray[0];
        PokerGameErasePoker *p2 = (PokerGameErasePoker *)stack1[i];
        PokerModel *p2Model = p2.pokerArray[0];
        if (p1Model.pokerColor == p2Model.pokerColor) {
            accNum += 1;
        }
        else{
            if (accNum > 2) {
                // 将相同颜色合并，添加进stack2
                for (NSInteger j = begin + 1; j < begin + accNum; j++) {
                    PokerGameErasePoker *p = (PokerGameErasePoker *)stack1[j];
                    [p1.originalIndexArray addObject:p.originalIndexArray[0]];
                    [p1.pokerArray addObject:p.pokerArray[0]];
                }
                p1.mode = PokerEraseModeErase;
                priorEraseHappened = YES;
                
                [stack2 addObject:p1];
            }
            else{
                // 颜色不同，则分别单独放进stack2
                for (NSInteger j = begin; j < begin + accNum; j++) {
                    PokerGameErasePoker *p = (PokerGameErasePoker *)stack1[j];
                    if (p.mode == PokerEraseModeNoAction && priorEraseHappened == YES) {
                        p.mode = PokerEraseModeMove;
                    }
                    [stack2 addObject:p1];
                }
            }
            begin = i;
            accNum = 1;
        }
    }
    
    if (accNum == 1) {
        if (priorEraseHappened == YES) {
            PokerGameErasePoker *p = (PokerGameErasePoker *)stack1[[stack1 count] - 1];
            p.mode = PokerEraseModeMove;
            [stack2 addObject:p];
        }
        else{
            PokerGameErasePoker *p = (PokerGameErasePoker *)stack1[[stack1 count] - 1];
            [stack2 addObject:p];
        }
    }
    
    // 如果最后一个poker的颜色和前一个一样，那么需要处理
    if (accNum == 2) {
        //倒数两个花色相同
        PokerGameErasePoker *p1 = (PokerGameErasePoker *)stack1[[stack1 count] - 2];
        PokerGameErasePoker *p2 = (PokerGameErasePoker *)stack1[[stack1 count] - 1];
        [stack2 addObject:p1];
        [stack2 addObject:p2];
    }
    
    if (accNum == 3) {
        if ([stack1 count] == 3) {
            PokerGameErasePoker *p1 = (PokerGameErasePoker *)stack1[0];
            PokerGameErasePoker *p2 = (PokerGameErasePoker *)stack1[1];
            PokerGameErasePoker *p3 = (PokerGameErasePoker *)stack1[2];
            [p1.originalIndexArray addObject:p2.originalIndexArray[0]];
            [p1.pokerArray addObject:p2.pokerArray[0]];
            [p1.originalIndexArray addObject:p3.originalIndexArray[0]];
            [p1.pokerArray addObject:p3.pokerArray[0]];
            p1.mode = PokerEraseModeErase;
            [stack2 addObject:p1];
        }
        else{
            PokerGameErasePoker *p1 = (PokerGameErasePoker *)stack1[1];
            PokerGameErasePoker *p2 = (PokerGameErasePoker *)stack1[2];
            PokerGameErasePoker *p3 = (PokerGameErasePoker *)stack1[3];
            [p1.originalIndexArray addObject:p2.originalIndexArray[0]];
            [p1.pokerArray addObject:p2.pokerArray[0]];
            [p1.originalIndexArray addObject:p3.originalIndexArray[0]];
            [p1.pokerArray addObject:p3.pokerArray[0]];
            p1.mode = PokerEraseModeErase;
            [stack2 addObject:p1];
            
        }
    }
    
    if (accNum == 4) {
        PokerGameErasePoker *p1 = (PokerGameErasePoker *)stack1[0];
        PokerGameErasePoker *p2 = (PokerGameErasePoker *)stack1[1];
        PokerGameErasePoker *p3 = (PokerGameErasePoker *)stack1[2];
        PokerGameErasePoker *p4 = (PokerGameErasePoker *)stack1[3];
        [p1.originalIndexArray addObject:p2.originalIndexArray[0]];
        [p1.pokerArray addObject:p2.pokerArray[0]];
        [p1.originalIndexArray addObject:p3.originalIndexArray[0]];
        [p1.pokerArray addObject:p3.pokerArray[0]];
        [p1.originalIndexArray addObject:p4.originalIndexArray[0]];
        [p1.pokerArray addObject:p4.pokerArray[0]];
        p1.mode = PokerEraseModeErase;
        [stack2 addObject:p1];
    }
    
    return stack2;
}

// 根据顺子来消除poker
- (NSMutableArray *)erasePokerWithStraight:(NSMutableArray *)stack1
{
    if ([stack1 count] < 3) {
        return nil;
    }
    NSMutableArray *stack2 = [NSMutableArray array];
    NSMutableArray *difference = [[NSMutableArray alloc] init];
    for (NSInteger i=0; i < [stack1 count] - 1; i++) {
        PokerGameErasePoker *p1 = (PokerGameErasePoker *)stack1[i];
        PokerModel *p1Model = p1.pokerArray[0];
        PokerGameErasePoker *p2 = (PokerGameErasePoker *)stack1[i+1];
        PokerModel *p2Model = p2.pokerArray[0];
        [difference addObject:[NSNumber numberWithInt:(p2Model.pokerNumber - p1Model.pokerNumber)]];
    }
    // 如果stack1有3个值
    if ([difference count] == 2) {
        PokerGameErasePoker *p1 = (PokerGameErasePoker *)stack1[0];
        PokerGameErasePoker *p2 = (PokerGameErasePoker *)stack1[1];
        PokerGameErasePoker *p3 = (PokerGameErasePoker *)stack1[2];
        
        if ([(NSNumber *)difference[0] integerValue] == [(NSNumber *)difference[1] integerValue]
            && ([(NSNumber *)difference[0] integerValue] == 1 || [(NSNumber *)difference[0] integerValue] == -1)) {
            [p1.originalIndexArray addObject:p2.originalIndexArray[0]];
            [p1.pokerArray addObject:p2.pokerArray[0]];
            [p1.originalIndexArray addObject:p3.originalIndexArray[0]];
            [p1.pokerArray addObject:p3.pokerArray[0]];
            p1.mode = PokerEraseModeErase;
            [stack2 addObject:p1];
        }
        else{
            [stack2 addObject:p1];
            [stack2 addObject:p2];
            [stack2 addObject:p3];
        }
    }
    else if ([difference count] == 3){
        PokerGameErasePoker *p1 = (PokerGameErasePoker *)stack1[0];
        PokerGameErasePoker *p2 = (PokerGameErasePoker *)stack1[1];
        PokerGameErasePoker *p3 = (PokerGameErasePoker *)stack1[2];
        PokerGameErasePoker *p4 = (PokerGameErasePoker *)stack1[3];
        if ([self isArrayEqual:difference] &&
            ([(NSNumber *)difference[0] integerValue] == 1 || [(NSNumber *)difference[0] integerValue] == -1)) {
            [p1.originalIndexArray addObject:p2.originalIndexArray[0]];
            [p1.pokerArray addObject:p2.pokerArray[0]];
            [p1.originalIndexArray addObject:p3.originalIndexArray[0]];
            [p1.pokerArray addObject:p3.pokerArray[0]];
            [p1.originalIndexArray addObject:p4.originalIndexArray[0]];
            [p1.pokerArray addObject:p4.pokerArray[0]];
            p1.mode = PokerEraseModeErase;
            [stack2 addObject:p1];
        }
        else{
            if([(NSNumber *)difference[0] integerValue] == [(NSNumber *)difference[1] integerValue]
                && ([(NSNumber *)difference[0] integerValue] == 1 || [(NSNumber *)difference[0] integerValue] == -1))
            {
                [p1.originalIndexArray addObject:p2.originalIndexArray[0]];
                [p1.pokerArray addObject:p2.pokerArray[0]];
                [p1.originalIndexArray addObject:p3.originalIndexArray[0]];
                [p1.pokerArray addObject:p3.pokerArray[0]];
                p1.mode = PokerEraseModeErase;
                [stack2 addObject:p1];
                p4.mode = PokerEraseModeMove;
                [stack2 addObject:p4];
            }
            else if ([(NSNumber *)difference[1] integerValue] == [(NSNumber *)difference[2] integerValue]
                     && ([(NSNumber *)difference[1] integerValue] == 1 || [(NSNumber *)difference[1] integerValue] == -1))
            {
                [p2.originalIndexArray addObject:p3.originalIndexArray[0]];
                [p2.pokerArray addObject:p3.pokerArray[0]];
                [p2.originalIndexArray addObject:p4.originalIndexArray[0]];
                [p2.pokerArray addObject:p4.pokerArray[0]];
                p2.mode = PokerEraseModeErase;
                [stack2 addObject:p2];
            }
            else{
                [stack2 addObject:p1];
                [stack2 addObject:p2];
                [stack2 addObject:p3];
                [stack2 addObject:p4];
            }
            
        }
        
    }
    return  stack2;
}

- (BOOL)isArrayEqual:(NSMutableArray *)array
{
    BOOL rt = YES;
    for (NSInteger i = 0; i < [array count] - 1; i++) {
        if ([(NSNumber *)array[i] integerValue] != [(NSNumber *)array[i+1] integerValue]) {
            rt = NO;
            break;
        }
    }
    return rt;
}

// 深拷贝pokerModel数组
- (NSMutableArray *)copyPokerModleArray:(NSMutableArray *)array
{
    NSMutableArray *arrayCopy = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < [array count]; i++) {
        PokerGameErasePoker *erasePoker = (PokerGameErasePoker *)array[i];
        PokerGameErasePoker *erasePokerCopy = [PokerGameErasePoker copyWithErasePoker:erasePoker];
        [arrayCopy addObject:erasePokerCopy];
    }
    return arrayCopy;
}



@end
